import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:limit_it_app/core/models/plan_model.dart';
import 'package:limit_it_app/core/services/api_constants.dart';
import 'package:limit_it_app/core/services/api_client.dart';
import 'package:limit_it_app/controllers/upgrade_premium_controller.dart';
import 'package:limit_it_app/core/constants/iap_products.dart';
import 'package:limit_it_app/core/helpers/localization_helper.dart';

// Product IDs live in core/constants/iap_products.dart so this screen,
// in_app_purchase_screen.dart and choose_plan_screen.dart cannot drift apart.

// ─── Screen ───────────────────────────────────────────────────────────────────

class UpgradePremiumScreen extends StatefulWidget {
  const UpgradePremiumScreen({super.key});

  @override
  State<UpgradePremiumScreen> createState() => _UpgradePremiumScreenState();
}

class _UpgradePremiumScreenState extends State<UpgradePremiumScreen> {
  // ── GetX controller ──────────────────────────────────────────────────────
  late final UpgradePremiumController _controller;

  // ── In-App Purchase ──────────────────────────────────────────────────────
  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;
  bool _iapAvailable = false;
  Map<String, ProductDetails> _iapProducts = {}; // productId → ProductDetails

  // Track which plan is currently being purchased
  PlanModel? _pendingPlan;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<UpgradePremiumController>();
    _initIAP();

    // Listen to plans changes and reload IAP products when plans are loaded
    ever(_controller.plans, (_) {
      if (_controller.plans.isNotEmpty && _iapAvailable) {
        _loadIAPProducts();
      }
    });
  }

  // ── IAP Initialization ───────────────────────────────────────────────────

  Future<void> _initIAP() async {
    final available = await _iap.isAvailable();
    if (!available) {
      debugPrint('====> IAP not available on this device');
      setState(() => _iapAvailable = false);
      return;
    }

    setState(() => _iapAvailable = true);

    // Listen to purchase stream
    _purchaseSubscription = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () => _purchaseSubscription?.cancel(),
      onError: (error) {
        debugPrint('====> IAP stream error: $error');
        _showErrorSnackbar(appL10n.purchaseError('$error'));
      },
    );

    // Load IAP products from Play Store
    await _loadIAPProducts();

    // Restore any existing purchases
    await _iap.restorePurchases();
  }

  Future<void> _loadIAPProducts() async {
    // Generate product IDs dynamically from available plans
    final productIds = productIdsFor(_controller.plans);

    if (productIds.isEmpty) {
      debugPrint('====> No plans available — skipping IAP query');
      return;
    }

    debugPrint('====> Querying IAP products: $productIds');

    final response = await _iap.queryProductDetails(productIds);

    if (response.error != null) {
      debugPrint('====> IAP query error: ${response.error!.message}');
      return;
    }

    setState(() {
      _iapProducts = {
        for (var p in response.productDetails) p.id: p,
      };
    });

    debugPrint('====> IAP products loaded: ${_iapProducts.keys.toList()}');
  }

  // ── Purchase Flow ────────────────────────────────────────────────────────

  /// Price to show for [plan]: the store's own localised price once the product
  /// is loaded, so a card never advertises a different amount than the purchase
  /// sheet charges. Falls back to the backend price until the store answers.
  String _priceLabelFor(PlanModel plan) {
    final productId = productIdFor(plan);
    final product = productId == null ? null : _iapProducts[productId];
    return product?.price ?? '\$${plan.price.toStringAsFixed(2)}';
  }

  Future<void> _onSubscribePressed(PlanModel plan) async {
    // Premium is only ever granted after a real store purchase — no mock
    // fallback, otherwise the app would hand out a paid plan for free.
    if (!_iapAvailable) {
      debugPrint('====> IAP not available on this device');
      _showErrorSnackbar(appL10n.storeUnavailable);
      return;
    }

    final productId = resolveProductId(plan, uniqueProductPlans(_controller.plans));
    final product = productId == null ? null : _iapProducts[productId];

    if (product == null) {
      debugPrint('====> No purchasable product for plan "${plan.name}" ($productId)');
      _showErrorSnackbar(appL10n.planNotAvailable);
      return;
    }

    // Store pending plan so we can use it in _onPurchaseUpdate
    _pendingPlan = plan;

    // Trigger Google Play purchase sheet
    final purchaseParam = PurchaseParam(
      productDetails: product,
    );

    try {
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      // Result comes via _onPurchaseUpdate stream
    } catch (e) {
      _pendingPlan = null;
      debugPrint('====> IAP buy error: $e');
      _showErrorSnackbar(appL10n.couldNotStartPurchase('$e'));
    }
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final purchase in purchaseDetailsList) {
      debugPrint('====> Purchase update: ${purchase.productID} — ${purchase.status}');

      switch (purchase.status) {
        case PurchaseStatus.pending:
          _showSnackbar(appL10n.paymentPending, color: Colors.orange);
          break;

        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _handleSuccessfulPurchase(purchase);
          break;

        case PurchaseStatus.error:
          _pendingPlan = null;
          _handlePurchaseError(purchase.error!);
          break;

        case PurchaseStatus.canceled:
          _pendingPlan = null;
          _showSnackbar(appL10n.purchaseCancelled, color: Colors.grey);
          break;
      }

      // Always complete the purchase to avoid re-delivery
      if (purchase.pendingCompletePurchase) {
        _iap.completePurchase(purchase);
      }
    }
  }

  Future<void> _handleSuccessfulPurchase(PurchaseDetails purchase) async {
    final plan = _pendingPlan;
    _pendingPlan = null;

    if (plan == null) {
      debugPrint('====> Purchase received but no pending plan found');
      return;
    }

    // Use Google Play purchaseID as the paymentId for your backend
    final paymentId = purchase.purchaseID ??
        'iap_${purchase.productID}_${DateTime.now().millisecondsSinceEpoch}';

    debugPrint('====> IAP purchase successful, calling backend with paymentId: $paymentId');

    await _callBackendSubscribe(plan: plan, paymentId: paymentId);
  }

  void _handlePurchaseError(IAPError error) {
    debugPrint('====> IAP error: ${error.code} — ${error.message}');
    _showErrorSnackbar(appL10n.purchaseFailed('${error.message}'));
  }

  // ── Backend API Call ─────────────────────────────────────────────────────

  Future<void> _callBackendSubscribe({
    required PlanModel plan,
    required String paymentId,
  }) async {
    // Show loading
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );
    }

    try {
      final response = await ApiClient.postData(
        ApiConstants.subscribeEndPoint, // "/subscriptions/subscribe"
        jsonEncode({
          'planId': plan.id,
          'paymentId': paymentId,
        }),
      );

      if (mounted) Navigator.of(context).pop(); // close loading

      if (response.statusCode == 201 && response.body != null) {
        final data = response.body as Map<String, dynamic>;

        if (data['status'] == 'success' && data['statusCode'] == 201) {
          _showSuccessDialog(plan);
        } else {
          _showErrorSnackbar(data['message'] ?? appL10n.subscriptionFailed);
        }
      } else {
        _showErrorSnackbar(appL10n.serverErrorWithMessage('${response.statusText}'));
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      _showErrorSnackbar(e.toString());
    }
  }

  // ── Dialogs & Snackbars ──────────────────────────────────────────────────

  void _showSuccessDialog(PlanModel plan) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF1C3D2E), size: 64),
            const SizedBox(height: 16),
            Text(
              appL10n.subscriptionActivated,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              appL10n.youAreNowSubscribedTo(plan.name),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // close dialog
              Navigator.of(context).pop(); // go back to previous screen
            },
            child: Text(context.l10n.continueWithApps),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSnackbar(String message, {Color color = Colors.black87}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _purchaseSubscription?.cancel();
    super.dispose();
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F0E8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          context.l10n.upgradeToPremium,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w500,
            fontSize: 18,
          ),
        ),
      ),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_controller.isError.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    _controller.errorMessage.value,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _controller.fetchPlans,
                  child: Text(context.l10n.retry),
                ),
              ],
            ),
          );
        }

        if (_controller.plans.isEmpty) {
          return Center(child: Text(context.l10n.noSubscriptionPlans));
        }

        final plans = uniqueProductPlans(_controller.plans);

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: plans.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final plan = plans[index];
            return Obx(() => _PlanCard(
              plan: plan,
              priceLabel: _priceLabelFor(plan),
              isSelected: _controller.selectedPlan.value == plan.id,
              onSelect: () => _controller.changePlan(plan.id),
              onSubscribe: () => _onSubscribePressed(plan),
            ));
          },
        );
      }),
    );
  }
}

// ─── Plan Card ────────────────────────────────────────────────────────────────

class _PlanCard extends StatelessWidget {
  final PlanModel plan;

  /// Already formatted — store price when known, backend price otherwise.
  final String priceLabel;
  final bool isSelected;
  final VoidCallback onSelect;
  final VoidCallback onSubscribe;

  const _PlanCard({
    required this.plan,
    required this.priceLabel,
    required this.isSelected,
    required this.onSelect,
    required this.onSubscribe,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelect,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: const Color(0xFFF0EBE0),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF1C3D2E) : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _getDurationLabel(plan.duration),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF1C3D2E)
                            : Colors.grey.shade400,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF1C3D2E),
                        ),
                      ),
                    )
                        : null,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Text(
                priceLabel,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1C3D2E),
                ),
              ),
              Text(
                'Price per ${_getDurationLabel(plan.duration).toLowerCase()}',
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),

              const Divider(height: 28),

              ..._getFeatures(plan).map(
                    (feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Color(0xFF1C3D2E),
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          feature,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onSubscribe,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1C3D2E),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    context.l10n.subscribeNow,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getDurationLabel(int duration) {
    if (duration <= 7) return 'Weekly';
    if (duration <= 31) return 'Monthly';
    if (duration <= 92) return 'Quarterly';
    return 'Yearly';
  }

  List<String> _getFeatures(PlanModel plan) {
    if (plan.price <= 10) {
      return [
        appL10n.planFeatureAdFree,
        appL10n.planFeatureStandardReports,
        appL10n.planFeatureEmailSupport,
      ];
    } else {
      return [
        appL10n.planFeatureEverythingInBasic,
        appL10n.planFeatureAdvancedAnalytics,
        appL10n.planFeaturePrioritySupport,
        appL10n.planFeatureUnlimitedAppLimits,
      ];
    }
  }
}




















//
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:limit_it_app/controllers/upgrade_premium_controller.dart';
// import 'package:limit_it_app/core/constants/app_colors.dart';
// import 'package:limit_it_app/core/helpers/localization_helper.dart';
// import 'package:limit_it_app/core/models/plan_model.dart';
// import 'package:limit_it_app/core/presentations/widgets/custom_button.dart';
// import 'package:limit_it_app/core/presentations/widgets/custom_text.dart';
// import 'package:limit_it_app/core/services/plan_service.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
//
//
// class UpgradePremiumScreen extends StatelessWidget {
//   const UpgradePremiumScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.find<UpgradePremiumController>();
//
//     return Scaffold(
//       appBar: _buildAppBar(context),
//       body: SafeArea(
//         child: Obx(() {
//           if (controller.isLoading.value) {
//             return _buildLoadingState();
//           } else if (controller.isError.value) {
//             return _buildErrorState(context, controller);
//           } else {
//             return _buildPlanList(context, controller);
//           }
//         }),
//       ),
//     );
//   }
//
//   Widget _buildLoadingState() {
//     return Center(
//       child: SpinKitFadingCircle(
//         color: AppColors.primaryGreen,
//         size: 40.r,
//       ),
//     );
//   }
//
//   Widget _buildErrorState(BuildContext context, UpgradePremiumController controller) {
//     return Center(
//       child: Padding(
//         padding: EdgeInsets.symmetric(horizontal: 24.w),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.error_outline,
//               color: Colors.red,
//               size: 60.r,
//             ),
//             SizedBox(height: 16.h),
//             CustomText(
//               text: 'Failed to load plans',
//               fontsize: 18.sp,
//               fontWeight: FontWeight.w600,
//               color: AppColors.textColor3D3D3D,
//               textAlign: TextAlign.center,
//             ),
//             SizedBox(height: 8.h),
//             CustomText(
//               text: controller.errorMessage.value,
//               fontsize: 14.sp,
//               fontWeight: FontWeight.w400,
//               color: Colors.grey,
//               textAlign: TextAlign.center,
//             ),
//             SizedBox(height: 24.h),
//             CustomButton(
//               title: 'Retry',
//               onpress: () => controller.fetchPlans(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildPlanList(BuildContext context, UpgradePremiumController controller) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 24.w),
//       child: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SizedBox(height: 16.h),
//             ...controller.plans.map((plan) => _buildPlanCard(context, controller, plan)),
//             SizedBox(height: 20.h),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildPlanCard(BuildContext context, UpgradePremiumController controller, PlanModel plan) {
//     final isSelected = controller.selectedPlan.value == plan.id;
//
//     return GestureDetector(
//       onTap: () => controller.changePlan(plan.id),
//       child: Container(
//         margin: EdgeInsets.only(bottom: 16.h),
//         padding: EdgeInsets.all(16.w),
//         decoration: BoxDecoration(
//           color: AppColors.backGroundColor,
//           borderRadius: BorderRadius.circular(12.r),
//           border: Border.all(
//             color: isSelected ? AppColors.primaryColor526E4B : Colors.grey.shade300,
//             width: isSelected ? 2 : 1,
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withValues(alpha: 0.05),
//               blurRadius: 10,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       CustomText(
//                         textAlign: TextAlign.start,
//                         text: plan.name,
//                         fontsize: 20.sp,
//                         fontWeight: FontWeight.w600,
//                         color: AppColors.textColor3D3D3D,
//                       ),
//                       SizedBox(height: 4.h),
//                       CustomText(
//                         textAlign: TextAlign.start,
//                         text: PlanService.getPlanDurationText(plan.duration),
//                         fontsize: 14.sp,
//                         fontWeight: FontWeight.w400,
//                         color: Colors.grey,
//                       ),
//                     ],
//                   ),
//                 ),
//                 Radio<String>(
//                   value: plan.id,
//                   groupValue: controller.selectedPlan.value,
//                   onChanged: (value) => controller.changePlan(value!),
//                   activeColor: AppColors.primaryColor526E4B,
//                 ),
//               ],
//             ),
//             SizedBox(height: 12.h),
//             CustomText(
//               textAlign: TextAlign.start,
//               text: PlanService.formatPrice(plan.price),
//               fontsize: 28.sp,
//               fontWeight: FontWeight.w700,
//               color: AppColors.primaryColor526E4B,
//             ),
//             SizedBox(height: 4.h),
//             CustomText(
//               textAlign: TextAlign.start,
//               text: 'Price per month • ${plan.limits.maxApps} apps',
//               fontsize: 12.sp,
//               fontWeight: FontWeight.w400,
//               color: Colors.grey,
//             ),
//             SizedBox(height: 16.h),
//             Divider(color: Colors.grey.shade300),
//             SizedBox(height: 12.h),
//             ...plan.benefits.map((benefit) => Padding(
//               padding: EdgeInsets.only(bottom: 8.h),
//               child: Row(
//                 children: [
//                   Icon(
//                     Icons.check_circle,
//                     color: AppColors.primaryGreen,
//                     size: 18.r,
//                   ),
//                   SizedBox(width: 8.w),
//                   Expanded(
//                     child: CustomText(
//                       textAlign: TextAlign.start,
//                       text: benefit,
//                       fontsize: 14.sp,
//                       fontWeight: FontWeight.w400,
//                       color: AppColors.textColor3D3D3D,
//                     ),
//                   ),
//                 ],
//               ),
//             )),
//             SizedBox(height: 16.h),
//             CustomButton(
//               title: context.l10n.subscribeNow,
//               onpress: () {},
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   AppBar _buildAppBar(BuildContext context) => AppBar(
//     forceMaterialTransparency: true,
//     backgroundColor: Colors.transparent,
//     elevation: 0,
//     automaticallyImplyLeading: false,
//     titleSpacing: 0,
//     title: Row(
//       children: [
//         IconButton(
//           padding: EdgeInsets.zero,
//           icon: Icon(Icons.arrow_back, color: Colors.black, size: 20.r),
//           onPressed: () => Navigator.pop(context),
//         ),
//         SizedBox(width: 12.w),
//         CustomText(
//           text: context.l10n.upgradeToPremium,
//           fontsize: 24.sp,
//           fontWeight: FontWeight.w500,
//           color: AppColors.textColor3D3D3D,
//         ),
//       ],
//     ),
//   );
// }
