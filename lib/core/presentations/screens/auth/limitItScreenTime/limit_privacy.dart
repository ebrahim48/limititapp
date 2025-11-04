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
import 'package:limit_it_app/global/custom_assets/assets.gen.dart';

class LimitPrivacyProtectionScreen extends StatefulWidget {
  LimitPrivacyProtectionScreen({super.key});

  @override
  State<LimitPrivacyProtectionScreen> createState() => _LimitPrivacyProtectionScreenState();
}

class _LimitPrivacyProtectionScreenState extends State<LimitPrivacyProtectionScreen> {
  final RxBool isChecked = false.obs;

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

          // Main content
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 112.h),

                    // Title
                    CustomText(
                      text: "Limit It",
                      fontsize: 32.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textColor2C2C2C,
                    ),

                    SizedBox(height: 12.h),

                    CustomText(
                      text: context.l10n.takeControl,
                      fontsize: 16.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textColor454545,
                    ),

                    SizedBox(height: 32.h),

                    // Privacy icon
                    Center(
                      child: Assets.images.privacy.image(
                        width: 85.w,
                        height: 85.h,
                      ),
                    ),

                    SizedBox(height: 32.h),


                    Container(
                      width: 334.w,
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: Color(0xFF888888),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          CustomText(
                            text: context.l10n.privacyDataProtection,
                            fontsize: 24.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textColor2C2C2C,
                          ),

                          SizedBox(height: 16.h),

                          _buildPrivacyPoint(context.l10n.usageDataStaysOnDevice),
                          SizedBox(height: 12.h),

                          _buildPrivacyPoint(context.l10n.noPersonalInfoCollection),
                          SizedBox(height: 12.h),

                          _buildPrivacyPoint(context.l10n.gdprCompliance),
                          SizedBox(height: 12.h),

                          _buildPrivacyPoint(context.l10n.transparentPermissions),
                        ],
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // Terms checkbox
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(
                              () => Checkbox(
                            activeColor: AppColors.primaryColor,
                            checkColor: AppColors.textColorF6F6F6,
                            value: isChecked.value,
                            onChanged: (value) {
                              isChecked.value = value ?? false;
                            },
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(top: 20.h),
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  color: AppColors.textColor3D3D3D,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w400,
                                ),
                                children: [
                                  TextSpan(
                                    text: context.l10n.iAcceptPrivacy,
                                  ),


                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 32.h),

                    // Get Started button
                    CustomButton(
                      title: "Get Started",
                      onpress: () {
                        context.pushNamed(AppRoutes.selectAppsManageScreen);
                      },
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



  Widget _buildPrivacyPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 2.h),
          child: Icon(
            Icons.check,
            size: 23.r,
            color: AppColors.primaryColor,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: CustomText(
            text: text,
            fontsize: 14.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.textColor5D5D5D,
            maxline: 2,
            textAlign: TextAlign.left,
          ),
        ),
      ],
    );
  }


}