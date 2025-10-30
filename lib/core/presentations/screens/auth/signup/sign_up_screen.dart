import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:limit_it_app/controllers/auth_controller.dart';
import 'package:limit_it_app/core/config/app_routes/app_routes.dart';
import 'package:limit_it_app/core/constants/app_colors.dart';
import 'package:limit_it_app/core/constants/app_strings.dart';
import 'package:limit_it_app/core/helpers/toast_message_helper.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_button.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_text.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_text_field.dart';
import 'package:limit_it_app/global/custom_assets/assets.gen.dart';

class SignUpScreen extends StatefulWidget {
  SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {



  AuthController authController = Get.put(AuthController());
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final RxBool isChecked = false.obs;
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController passWordCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 40.h),

                      // Title
                      CustomText(
                        text: AppString.signUp,
                        fontsize: 24.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textColor3D3D3D,
                      ),

                      SizedBox(height: 8.h),

                      // Subtitle
                      CustomText(
                        textAlign: TextAlign.start,
                        text: AppString.enter,
                        fontsize: 14.sp,
                        color: AppColors.textColor5D5D5D,
                        maxline: 2,
                      ),

                      SizedBox(height: 32.h),

                      // Form fields
                      CustomTextField(
                        hintextColor: AppColors.textColor5D5D5D,
                        controller: nameCtrl,
                        hintText: AppString.firstName,
                        prefixIcon: Assets.icons.nameProfile.svg(),
                      ),

                      SizedBox(height: 16.h),

                      CustomTextField(
                        hintextColor: AppColors.textColor5D5D5D,
                        controller: emailCtrl,
                        hintText: AppString.email,
                        prefixIcon: Assets.icons.email.svg(),
                        isEmail: true,
                      ),

                      SizedBox(height: 16.h),

                      CustomTextField(
                        hintextColor: AppColors.textColor5D5D5D,
                        controller: passWordCtrl,
                        prefixIcon: Assets.icons.pass.svg(),
                        hintText: AppString.password,
                        isPassword: true,
                      ),

                      SizedBox(height: 16.h),


                      ///================================ Terms checkbox ================================
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(
                                () => Checkbox(
                              activeColor: AppColors.primaryColor,
                              checkColor: Colors.white,
                              value: isChecked.value,
                              onChanged: (value) {
                                isChecked.value = value ?? false;
                              },
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(top: 12.h),
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    color: AppColors.textColor3D3D3D,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: AppString.creating,
                                    ),
                                    TextSpan(
                                      text: AppString.terms,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12.sp,
                                        color: AppColors.primaryColor,
                                        decoration: TextDecoration.underline,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          // Open Terms
                                        },
                                    ),
                                    TextSpan(text: ' & '),
                                    TextSpan(
                                      text: AppString.privacy,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12.sp,
                                        color: AppColors.primaryColor,
                                        decoration: TextDecoration.underline,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          // Open Privacy Policy
                                        },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 32.h),

                      /// ====================> Sign Up button =========================================
                      Obx(() => CustomButton(
                        loading: authController.signUpLoading.value,
                        title: AppString.signUps,
                        onpress: () {
                          if ((formKey.currentState?.validate() ?? false) && isChecked.value) {
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
                            ToastMessageHelper.showToastMessage("Please accept Privacy Policy",title: 'Failed');
                          }
                        },
                      )),


                      SizedBox(height: 24.h),

                      // Login link
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            CustomText(
                              text: AppString.already,
                              color: AppColors.textColor1A1A1A,
                              fontsize: 14.sp,
                              fontWeight: FontWeight.w400,
                            ),
                            GestureDetector(
                              onTap: () {
                                context.pushNamed(AppRoutes.logInScreen);
                              },
                              child: CustomText(
                                text: AppString.login,
                                color: AppColors.primaryColor,
                                fontsize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 40.h),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}