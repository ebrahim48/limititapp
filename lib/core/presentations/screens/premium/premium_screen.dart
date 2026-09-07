import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:limit_it_app/controllers/premium_controller.dart';
import 'package:limit_it_app/core/config/app_routes/app_routes.dart';
import 'package:limit_it_app/core/helpers/localization_helper.dart';
import 'package:limit_it_app/global/custom_assets/assets.gen.dart';
import '../../widgets/ui/ui.dart';
import 'manage_subscription_screen.dart';

/// Premium tab — the paywall while on the free plan, the subscription
/// management view once subscribed.
class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final premium = Get.find<PremiumController>();
    return Obx(
      () => premium.isPremium.value
          ? const ManageSubscriptionScreen(embedded: true)
          : const _Paywall(),
    );
  }
}

class _Paywall extends StatelessWidget {
  const _Paywall();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppScaffold(
      appBar: AppTopBar(title: l10n.premium, showBack: false),
      bottomBar: AppButton(
        label: l10n.choosePlan,
        icon: AppIcon(Assets.icons.ui.crown, size: 18.w, color: AppColors.gold),
        onPressed: () => context.pushNamed(AppRoutes.choosePlanScreen),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(bottom: 110.h),
        children: [
          SizedBox(height: 8.h),
          Center(
            child: Container(
              width: 88.w,
              height: 88.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.warmSoft,
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: AppIcon(
                Assets.icons.ui.crown,
                size: 44.w,
                color: AppColors.gold,
              ),
            ),
          ),
          SizedBox(height: 20.h),

          Text(
            l10n.limitItPremium,
            textAlign: TextAlign.center,
            style: AppTextStyles.h1(),
          ),
          SizedBox(height: 10.h),
          Text(
            l10n.premiumSubtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.body(color: AppColors.slateGreen),
          ),

          SizedBox(height: 28.h),

          AppCardList(
            children: [
              _FeatureRow(
                icon: Assets.icons.ui.shieldLock,
                title: l10n.premiumFeatureUnlimitedTitle,
                subtitle: l10n.premiumFeatureUnlimitedSubtitle,
              ),
              _FeatureRow(
                icon: Assets.icons.ui.barChart,
                title: l10n.premiumFeatureStatsTitle,
                subtitle: l10n.premiumFeatureStatsSubtitle,
              ),
              _FeatureRow(
                icon: Assets.icons.ui.moon,
                title: l10n.premiumFeatureScheduleTitle,
                subtitle: l10n.premiumFeatureScheduleSubtitle,
              ),
              _FeatureRow(
                icon: Assets.icons.ui.cloudUpload,
                title: l10n.premiumFeatureBackupTitle,
                subtitle: l10n.premiumFeatureBackupSubtitle,
              ),
              _FeatureRow(
                icon: Assets.icons.ui.xCircleOutline,
                title: l10n.premiumFeatureNoAdsTitle,
                subtitle: l10n.premiumFeatureNoAdsSubtitle,
              ),
            ],
          ),

          SizedBox(height: 16.h),

          Center(
            child: AppTextLink(
              label: l10n.restorePurchases,
              onPressed: () => context.pushNamed(AppRoutes.choosePlanScreen),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final SvgGenImage icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return AppListRow(
      showChevron: false,
      leading: AppIconBox(
        child: AppIcon(icon, size: 18.w, color: AppColors.fern),
      ),
      title: title,
      subtitle: subtitle,
      trailing: Icon(
        Icons.check_circle_rounded,
        size: 20.sp,
        color: AppColors.leafGreen,
      ),
    );
  }
}
