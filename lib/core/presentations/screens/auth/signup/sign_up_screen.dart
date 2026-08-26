import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:limit_it_app/controllers/auth_controller.dart';
import 'package:limit_it_app/core/config/app_routes/app_routes.dart';
import 'package:limit_it_app/core/helpers/localization_helper.dart';
import 'package:limit_it_app/core/helpers/toast_message_helper.dart';
import 'package:limit_it_app/core/presentations/widgets/ui/ui.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final RxBool isChecked = false.obs;
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController passWordCtrl = TextEditingController();
  final TextEditingController confirmPassWordCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final l10n = context.l10n;

    return AppScaffold(
      appBar: const AppTopBar(),
      scrollable: true,
      resizeToAvoidBottomInset: true,
      body: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 8.h),
            Text(l10n.signUpYourAccount, style: AppTextStyles.h1()),
            SizedBox(height: 8.h),
            Text(
              l10n.enterYourDetails,
              style: AppTextStyles.body(color: AppColors.slateGreen),
            ),

            SizedBox(height: 28.h),

            AppTextField(
              controller: nameCtrl,
              label: l10n.firstName,
              hintText: l10n.firstName,
              textInputAction: TextInputAction.next,
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? '${l10n.firstName} ${l10n.passwordRequired}'
                  : null,
            ),
            SizedBox(height: 16.h),

            AppTextField(
              controller: emailCtrl,
              label: l10n.email,
              hintText: 'you@example.com',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              onChanged: (_) => authController.signUpError(''),
              validator: _emailValidator,
            ),

            Obx(() {
              if (authController.signUpError.value.isEmpty) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: EdgeInsets.only(top: 6.h, left: 2.w),
                child: Text(
                  authController.signUpError.value,
                  style: AppTextStyles.caption(color: AppColors.alertRed),
                ),
              );
            }),

            SizedBox(height: 16.h),

            AppTextField(
              controller: passWordCtrl,
              label: l10n.password,
              hintText: '••••••••',
              isPassword: true,
              validator: _passwordValidator,
            ),

            SizedBox(height: 20.h),

            /// ---------------- Terms checkbox ----------------
            Obx(
              () => GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => isChecked.value = !isChecked.value,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CheckBox(value: isChecked.value),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: AppTextStyles.small(
                            color: AppColors.slateGreen,
                          ),
                          children: [
                            TextSpan(text: l10n.byCreatingAccount),
                            TextSpan(
                              text: l10n.termsAndConditions,
                              style: AppTextStyles.small(
                                color: AppColors.forestGreen,
                              ).copyWith(fontWeight: AppFont.semiBold),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () => context
                                    .pushNamed(AppRoutes.termsServicesScreen),
                            ),
                            const TextSpan(text: ' & '),
                            TextSpan(
                              text: l10n.privacyPolicy,
                              style: AppTextStyles.small(
                                color: AppColors.forestGreen,
                              ).copyWith(fontWeight: AppFont.semiBold),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () => context
                                    .pushNamed(AppRoutes.privacyPolicyScreen),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 28.h),

            /// ---------------- Sign up ----------------
            Obx(
              () => AppButton(
                label: l10n.signUp,
                loading: authController.signUpLoading.value,
                onPressed: () {
                  if ((formKey.currentState?.validate() ?? false) &&
                      isChecked.value) {
                    authController.handleSignUp(
                      name: nameCtrl.text.trim(),
                      email: emailCtrl.text.trim(),
                      password: passWordCtrl.text.trim(),
                      isPrivacy: isChecked.value,
                      role: "USER",
                      context: context,
                      screenType: "signup",
                    );
                  } else if (!isChecked.value) {
                    ToastMessageHelper.showToastMessage(
                      l10n.pleaseAcceptPrivacyPolicy,
                      title: l10n.failed,
                    );
                  }
                },
              ),
            ),

            SizedBox(height: 20.h),

            Center(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => context.pushNamed(AppRoutes.logInScreen),
                child: RichText(
                  text: TextSpan(
                    text: '${l10n.alreadyHaveAccount} ',
                    style: AppTextStyles.small(color: AppColors.slateGreen),
                    children: [
                      TextSpan(
                        text: l10n.login,
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

  String? _emailValidator(String? value) {
    final l10n = context.l10n;
    if (value == null || value.trim().isEmpty) {
      return '${l10n.email} ${l10n.passwordRequired}';
    }
    final ok = RegExp(r'^[\w\.\-\+]+@([\w\-]+\.)+[\w\-]{2,}$')
        .hasMatch(value.trim());
    return ok ? null : l10n.emailInvalid;
  }

  String? _passwordValidator(String? value) {
    final l10n = context.l10n;
    if (value == null || value.isEmpty) return l10n.passwordRequired;
    final hasLetter = RegExp(r'[A-Za-z]').hasMatch(value);
    final hasDigit = RegExp(r'\d').hasMatch(value);
    if (value.length < 8 || !hasLetter || !hasDigit) {
      return l10n.passwordRule;
    }
    return null;
  }
}

/// Rounded checkbox matching the design system.
class _CheckBox extends StatelessWidget {
  const _CheckBox({required this.value});

  final bool value;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      width: 20.w,
      height: 20.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: value ? AppColors.leafGreen : AppColors.white,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(
          color: value ? AppColors.leafGreen : AppColors.haze,
          width: 1.5,
        ),
      ),
      child: value
          ? Icon(Icons.check_rounded, size: 14.sp, color: AppColors.white)
          : null,
    );
  }
}
