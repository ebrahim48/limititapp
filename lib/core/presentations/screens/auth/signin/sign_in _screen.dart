import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:limit_it_app/core/config/app_routes/app_routes.dart';
import 'package:limit_it_app/core/constants/app_colors.dart';
import 'package:limit_it_app/core/constants/app_strings.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_button.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_text.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_text_field.dart';
import 'package:limit_it_app/global/custom_assets/assets.gen.dart';

class LoginInScreen extends StatelessWidget {
  LoginInScreen({super.key});


  // Controllers
  final TextEditingController emailCtrl = TextEditingController();
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 50.h),

                    // Title
                    CustomText(
                      text: AppString.loginYour,
                      fontsize: 24.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textColor3D3D3D,
                    ),

                    SizedBox(height: 8.h),

                    // Subtitle
                    CustomText(
                      textAlign: TextAlign.start,
                      text: AppString.loginYourSecurity,
                      fontsize: 14.sp,
                      color: AppColors.textColor5D5D5D,
                      maxline: 2,
                    ),

                    SizedBox(height: 32.h),

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

                    SizedBox(height: 5.h),

                    /// ====================================> Forget password ========================>

                    GestureDetector(
                      onTap: (){
                        context.pushNamed(AppRoutes.forgetPasswordScreen);
                      },
                      child: CustomText(
                        text: AppString.forgetPass,
                        color: AppColors.primaryColor,
                        fontsize: 12.sp,
                        fontWeight: FontWeight.w500,

                      ),
                    ),





                    SizedBox(height: 32.h),

                    // log in button
                    CustomButton(
                      title: AppString.login,
                      onpress: () {
                        context.pushNamed(AppRoutes.limitPrivacyProtectionScreen);


                      },
                    ),
                    SizedBox(height: 12.h),
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
                              context.pushNamed(AppRoutes.signUpScreen);
                            },
                            child: CustomText(
                              text: AppString.signUps,
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
        ],
      ),
    );
  }
}