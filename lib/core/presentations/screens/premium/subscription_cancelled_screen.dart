import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:limit_it_app/core/config/app_routes/app_routes.dart';
import 'package:limit_it_app/core/helpers/localization_helper.dart';
import 'package:limit_it_app/global/custom_assets/assets.gen.dart';
import '../../widgets/ui/ui.dart';

/// Final state after a cancellation.
class SubscriptionCancelledScreen extends StatelessWidget {
  const SubscriptionCancelledScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppScaffold(
      bottomBar: AppButton(
        label: l10n.goToHome,
        onPressed: () => context.goNamed(AppRoutes.bottomNavBarScreen),
      ),
      body: AppMessageView(
        illustration: Assets.illustrations.alertCircle.svg(
          width: 96.w,
          height: 96.w,
        ),
        title: l10n.subscriptionCancelled,
        description: l10n.subscriptionCancelledSubtitle,
        extra: Text(
          l10n.youCanResubscribeAnytime,
          textAlign: TextAlign.center,
          style: AppTextStyles.small(color: AppColors.mist),
        ),
      ),
    );
  }
}
