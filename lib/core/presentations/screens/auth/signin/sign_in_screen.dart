import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:limit_it_app/controllers/auth_controller.dart';
import 'package:limit_it_app/core/config/app_routes/app_routes.dart';
import 'package:limit_it_app/core/helpers/localization_helper.dart';
import 'package:limit_it_app/core/helpers/toast_message_helper.dart';
import 'package:limit_it_app/core/presentations/widgets/ui/ui.dart';
import 'package:limit_it_app/global/custom_assets/assets.gen.dart';

class LoginInScreen extends StatelessWidget {
  LoginInScreen({super.key});

  final GlobalKey<FormState> _logKey = GlobalKey<FormState>();

  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passWordCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final l10n = context.l10n;

    return AppScaffold(
      appBar: const AppTopBar(),
      scrollable: true,
      resizeToAvoidBottomInset: true,
      body: Form(
        key: _logKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 8.h),
            Text(l10n.logInYourAccount, style: AppTextStyles.h1()),
            SizedBox(height: 8.h),
            Text(
              l10n.logInSecurely,
              style: AppTextStyles.body(color: AppColors.slateGreen),
            ),

            SizedBox(height: 28.h),

            AppTextField(
              controller: emailCtrl,
              label: l10n.email,
              hintText: 'you@example.com',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '${l10n.email} ${l10n.passwordRequired}';
                }
                final ok = RegExp(r'^[\w\.\-\+]+@([\w\-]+\.)+[\w\-]{2,}$')
                    .hasMatch(value.trim());
                return ok ? null : l10n.emailInvalid;
              },
            ),
            SizedBox(height: 16.h),

            AppTextField(
              controller: passWordCtrl,
              label: l10n.password,
              hintText: '••••••••',
              isPassword: true,
              validator: (value) => (value == null || value.isEmpty)
                  ? l10n.passwordRequired
                  : null,
            ),

            /// ---------------- Server-side login error ----------------
            Obx(() {
              if (authController.loginErrorMessage.value.isEmpty) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: EdgeInsets.only(top: 8.h, left: 2.w),
                child: Text(
                  authController.loginErrorMessage.value,
                  style: AppTextStyles.caption(color: AppColors.alertRed),
                ),
              );
            }),

            SizedBox(height: 12.h),

            Align(
              alignment: Alignment.centerRight,
              child: AppTextLink(
                label: l10n.forgetPassword,
                style: AppTextStyles.small(color: AppColors.forestGreen)
                    .copyWith(fontWeight: AppFont.semiBold),
                onPressed: () {
                  if (emailCtrl.text.isEmpty) {
                    authController.loginErrorMessage.value =
                        l10n.pleaseEnterYourEmail;
                  } else {
                    context.pushNamed(
                      AppRoutes.forgetPasswordScreen,
                      extra: emailCtrl.text,
                    );
                  }
                },
              ),
            ),

            SizedBox(height: 20.h),

            Obx(
              () => AppButton(
                label: l10n.login,
                loading: authController.loginLoading.value,
                onPressed: () {
                  if (_logKey.currentState?.validate() ?? true) {
                    authController.handleLogIn(
                      emailCtrl.text,
                      passWordCtrl.text.trim(),
                      context: context,
                    );
                  }
                },
              ),
            ),

            SizedBox(height: 20.h),

            /// ---------------- OR divider ----------------
            _OrDivider(label: l10n.or),

            SizedBox(height: 20.h),

            /// ---------------- Sign in with Apple ----------------
            AppSocialButton(
              dark: true,
              label: l10n.continueWithApple,
              icon: Assets.icons.ui.apple.svg(
                width: 20.w,
                height: 20.w,
                colorFilter: const ColorFilter.mode(
                  AppColors.white,
                  BlendMode.srcIn,
                ),
              ),
              onPressed: () => ToastMessageHelper.showToastMessage(
                l10n.socialLoginComingSoon,
              ),
            ),

            SizedBox(height: 12.h),

            /// ---------------- Sign in with Google ----------------
            AppSocialButton(
              dark: false,
              label: l10n.continueWithGoogle,
              icon: Assets.icons.ui.google.svg(width: 20.w, height: 20.w),
              onPressed: () => ToastMessageHelper.showToastMessage(
                l10n.socialLoginComingSoon,
              ),
            ),

            SizedBox(height: 20.h),

            Center(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => context.pushNamed(AppRoutes.signUpScreen),
                child: RichText(
                  text: TextSpan(
                    text: '${l10n.alreadyHaveAccount} ',
                    style: AppTextStyles.small(color: AppColors.slateGreen),
                    children: [
                      TextSpan(
                        text: l10n.signUp,
                        style: AppTextStyles.small(color: AppColors.forestGreen)
                            .copyWith(fontWeight: AppFont.semiBold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
}

/// "— or —" horizontal rule with a centred label.
class _OrDivider extends StatelessWidget {
  const _OrDivider({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.haze, thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Text(
            label,
            style: AppTextStyles.small(color: AppColors.mist),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.haze, thickness: 1)),
      ],
    );
  }
}
