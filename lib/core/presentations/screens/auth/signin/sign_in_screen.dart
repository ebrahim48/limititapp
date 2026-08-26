import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:limit_it_app/controllers/auth_controller.dart';
import 'package:limit_it_app/core/config/app_routes/app_routes.dart';
import 'package:limit_it_app/core/helpers/localization_helper.dart';
import 'package:limit_it_app/core/presentations/widgets/ui/ui.dart';

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
                        "Please enter your email";
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
