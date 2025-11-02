import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:go_router/go_router.dart';
import 'package:limit_it_app/controllers/auth_controller.dart';
import 'package:limit_it_app/core/config/app_routes/app_routes.dart';
import 'package:limit_it_app/core/constants/app_colors.dart';
import 'package:limit_it_app/core/constants/app_strings.dart';
import 'package:limit_it_app/core/helpers/toast_message_helper.dart';
import 'package:limit_it_app/core/presentations/screens/auth/verify/custom_pin_text_field.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_button.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_text.dart';


class VerifyScreen extends StatelessWidget {

  final String screenType;
  final String email;
  final String token;
  VerifyScreen({super.key,required this.screenType, required this.email,required this.token});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(Icons.arrow_back, color: Colors.black, size: 20.r),
              onPressed: () => Navigator.pop(context),
            ),
            SizedBox(width: 12.w),
            CustomText(
              text: AppString.verifyOtp,
              color: AppColors.textColor3D3D3D,
              fontsize: 24.sp,
              fontWeight: FontWeight.w500,
            ),
          ],
        ),
      ),
      body: Stack(
        children: [

          Positioned(
            top: 18.h,
            right: 20.w,
            child: Container(
              width: 259.w,
              height: 195.h,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                  ),
                ),
              ),
            ),
          ),


          Positioned(
            bottom: 0,
            left: 0,
            child: Container(
              width: 158.w,
              height: 219.h,
              decoration: BoxDecoration(
                color: AppColors.textColor803D20.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                  ),
                ),
              ),
            ),
          ),


          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    SizedBox(height: 32.h),

                    /// <<< ============><>>> OTP  << < ==============>>>

                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomPinCodeTextField(textEditingController: otpTEController),
                        SizedBox(height: 12.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomText(
                              textAlign: TextAlign.center,
                              text: AppString.didnt,
                              color: AppColors.textColor3D3D3D,
                              fontWeight: FontWeight.w400,
                              fontsize: 12.sp,

                            ),
                            GestureDetector(
                              onTap: isCountingDown.value
                                  ? null
                                  : () {
                                startCountdown();
                              },
                              child: CustomText(
                                fontWeight: FontWeight.w600,
                                text: isCountingDown.value
                                    ? '${'Resend in'} ${countdown.value}s'
                                    : ' Resend',
                                color: isCountingDown.value
                                    ? AppColors.textColor3D3D3D
                                    : AppColors.primaryColor,
                                fontsize: 14.sp,
                              ),
                            ),
                          ],
                        ),

                      ],
                    ),







                    SizedBox(height: 32.h),


                    Obx(() => CustomButton(
                      loading: authController.verfyLoading.value,
                      title: "Verify",
                      onpress: () {
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
                    )),

                    SizedBox(height: 12.h),

                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),
          ),
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