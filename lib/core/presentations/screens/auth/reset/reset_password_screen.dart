import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:limit_it_app/core/config/app_routes/app_routes.dart';
import 'package:limit_it_app/core/constants/app_colors.dart';
import 'package:limit_it_app/core/helpers/localization_helper.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_button.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_text.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_text_field.dart';
import 'package:limit_it_app/global/custom_assets/assets.gen.dart';

class ResetPasswordScreen extends StatelessWidget {
  ResetPasswordScreen({super.key});


  final TextEditingController newPassWordCtrl = TextEditingController();
  final TextEditingController confirmNewPassWordCtrl = TextEditingController();

  // Observable variables
  final RxBool isMatched = false.obs;
  final RxBool isChecked = false.obs;
  final RxBool isObscureConfirmPassword = true.obs;


  @override
  Widget build(BuildContext context) {
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
              text: context.l10n.resetPassword,
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
                color: AppColors.primaryColor.withValues(alpha: 0.5),
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
                color: AppColors.textColor803D20.withValues(alpha: 0.3),
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

                    CustomTextField(
                      hintextColor: AppColors.textColor5D5D5D,
                      controller: newPassWordCtrl,
                      prefixIcon: Assets.icons.pass.svg(),
                      hintText: context.l10n.setNewPassword,
                      isPassword: true,
                    ),

                    SizedBox(height: 16.h),

                    CustomTextField(
                      hintextColor: AppColors.textColor5D5D5D,
                      controller: confirmNewPassWordCtrl,
                      prefixIcon: Assets.icons.pass.svg(),
                      hintText: context.l10n.confirmNewPassword,
                      isPassword: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          isMatched.value = false;
                          return 'Please enter your confirm password';
                        } else if (newPassWordCtrl.text == value) {
                          isMatched.value = true;
                          return null;
                        } else {
                          isMatched.value = false;
                          return 'Password Not Matching';
                        }
                      },
                      onChanged: (value) {
                        isMatched.value = newPassWordCtrl.text == value;
                      },
                    ),

                    SizedBox(height: 8.h),

                    // Password match indicator
                    Obx(() => isMatched.value
                        ? Align(
                      alignment: Alignment.centerLeft,
                      child: CustomText(
                        text: context.l10n.passwordMatched,
                        color: Colors.green,
                        fontsize: 12.sp,
                      ),
                    )
                        : SizedBox.shrink()),





                    SizedBox(height: 32.h),


                    CustomButton(
                      title: context.l10n.resetPassword,
                      onpress: () {
                        context.pushNamed(AppRoutes.resetSuccessFullyScreen);
                      },
                    ),
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
}