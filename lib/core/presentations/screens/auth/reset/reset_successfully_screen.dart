import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:limit_it_app/core/config/app_routes/app_routes.dart';
import 'package:limit_it_app/core/helpers/localization_helper.dart';
import 'package:limit_it_app/core/presentations/widgets/ui/ui.dart';
import 'package:limit_it_app/global/custom_assets/assets.gen.dart';

class ResetSuccessFullyScreen extends StatelessWidget {
  const ResetSuccessFullyScreen({super.key});

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
          title: l10n.allSetPasswordUpdated,
          description: l10n.resetSuccessSubtitle,
          action: AppButton(
            label: l10n.backToLogin,
            onPressed: () => context.goNamed(AppRoutes.logInScreen),
          ),
        ),
      ),
    );
  }
}
