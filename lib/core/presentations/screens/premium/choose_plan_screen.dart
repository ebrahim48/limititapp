import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:limit_it_app/controllers/premium_controller.dart';
import 'package:limit_it_app/controllers/upgrade_premium_controller.dart';
import 'package:limit_it_app/core/config/app_routes/app_routes.dart';
import 'package:limit_it_app/core/constants/iap_products.dart';
import 'package:limit_it_app/core/helpers/localization_helper.dart';
import 'package:limit_it_app/core/models/plan_model.dart';
import 'package:limit_it_app/core/services/api_client.dart';
import 'package:limit_it_app/core/services/api_constants.dart';
import '../../widgets/ui/ui.dart';

/// Plan picker + purchase. Plans come from `/plans`, payment goes through
/// In-App Purchase, and `/subscriptions/subscribe` activates it server-side.
class ChoosePlanScreen extends StatefulWidget {
  const ChoosePlanScreen({super.key});

  @override
  State<ChoosePlanScreen> createState() => _ChoosePlanScreenState();
}

class _ChoosePlanScreenState extends State<ChoosePlanScreen> {
  late final UpgradePremiumController _controller;
  final PremiumController _premium = Get.find<PremiumController>();

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;
  bool _iapAvailable = false;
  Map<String, ProductDetails> _iapProducts = {};

  PlanModel? _pendingPlan;

  /// Index into [_cycles].
  int _cycleIndex = 1;
  String _selectedPlanId = '';
  bool _isSubscribing = false;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<UpgradePremiumController>();
    _initIAP();

    ever(_controller.plans, (_) {
      if (_controller.plans.isNotEmpty && _iapAvailable) {
        _loadIAPProducts();
      }
    });
  }

  @override
  void dispose() {
    _purchaseSubscription?.cancel();
    super.dispose();
  }

  // ── In-App Purchase ──────────────────────────────────────────────────────

  Future<void> _initIAP() async {
    final available = await _iap.isAvailable();
    if (!available) {
      debugPrint('====> IAP not available on this device');
      if (mounted) setState(() => _iapAvailable = false);
      return;
    }

    if (mounted) setState(() => _iapAvailable = true);

    _purchaseSubscription = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () => _purchaseSubscription?.cancel(),
      onError: (error) {
        debugPrint('====> IAP stream error: $error');
        _showError(appL10n.purchaseError('$error'));
      },
    );

    await _loadIAPProducts();
    await _iap.restorePurchases();
  }

  Future<void> _loadIAPProducts() async {
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

    if (!mounted) return;
    setState(() {
      _iapProducts = {for (final p in response.productDetails) p.id: p};
    });
    debugPrint('====> IAP products loaded: ${_iapProducts.keys.toList()}');
    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('====> IAP products missing from store: ${response.notFoundIDs}');
    }
  }

  /// Store product backing [plan], or null when it is not purchasable.
  ProductDetails? _productFor(PlanModel plan) {
    final id = resolveProductId(plan, _controller.plans);
    if (id == null) return null;
    return _iapProducts[id];
  }

  Future<void> _onSubscribePressed(PlanModel plan) async {
    // Premium is only ever granted after a real store purchase — no mock
    // fallback, otherwise the app would hand out a paid plan for free.
    if (!_iapAvailable) {
      debugPrint('====> IAP not available on this device');
      _showError(appL10n.storeUnavailable);
      return;
    }

    final product = _productFor(plan);

    if (product == null) {
      debugPrint(
          '====> No purchasable product for plan "${plan.name}" (${productIdFor(plan)})');
      _showError(appL10n.planNotAvailable);
      return;
    }

    _pendingPlan = plan;

    final purchaseParam = PurchaseParam(productDetails: product);

    try {
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      _pendingPlan = null;
      debugPrint('====> IAP buy error: $e');
      _showError(appL10n.couldNotStartPurchase('$e'));
    }
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final purchase in purchaseDetailsList) {
      debugPrint(
          '====> Purchase update: ${purchase.productID} — ${purchase.status}');

      switch (purchase.status) {
        case PurchaseStatus.pending:
          _showMessage(context.l10n.paymentPending);
          break;

        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _handleSuccessfulPurchase(purchase);
          break;

        case PurchaseStatus.error:
          _pendingPlan = null;
          debugPrint(
              '====> IAP error: ${purchase.error?.code} — ${purchase.error?.message}');
          _showError(appL10n.purchaseFailed('${purchase.error?.message}'));
          break;

        case PurchaseStatus.canceled:
          _pendingPlan = null;
          _showMessage(context.l10n.purchaseCancelled);
          break;
      }

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

    final paymentId = purchase.purchaseID ??
        'iap_${purchase.productID}_${DateTime.now().millisecondsSinceEpoch}';

    debugPrint(
        '====> IAP purchase successful, calling backend with paymentId: $paymentId');
    await _callBackendSubscribe(plan: plan, paymentId: paymentId);
  }

  // ── Backend ──────────────────────────────────────────────────────────────

  Future<void> _callBackendSubscribe({
    required PlanModel plan,
    required String paymentId,
  }) async {
    if (mounted) setState(() => _isSubscribing = true);

    try {
      final response = await ApiClient.postData(
        ApiConstants.subscribeEndPoint,
        jsonEncode({'planId': plan.id, 'paymentId': paymentId}),
      );

      if (response.statusCode == 201 && response.body != null) {
        final data = response.body as Map<String, dynamic>;

        if (data['status'] == 'success' && data['statusCode'] == 201) {
          await _premium.activate(
            name: plan.name,
            price: '€${plan.price.toStringAsFixed(2)}',
            renewal: DateTime.now().add(Duration(days: plan.duration)),
          );
          if (!mounted) return;
          context.pushReplacementNamed(AppRoutes.premiumSuccessScreen);
          return;
        }
        _showError(data['message'] ?? appL10n.subscriptionFailed);
      } else {
        _showError(appL10n.serverErrorWithMessage('${response.statusText}'));
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isSubscribing = false);
    }
  }

  // ── Feedback ─────────────────────────────────────────────────────────────

  void _showError(String message) => _showMessage(message, isError: true);

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: AppTextStyles.small(color: AppColors.white)),
        backgroundColor: isError ? AppColors.alertRed : AppColors.forestGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── UI ───────────────────────────────────────────────────────────────────

  /// Billing cycles shown as tabs, in the order they appear.
  static const List<String> _cycles = ['weekly', 'monthly', 'yearly'];

  /// Plans belonging to the selected billing cycle. Empty when the backend has
  /// no plan for that cycle — the tab then shows an empty state rather than
  /// silently falling back to plans from another cycle.
  List<PlanModel> _plansForCycle(List<PlanModel> plans) {
    final cycle = _cycles[_cycleIndex];
    return plans.where((p) => billingCycleOf(p) == cycle).toList();
  }

  /// Yearly saving vs. paying monthly for a year, e.g. "Save 33%".
  String? _yearlySavingBadge(List<PlanModel> plans) {
    final monthly = plans.where((p) => p.duration >= 28 && p.duration < 365);
    final yearly = plans.where((p) => p.duration >= 365);
    if (monthly.isEmpty || yearly.isEmpty) return null;

    final monthlyYearCost = monthly.first.price * 12;
    if (monthlyYearCost <= 0) return null;

    final saving =
        ((monthlyYearCost - yearly.first.price) / monthlyYearCost) * 100;
    if (saving <= 0) return null;
    return '${context.l10n.save} ${saving.round()}%';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppScaffold(
      appBar: AppTopBar(title: l10n.choosePlan),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.leafGreen),
          );
        }

        if (_controller.isError.value || _controller.plans.isEmpty) {
          return AppMessageView(
            title: l10n.failedToLoadPlans,
            description: _controller.errorMessage.value,
            action: AppButton(
              label: l10n.retry,
              onPressed: _controller.fetchPlans,
            ),
          );
        }

        final allPlans = _controller.plans.toList();
        final plans = _plansForCycle(allPlans);
        final badge = _yearlySavingBadge(allPlans);

        if (_selectedPlanId.isEmpty ||
            !plans.any((p) => p.id == _selectedPlanId)) {
          _selectedPlanId = plans.isEmpty ? '' : plans.first.id;
        }

        final selected = plans.isEmpty
            ? null
            : plans.firstWhere((p) => p.id == _selectedPlanId,
                orElse: () => plans.first);

        return Column(
          children: [
            AppSegmentedTabs(
              segments: [l10n.weekly, l10n.monthly, l10n.yearly],
              trailingBadges: [null, null, badge],
              selectedIndex: _cycleIndex,
              onChanged: (i) => setState(() {
                _cycleIndex = i;
                _selectedPlanId = '';
              }),
            ),
            SizedBox(height: 20.h),

            Expanded(
              child: plans.isEmpty
                  ? AppMessageView(title: l10n.noPlansAvailable)
                  : ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.only(bottom: 16.h),
                      children: [
                        for (final plan in plans) ...[
                          _PlanCard(
                            plan: plan,
                            selected: plan.id == _selectedPlanId,
                            onTap: () =>
                                setState(() => _selectedPlanId = plan.id),
                          ),
                          SizedBox(height: 12.h),
                        ],
                      ],
                    ),
            ),

            AppButton(
              label: l10n.subscribeNow,
              loading: _isSubscribing,
              onPressed:
                  selected == null ? null : () => _onSubscribePressed(selected),
            ),
            SizedBox(height: 8.h),
            AppTextLink(
              label: l10n.restorePurchases,
              onPressed: () async {
                await _iap.restorePurchases();
                _showMessage(l10n.checkingPurchases);
              },
            ),
            SizedBox(height: 12.h),
          ],
        );
      }),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.selected,
    required this.onTap,
  });

  final PlanModel plan;
  final bool selected;
  final VoidCallback onTap;

  String _period(BuildContext context) {
    final l10n = context.l10n;
    if (plan.duration >= 365) return l10n.perYear;
    if (plan.duration >= 28) return l10n.perMonth;
    return l10n.perWeek;
  }

  @override
  Widget build(BuildContext context) {
    return AppSelectableTile(
      selected: selected,
      onTap: onTap,
      // The card draws its own check next to the plan name.
      showCheck: false,
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(child: Text(plan.name, style: AppTextStyles.h3())),
              if (selected)
                Icon(Icons.check_circle_rounded,
                    size: 22.sp, color: AppColors.leafGreen),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '€${plan.price.toStringAsFixed(2)}',
                style: AppTextStyles.display(color: AppColors.forestGreen),
              ),
              SizedBox(width: 6.w),
              Text(
                _period(context),
                style: AppTextStyles.body(color: AppColors.slateGreen),
              ),
            ],
          ),
          if (plan.benefits.isNotEmpty) ...[
            SizedBox(height: 12.h),
            for (final benefit in plan.benefits)
              Padding(
                padding: EdgeInsets.only(bottom: 6.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_rounded,
                        size: 16.sp, color: AppColors.leafGreen),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        benefit,
                        style:
                            AppTextStyles.small(color: AppColors.slateGreen),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}
