import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:limit_it_app/core/config/app_routes/app_routes.dart';
import 'package:limit_it_app/core/helpers/localization_helper.dart';
import 'package:limit_it_app/global/custom_assets/assets.gen.dart';
import '../../widgets/ui/ui.dart';

/// Closing step of the add-protection wizard.
class ProtectionSuccessScreen extends StatelessWidget {
  const ProtectionSuccessScreen({super.key, required this.appName});

  final String appName;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppScaffold(
      appBar: const AppTopBar(showBack: false),
      body: Center(
        child: AppMessageView(
          illustration:
              Assets.illustrations.shieldCheck.svg(width: 96.w, height: 96.w),
          title: l10n.appIsNowProtected(appName),
          description: l10n.smallPauseBigChange,
          extra: Text(
            l10n.oneStepCloserToBetterHabits,
            textAlign: TextAlign.center,
            style: AppTextStyles.small(color: AppColors.mist),
          ),
        ),
      ),
      bottomBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppButton(label: l10n.done, onPressed: () => _goHome(context)),
          SizedBox(height: 12.h),
          AppButton(
            label: l10n.addAnother,
            variant: AppButtonVariant.outline,
            onPressed: () {
              // Reset to Home first, so Back from the chooser lands on the tab
              // rather than walking back through the finished wizard.
              _goHome(context);
              context.pushNamed(AppRoutes.chooseFunctionScreen);
            },
          ),
        ],
      ),
    );
  }

  void _goHome(BuildContext context) =>
      context.goNamed(AppRoutes.bottomNavBarScreen);
}
