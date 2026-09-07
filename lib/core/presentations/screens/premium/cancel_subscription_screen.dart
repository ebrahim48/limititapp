import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:limit_it_app/controllers/premium_controller.dart';
import 'package:limit_it_app/core/config/app_routes/app_routes.dart';
import 'package:limit_it_app/core/helpers/localization_helper.dart';
import '../../widgets/ui/ui.dart';

/// Confirmation step before cancelling — spells out what is lost.
class CancelSubscriptionScreen extends StatefulWidget {
  const CancelSubscriptionScreen({super.key});

  @override
  State<CancelSubscriptionScreen> createState() =>
      _CancelSubscriptionScreenState();
}

class _CancelSubscriptionScreenState extends State<CancelSubscriptionScreen> {
  final PremiumController _premium = Get.find<PremiumController>();
  bool _isCancelling = false;

  Future<void> _cancel() async {
    setState(() => _isCancelling = true);
    await _premium.deactivate();
    if (!mounted) return;
    setState(() => _isCancelling = false);
    context.pushReplacementNamed(AppRoutes.subscriptionCancelledScreen);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final renewal = _premium.renewalDate;
    final renewalLabel = renewal == null
        ? null
        : DateFormat.yMMMMd(Localizations.localeOf(context).toString())
            .format(renewal);

    return AppScaffold(
      appBar: AppTopBar(title: l10n.cancelSubscription),
      bottomBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppButton(
            label: l10n.yesCancelSubscription,
            variant: AppButtonVariant.destructive,
            loading: _isCancelling,
            onPressed: _cancel,
          ),
          SizedBox(height: 10.h),
          AppButton(
            label: l10n.keepMyPlan,
            variant: AppButtonVariant.outline,
            onPressed: () => context.pop(),
          ),
        ],
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(bottom: 160.h),
        children: [
          SizedBox(height: 8.h),
          Text(l10n.youllLoseAccessTo, style: AppTextStyles.h3()),
          SizedBox(height: 16.h),

          AppCardList(
            children: [
              _LostFeature(label: l10n.lockedFeatureTimeSaved),
              _LostFeature(label: l10n.lockedFeatureTrends),
              _LostFeature(label: l10n.lockedFeatureGoals),
              _LostFeature(label: l10n.lockedFeatureReports),
              _LostFeature(label: l10n.premiumFeatureNoAdsTitle),
            ],
          ),

          SizedBox(height: 16.h),

          AppSoftCard(
            color: AppColors.alertRedSoft,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 18.sp, color: AppColors.alertRed),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    renewalLabel == null
                        ? l10n.cancelKeepsAccess
                        : l10n.cancelKeepsAccessUntil(renewalLabel),
                    style: AppTextStyles.small(color: AppColors.alertRed),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 12.h),

          Text(
            l10n.cancelStoreNote,
            style: AppTextStyles.caption(color: AppColors.mist),
          ),
        ],
      ),
    );
  }
}

class _LostFeature extends StatelessWidget {
  const _LostFeature({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return AppListRow(
      showChevron: false,
      title: label,
      leading: Icon(
        Icons.remove_circle_outline_rounded,
        size: 20.sp,
        color: AppColors.alertRed,
      ),
    );
  }
}
