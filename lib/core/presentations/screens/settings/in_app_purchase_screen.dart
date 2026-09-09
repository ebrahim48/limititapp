import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:limit_it_app/controllers/upgrade_premium_controller.dart';
import 'package:limit_it_app/core/constants/app_colors.dart';
import 'package:limit_it_app/core/constants/iap_products.dart';
import 'package:limit_it_app/core/helpers/localization_helper.dart';
import 'package:limit_it_app/core/models/plan_model.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_button.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_text.dart';
import 'package:limit_it_app/core/services/api_client.dart';
import 'package:limit_it_app/core/services/api_constants.dart';

// Product IDs live in core/constants/iap_products.dart so this screen,
// upgrade_premium.dart and choose_plan_screen.dart cannot drift apart.

// ─── Screen ───────────────────────────────────────────────────────────────────

class InAppPurchaseSubscriptionScreen extends StatefulWidget {
  const InAppPurchaseSubscriptionScreen({super.key});

  @override
  State<InAppPurchaseSubscriptionScreen> createState() =>
      _InAppPurchaseSubscriptionScreenState();
}

class _InAppPurchaseSubscriptionScreenState
    extends State<InAppPurchaseSubscriptionScreen> {
  // ── Controllers ────────────────────────────────────────────────────────────
  late final UpgradePremiumController _planController;

  // ── IAP ────────────────────────────────────────────────────────────────────
  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;
  bool _iapAvailable = false;
  Map<String, ProductDetails> _iapProducts = {};

  // ── Local state ────────────────────────────────────────────────────────────
  PlanModel? _pendingPlan;
  bool _isPurchasing = false;

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _planController = Get.find<UpgradePremiumController>();
    _initIAP();

    // When plans load from API, query the matching Play Store products
    ever(_planController.plans, (_) {
      if (_planController.plans.isNotEmpty && _iapAvailable) {
        _queryIAPProducts();
      }
    });
  }

  @override
  void dispose() {
    _purchaseSub?.cancel();
    super.dispose();
  }

  // ── IAP Initialization ─────────────────────────────────────────────────────

  Future<void> _initIAP() async {
    final available = await _iap.isAvailable();
    if (!mounted) return;

    setState(() => _iapAvailable = available);

    if (!available) {
      debugPrint('====> [IAP] Store not available on this device');
      return;
    }

    // Listen to purchase updates from Google Play
    _purchaseSub = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () => _purchaseSub?.cancel(),
      onError: (e) {
        debugPrint('====> [IAP] Stream error: $e');
        _showError(appL10n.purchaseError('$e'));
      },
    );

    // Silently restore any existing purchases on launch
    await _iap.restorePurchases();

    // If plans are already loaded, query Play Store products now
    if (_planController.plans.isNotEmpty) {
      await _queryIAPProducts();
    }
  }

  Future<void> _queryIAPProducts() async {
    final ids = <String>{};
    for (final plan in _planController.plans) {
      final productId = productIdFor(plan);
      if (productId != null) ids.add(productId);
    }
    if (ids.isEmpty) return;

    debugPrint('====> [IAP] Querying Play Store products: $ids');
    final response = await _iap.queryProductDetails(ids);

    if (!mounted) return;

    if (response.error != null) {
      debugPrint('====> [IAP] Query error: ${response.error!.message}');
      return;
    }

    setState(() {
      _iapProducts = {for (final p in response.productDetails) p.id: p};
    });
    debugPrint('====> [IAP] Products loaded: ${_iapProducts.keys.toList()}');
  }

  // ── Purchase Flow ──────────────────────────────────────────────────────────

  Future<void> _subscribe(PlanModel plan) async {
    if (_isPurchasing) return;

    // Premium is only ever granted after a real store purchase — no mock
    // fallback, otherwise the app would hand out a paid plan for free.
    if (!_iapAvailable) {
      debugPrint('====> [IAP] Store unavailable');
      _showError(appL10n.storeUnavailable);
      return;
    }

    final productId = resolveProductId(plan, _planController.plans);
    final product = productId == null ? null : _iapProducts[productId];

    if (product == null) {
      debugPrint('====> [IAP] No purchasable product for plan "${plan.name}"');
      _showError(appL10n.planNotAvailable);
      return;
    }

    setState(() {
      _pendingPlan = plan;
      _isPurchasing = true;
    });

    try {
      await _iap.buyNonConsumable(
        purchaseParam: PurchaseParam(productDetails: product),
      );
      // Result comes back asynchronously via _onPurchaseUpdate
    } catch (e) {
      setState(() {
        _pendingPlan = null;
        _isPurchasing = false;
      });
      debugPrint('====> [IAP] Buy error: $e');
      _showError(appL10n.couldNotStartPurchaseRetry);
    }
  }

  void _onPurchaseUpdate(List<PurchaseDetails> updates) {
    for (final purchase in updates) {
      debugPrint(
          '====> [IAP] Update: ${purchase.productID} — ${purchase.status}');

      switch (purchase.status) {
        case PurchaseStatus.pending:
          // Loading spinner is already shown; nothing else needed
          break;

        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _handleSuccessfulPurchase(purchase);
          break;

        case PurchaseStatus.error:
          setState(() {
            _pendingPlan = null;
            _isPurchasing = false;
          });
          _showError(
              'Purchase failed: ${purchase.error?.message ?? 'Unknown error'}');
          break;

        case PurchaseStatus.canceled:
          setState(() {
            _pendingPlan = null;
            _isPurchasing = false;
          });
          break;
      }

      // Always acknowledge the purchase to prevent re-delivery
      if (purchase.pendingCompletePurchase) {
        _iap.completePurchase(purchase);
      }
    }
  }

  Future<void> _handleSuccessfulPurchase(PurchaseDetails purchase) async {
    final plan = _pendingPlan;
    setState(() {
      _pendingPlan = null;
      _isPurchasing = false;
    });

    if (plan == null) {
      debugPrint('====> [IAP] Purchase received but no pending plan stored');
      return;
    }

    final paymentId = purchase.purchaseID ??
        'iap_${purchase.productID}_${DateTime.now().millisecondsSinceEpoch}';

    debugPrint(
        '====> [IAP] Purchase successful — calling backend with paymentId: $paymentId');
    await _callBackend(plan: plan, paymentId: paymentId);
  }

  // ── Backend Call ───────────────────────────────────────────────────────────

  Future<void> _callBackend({
    required PlanModel plan,
    required String paymentId,
  }) async {
    if (!mounted) return;

    // Show activating dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r)),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 28.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SpinKitFadingCircle(
                  color: AppColors.primaryGreen, size: 48.r),
              SizedBox(height: 16.h),
              CustomText(
                text: context.l10n.activatingSubscription,
                fontsize: 15.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textColor2C2C2C,
              ),
            ],
          ),
        ),
      ),
    );

    try {
      final response = await ApiClient.postData(
        ApiConstants.subscribeEndPoint,
        jsonEncode({'planId': plan.id, 'paymentId': paymentId}),
      );

      if (mounted) Navigator.of(context).pop(); // close loading dialog

      if (response.statusCode == 201 && response.body != null) {
        final data = response.body as Map<String, dynamic>;
        if (data['status'] == 'success' && data['statusCode'] == 201) {
          _showSuccessDialog(plan);
        } else {
          _showError(data['message'] ?? appL10n.subscriptionActivationFailed);
        }
      } else {
        _showError(appL10n.serverErrorWithMessage('${response.statusText}'));
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      _showError(e.toString());
    }
  }

  // ── Dialogs & Feedback ─────────────────────────────────────────────────────

  void _showSuccessDialog(PlanModel plan) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r)),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 32.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72.r,
                height: 72.r,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: AppColors.primaryGreen,
                  size: 40.r,
                ),
              ),
              SizedBox(height: 20.h),
              CustomText(
                text: context.l10n.subscriptionActivated,
                fontsize: 20.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textColor2C2C2C,
              ),
              SizedBox(height: 8.h),
              CustomText(
                text: context.l10n.youAreNowSubscribedTo(plan.name),
                fontsize: 14.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textColor5D5D5D,
                maxline: 2,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 28.h),
              CustomButton(
                title: context.l10n.continueWithApps,
                height: 50.h,
                onpress: () {
                  Navigator.of(context).pop(); // close dialog
                  Navigator.of(context).pop(); // go back to previous screen
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r)),
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      ),
    );
  }

  Future<void> _restorePurchases() async {
    try {
      await _iap.restorePurchases();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.checkingForExistingPurchases),
            backgroundColor: AppColors.primaryGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r)),
            margin:
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          ),
        );
      }
    } catch (e) {
      _showError(appL10n.restoreFailed('$e'));
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      appBar: _buildAppBar(),
      body: Obx(() => _buildBody()),
    );
  }

  AppBar _buildAppBar() => AppBar(
        forceMaterialTransparency: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            IconButton(
              padding: EdgeInsets.only(left: 12.w),
              icon: Icon(Icons.arrow_back,
                  color: AppColors.textColor2C2C2C, size: 22.r),
              onPressed: () => Navigator.pop(context),
            ),
            SizedBox(width: 6.w),
            CustomText(
              text: context.l10n.choosePlan,
              fontsize: 20.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textColor2C2C2C,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _restorePurchases,
            child: CustomText(
              text: context.l10n.restore,
              fontsize: 13.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryGreen,
            ),
          ),
        ],
      );

  Widget _buildBody() {
    // Loading
    if (_planController.isLoading.value) {
      return Center(
        child: SpinKitFadingCircle(
            color: AppColors.primaryGreen, size: 48.r),
      );
    }

    // Error
    if (_planController.isError.value) {
      return _buildErrorState();
    }

    // Empty
    if (_planController.plans.isEmpty) {
      return Center(
        child: CustomText(
          text: context.l10n.noSubscriptionPlans,
          fontsize: 15.sp,
          color: AppColors.textColor5D5D5D,
        ),
      );
    }

    // Plans list
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          children: [
            SizedBox(height: 16.h),
            _buildHeader(),
            SizedBox(height: 24.h),
            ..._planController.plans
                .map((plan) => _buildPlanCard(plan))
                .toList(),
            SizedBox(height: 12.h),
            _buildFooter(),
            SizedBox(height: 36.h),
          ],
        ),
      ),
    );
  }

  // ── Header banner ──────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Container(
            width: 56.r,
            height: 56.r,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.workspace_premium_rounded,
              color: const Color(0xFFEDD69A),
              size: 32.r,
            ),
          ),
          SizedBox(height: 12.h),
          CustomText(
            text: context.l10n.upgradeToPremium,
            fontsize: 20.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
          SizedBox(height: 6.h),
          CustomText(
            text: context.l10n.takeFullControlOfScreenTime,
            fontsize: 13.sp,
            fontWeight: FontWeight.w400,
            color: Colors.white.withValues(alpha: 0.75),
          ),
        ],
      ),
    );
  }

  // ── Plan Card ──────────────────────────────────────────────────────────────

  Widget _buildPlanCard(PlanModel plan) {
    final isSelected = _planController.selectedPlan.value == plan.id;
    final productId = productIdFor(plan);
    final iapProduct = productId == null ? null : _iapProducts[productId];

    // Use Play Store price if available, else fall back to API price
    final priceLabel =
        iapProduct?.price ?? '\$${plan.price.toStringAsFixed(2)}';

    final periodLabel = _getPeriodLabel(context, plan);
    final isPopular =
        plan.type == 'monthly' || (plan.duration >= 28 && plan.duration < 90);
    final isThisPurchasing = _isPurchasing && _pendingPlan?.id == plan.id;

    return GestureDetector(
      onTap: () => _planController.changePlan(plan.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryColor
                : AppColors.borderColorD1D1D1,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // "Most Popular" badge
            if (isPopular)
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(14.r),
                    topRight: Radius.circular(14.r),
                  ),
                ),
                child: CustomText(
                  text: context.l10n.mostPopular,
                  fontsize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),

            Padding(
              padding: EdgeInsets.all(18.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title row + radio
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            textAlign: TextAlign.start,
                            text: plan.name,
                            fontsize: 17.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textColor2C2C2C,
                          ),
                          SizedBox(height: 4.h),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 3.h),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: CustomText(
                              text: periodLabel,
                              fontsize: 11.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ],
                      ),

                      // Radio indicator
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 22.r,
                        height: 22.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primaryColor
                                : AppColors.borderColorD1D1D1,
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? Center(
                                child: Container(
                                  width: 11.r,
                                  height: 11.r,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              )
                            : null,
                      ),
                    ],
                  ),

                  SizedBox(height: 16.h),

                  // Price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      CustomText(
                        textAlign: TextAlign.start,
                        text: priceLabel,
                        fontsize: 26.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryColor,
                      ),
                      SizedBox(width: 4.w),
                      Padding(
                        padding: EdgeInsets.only(bottom: 3.h),
                        child: CustomText(
                          textAlign: TextAlign.start,
                          text: '/ ${periodLabel.toLowerCase()}',
                          fontsize: 12.sp,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textColor5D5D5D,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 14.h),
                  Divider(color: AppColors.borderColorD1D1D1, height: 1),
                  SizedBox(height: 14.h),

                  // Benefits from API
                  if (plan.benefits.isNotEmpty)
                    ...plan.benefits.map(
                      (benefit) => Padding(
                        padding: EdgeInsets.only(bottom: 8.h),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.primaryGreen,
                              size: 17.r,
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: CustomText(
                                textAlign: TextAlign.start,
                                text: benefit,
                                fontsize: 13.sp,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textColor3D3D3D,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  SizedBox(height: 18.h),

                  // Subscribe button
                  CustomButton(
                    title:
                        isThisPurchasing ? context.l10n.processing : context.l10n.subscribeNow,
                    onpress: () => _subscribe(plan),
                    loading: isThisPurchasing,
                    height: 50.h,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Footer ─────────────────────────────────────────────────────────────────

  Widget _buildFooter() {
    return Column(
      children: [
        GestureDetector(
          onTap: _restorePurchases,
          child: CustomText(
            text: context.l10n.restorePurchases,
            fontsize: 13.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.primaryGreen,
          ),
        ),
        SizedBox(height: 10.h),
        CustomText(
          text:
              context.l10n.subscriptionAutoRenewNote,
          fontsize: 11.sp,
          fontWeight: FontWeight.w400,
          color: AppColors.textColor888888,
          maxline: 3,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ── Error State ────────────────────────────────────────────────────────────

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 28.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded,
                color: Colors.red.shade400, size: 56.r),
            SizedBox(height: 16.h),
            CustomText(
              text: _planController.errorMessage.value,
              fontsize: 14.sp,
              color: AppColors.textColor5D5D5D,
              maxline: 3,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            CustomButton(
              title: context.l10n.retry,
              onpress: _planController.fetchPlans,
              width: 140.w,
              height: 48.h,
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _getPeriodLabel(BuildContext context, PlanModel plan) {
    final l10n = context.l10n;
    if (plan.type == 'yearly' || plan.duration >= 365) return l10n.yearly;
    if (plan.type == 'monthly' || plan.duration >= 28) return l10n.monthly;
    if (plan.duration >= 7) return l10n.weekly;
    return l10n.monthly;
  }
}
