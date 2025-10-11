import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:limit_it_app/core/config/app_routes/app_routes.dart';
import 'package:limit_it_app/core/constants/app_colors.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_button.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_delete_button.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_text.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_toggle.dart';
import 'package:limit_it_app/global/custom_assets/assets.gen.dart';




class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key});





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
              icon: Icon(Icons.arrow_back, color: Colors.black, size: 24.r),
              onPressed: () => Navigator.pop(context),
            ),
            SizedBox(width: 12.w),
            CustomText(
              text: "Settings",
              color: AppColors.textColor3D3D3D,
              fontsize: 24.sp,
              fontWeight: FontWeight.w500,
            ),
          ],
        ),

      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 32.h),

            /// ==================================> Motivation Phrases =============================>
            GestureDetector(
              onTap: () {
                context.pushNamed(AppRoutes.motivationPhrasesScreen);
              },
              child: Container(
                width: 345.w,
                height: 54.h,
                margin: EdgeInsets.only(left: 2.w),
                decoration: BoxDecoration(
                  // color: AppColors.backgroundColor,
                  borderRadius: BorderRadius.all(Radius.circular(12.r)),
                  border: Border.all(
                    color: AppColors.borderColorD1D1D1,
                    width: 1.w,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: Row(
                        children: [
                          CustomText(text: 'Motivation Phrases',
                            fontsize: 16.sp,
                            color: AppColors.textColor5D5D5D,
                            fontWeight: FontWeight.w500,
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child:  Assets.icons.chevron.svg(),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.h),

            /// ==================================> Subscription =============================>
            GestureDetector(
              onTap: () {
                context.pushNamed(AppRoutes.subscriptionScreen);

              },
              child: Container(
                width: 345.w,
                height: 54.h,
                margin: EdgeInsets.only(left: 2.w),
                decoration: BoxDecoration(
                  // color: AppColors.backgroundColor,
                  borderRadius: BorderRadius.all(Radius.circular(12.r)),
                  border: Border.all(
                    color: AppColors.borderColorD1D1D1,
                    width: 1.w,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: Row(
                        children: [
                          CustomText(text: 'Subscription',
                            fontsize: 16.sp,
                            color: AppColors.textColor5D5D5D,
                            fontWeight: FontWeight.w500,
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child:  Assets.icons.chevron.svg(),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.h),

            /// ==================================> Change Password =============================>
            GestureDetector(
              onTap: () {
                context.pushNamed(AppRoutes.changePasswordScreen);

              },
              child: Container(
                width: 345.w,
                height: 54.h,
                margin: EdgeInsets.only(left: 2.w),
                decoration: BoxDecoration(
                  // color: AppColors.backgroundColor,
                  borderRadius: BorderRadius.all(Radius.circular(12.r)),
                  border: Border.all(
                    color: AppColors.borderColorD1D1D1,
                    width: 1.w,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: Row(
                        children: [
                          CustomText(text: 'Change Password',
                            fontsize: 16.sp,
                            color: AppColors.textColor5D5D5D,
                            fontWeight: FontWeight.w500,
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child:  Assets.icons.chevron.svg(),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.h),

            /// ==================================> Privacy Policy =============================>
            GestureDetector(
              onTap: () {

                context.pushNamed(AppRoutes.privacyPolicyScreen);

              },
              child: Container(
                width: 345.w,
                height: 54.h,
                margin: EdgeInsets.only(left: 2.w),
                decoration: BoxDecoration(
                  // color: AppColors.backgroundColor,
                  borderRadius: BorderRadius.all(Radius.circular(12.r)),
                  border: Border.all(
                    color: AppColors.borderColorD1D1D1,
                    width: 1.w,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: Row(
                        children: [
                          CustomText(text: 'Privacy Policy',
                            fontsize: 16.sp,
                            color: AppColors.textColor5D5D5D,
                            fontWeight: FontWeight.w500,
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child:  Assets.icons.chevron.svg(),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.h),

            /// ==================================> Terms & Conditions =============================>
            GestureDetector(
              onTap: () {
                context.pushNamed(AppRoutes.termsServicesScreen);
              },
              child: Container(
                width: 345.w,
                height: 54.h,
                margin: EdgeInsets.only(left: 2.w),
                decoration: BoxDecoration(
                  // color: AppColors.backgroundColor,
                  borderRadius: BorderRadius.all(Radius.circular(12.r)),
                  border: Border.all(
                    color: AppColors.borderColorD1D1D1,
                    width: 1.w,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: Row(
                        children: [
                          CustomText(text: 'Terms & Conditions',
                            fontsize: 16.sp,
                            color: AppColors.textColor5D5D5D,
                            fontWeight: FontWeight.w500,
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child:  Assets.icons.chevron.svg(),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.h),

            /// ==================================> About Us  =============================>
            GestureDetector(
              onTap: () {
                context.pushNamed(AppRoutes.aboutUsScreen);
              },
              child: Container(
                width: 345.w,
                height: 54.h,
                margin: EdgeInsets.only(left: 2.w),
                decoration: BoxDecoration(
                  // color: AppColors.backgroundColor,
                  borderRadius: BorderRadius.all(Radius.circular(12.r)),
                  border: Border.all(
                    color: AppColors.borderColorD1D1D1,
                    width: 1.w,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: Row(
                        children: [
                          CustomText(text: 'About Us',
                            fontsize: 16.sp,
                            color: AppColors.textColor5D5D5D,
                            fontWeight: FontWeight.w500,
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child:  Assets.icons.chevron.svg(),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16.h),

            Divider(),
            SizedBox(height: 16.h),
            /// ==================================> Notification =============================>
            GestureDetector(
              onTap: () {

              },
              child: Container(
                width: 345.w,
                height: 54.h,
                margin: EdgeInsets.only(left: 2.w),
                decoration: BoxDecoration(
                  // color: AppColors.backgroundColor,
                  borderRadius: BorderRadius.all(Radius.circular(12.r)),
                  border: Border.all(
                    color: AppColors.borderColorD1D1D1,
                    width: 1.w,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: Row(
                        children: [
                          CustomText(text: 'Notification',
                            fontsize: 16.sp,
                            color: AppColors.textColor5D5D5D,
                            fontWeight: FontWeight.w500,
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: CustomToggle(
                        initialValue: false,
                        onChanged: (value) {
                          print('Notification toggled: $value');
                        },
                      ),
                    ),

                  ],
                ),
              ),
            ),
            SizedBox(height: 50.h),


            CustomButton(
                title: 'Log out',
                onpress: () {
                  _showLogoutConfirmationDialog(context);
                },
              color: AppColors.textColorA70D0D,
            ),
            SizedBox(height: 80.h),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: AppColors.textColorFFFFFF,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 12.h),
                CustomText(
                  text: 'Ready to Log out ?',
                  fontsize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textColor3D3D3D,
                ),
                SizedBox(height: 24.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: CustomDeleteTwoButton(
                        title: 'Cancel',
                        bgColor: AppColors.textColorE7E7E7,
                        textColor: AppColors.textColor3D3D3D,
                        onTap: () => Navigator.pop(context),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: CustomDeleteTwoButton(
                        title: 'Log Out',
                        bgColor: AppColors.textColorA70D0D,
                        textColor: AppColors.textColorFFFFFF,
                        onTap: () async {
                          context.pushNamed(AppRoutes.logInScreen);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }


}
