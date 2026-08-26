import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:limit_it_app/controllers/auth_controller.dart';
import 'package:limit_it_app/core/helpers/localization_helper.dart';
import 'package:limit_it_app/core/presentations/widgets/ui/ui.dart';
import 'package:limit_it_app/global/custom_assets/assets.gen.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key, required this.email});

  final String email;

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final TextEditingController emailCtrl = TextEditingController();
  final GlobalKey<FormState> _logKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    emailCtrl.text = widget.email;
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final l10n = context.l10n;

    return AppScaffold(
      appBar: AppTopBar(title: l10n.forgetPasswordTitle),
      scrollable: true,
      resizeToAvoidBottomInset: true,
      body: Form(
        key: _logKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 12.h),
            Center(
              child: Assets.illustrations.mailCircle.svg(
                width: 88.w,
                height: 88.w,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              l10n.forgetPasswordSubtitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.body(color: AppColors.slateGreen),
            ),
            SizedBox(height: 28.h),

            AppTextField(
              controller: emailCtrl,
              label: l10n.email,
              hintText: 'you@example.com',
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '${l10n.email} ${l10n.passwordRequired}';
                }
                final ok = RegExp(r'^[\w\.\-\+]+@([\w\-]+\.)+[\w\-]{2,}$')
                    .hasMatch(value.trim());
                return ok ? null : l10n.emailInvalid;
              },
            ),

            SizedBox(height: 28.h),

            Obx(
              () => AppButton(
                label: l10n.getOtp,
                loading: authController.forgotLoading.value,
                onPressed: () {
                  if (_logKey.currentState?.validate() ?? true) {
                    authController.handleForgot(
                      emailCtrl.text,
                      "forgot",
                      context: context,
                    );
                  }
                },
              ),
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
}
