import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:limit_it_app/controllers/auth_controller.dart';
import 'package:limit_it_app/core/helpers/localization_helper.dart';
import 'package:limit_it_app/core/helpers/toast_message_helper.dart';
import 'package:limit_it_app/core/presentations/screens/auth/verify/custom_pin_text_field.dart';
import 'package:limit_it_app/core/presentations/widgets/ui/ui.dart';
import 'package:limit_it_app/global/custom_assets/assets.gen.dart';

class VerifyScreen extends StatelessWidget {
  final String screenType;
  final String email;
  final String token;

  VerifyScreen({
    super.key,
    required this.screenType,
    required this.email,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final l10n = context.l10n;

    return AppScaffold(
      appBar: AppTopBar(title: l10n.verifyOtp),
      scrollable: true,
      resizeToAvoidBottomInset: true,
      body: Column(
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
            l10n.verifyOtpSubtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.body(color: AppColors.slateGreen),
          ),
          SizedBox(height: 6.h),
          Text(
            email,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium(color: AppColors.forestGreen),
          ),

          SizedBox(height: 28.h),

          CustomPinCodeTextField(textEditingController: otpTEController),

          SizedBox(height: 8.h),

          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  l10n.didntGetCode,
                  style: AppTextStyles.small(color: AppColors.slateGreen),
                ),
                SizedBox(width: 4.w),
                GestureDetector(
                  onTap: isCountingDown.value ? null : startCountdown,
                  child: Text(
                    isCountingDown.value
                        ? '${l10n.resendIn} ${countdown.value}s'
                        : l10n.resend,
                    style: AppTextStyles.small(
                      color: isCountingDown.value
                          ? AppColors.mist
                          : AppColors.forestGreen,
                    ).copyWith(fontWeight: AppFont.semiBold),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 28.h),

          Obx(
            () => AppButton(
              label: l10n.verify,
              loading: authController.verfyLoading.value,
              onPressed: () {
                if (otpTEController.text.isEmpty) {
                  ToastMessageHelper.showToastMessage("Please enter OTP");
                  return;
                }

                authController.verfyEmail(
                  otpTEController.text.trim(),
                  email.trim(),
                  screenType: screenType,
                  context: context,
                );
              },
            ),
          ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  final TextEditingController otpTEController = TextEditingController();

  final RxInt countdown = 60.obs;
  final RxBool isCountingDown = false.obs;

  void startCountdown() {
    isCountingDown.value = true;
    countdown.value = 60;
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown.value > 0) {
        countdown.value--;
      } else {
        timer.cancel();
        isCountingDown.value = false;
      }
    });
  }
}
