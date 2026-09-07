import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:limit_it_app/core/config/app_routes/app_routes.dart';
import 'package:limit_it_app/core/helpers/localization_helper.dart';
import 'package:limit_it_app/global/custom_assets/assets.gen.dart';
import '../../widgets/ui/ui.dart';

/// Shown after the backend confirms an activated subscription.
class PremiumSuccessScreen extends StatelessWidget {
  const PremiumSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppScaffold(
      body: Padding(
        padding: EdgeInsets.only(bottom: 24.h),
        child: AppMessageView(
          illustration: Assets.illustrations.checkCircle.svg(
            width: 120.w,
            height: 120.w,
          ),
          title: l10n.youreAllSet,
          description: l10n.youreAllSetSubtitle,
          extra: AppBadge.premium(
            label: l10n.premium,
            icon: AppIcon(
              Assets.icons.ui.crown,
              size: 14.w,
              color: AppColors.warmText,
            ),
          ),
          action: AppButton(
            label: l10n.startUsingPremium,
            onPressed: () => context.goNamed(AppRoutes.bottomNavBarScreen),
          ),
        ),
      ),
    );
  }
}
