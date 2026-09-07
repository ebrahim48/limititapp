import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:limit_it_app/core/app_constants/app_constants.dart';
import 'package:limit_it_app/core/config/app_routes/app_routes.dart';
import 'package:limit_it_app/core/helpers/localization_helper.dart';
import 'package:limit_it_app/core/helpers/prefs_helper.dart';
import 'package:limit_it_app/global/custom_assets/assets.gen.dart';
import '../../widgets/ui/ui.dart';

/// Log-out confirmation. Clears the session keys, leaves protections and
/// history on the device.
class LogoutScreen extends StatefulWidget {
  const LogoutScreen({super.key});

  @override
  State<LogoutScreen> createState() => _LogoutScreenState();
}

class _LogoutScreenState extends State<LogoutScreen> {
  bool _isLoggingOut = false;

  Future<void> _logout() async {
    setState(() => _isLoggingOut = true);

    await PrefsHelper.remove(AppConstants.bearerToken);
    await PrefsHelper.remove(AppConstants.userId);
    await PrefsHelper.remove(AppConstants.isLogged);

    if (!mounted) return;
    context.goNamed(AppRoutes.logInScreen);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppScaffold(
      appBar: const AppTopBar(),
      body: Padding(
        padding: EdgeInsets.only(bottom: 24.h),
        child: AppMessageView(
          illustration: Assets.illustrations.logoutCircle.svg(
            width: 96.w,
            height: 96.w,
          ),
          title: l10n.logOutOfLimitIt,
          description: l10n.logOutSubtitle,
          action: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppButton(
                label: l10n.yesLogOut,
                variant: AppButtonVariant.destructive,
                loading: _isLoggingOut,
                onPressed: _logout,
              ),
              SizedBox(height: 10.h),
              AppButton(
                label: l10n.cancel,
                variant: AppButtonVariant.outline,
                onPressed: () => context.pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
