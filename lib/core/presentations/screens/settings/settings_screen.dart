import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:limit_it_app/core/config/app_routes/app_routes.dart';
import 'package:limit_it_app/core/constants/app_colors.dart';
import 'package:limit_it_app/core/helpers/delete_account_dialog.dart';
import 'package:limit_it_app/core/helpers/localization_helper.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_button.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_delete_button.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_text.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_toggle.dart';
import 'package:limit_it_app/global/custom_assets/assets.gen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            forceMaterialTransparency: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            floating: true,
            snap: true,
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
                  text: context.l10n.settings,
                  color: AppColors.textColor3D3D3D,
                  fontsize: 24.sp,
                  fontWeight: FontWeight.w500,
                ),
              ],
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 32.h),

                  /// Motivation Phrases
                  _buildMenuItem(
                    context: context,
                    label: context.l10n.motivationalPhrases,
                    onTap: () => context.pushNamed(AppRoutes.motivationPhrasesScreen),
                  ),
                  SizedBox(height: 16.h),

                  /// Subscription
                  _buildMenuItem(
                    context: context,
                    label: context.l10n.subscription,
                    onTap: () => context.pushNamed(AppRoutes.subscriptionScreen),
                  ),
                  SizedBox(height: 16.h),

                  /// Change Password
                  _buildMenuItem(
                    context: context,
                    label: context.l10n.changePassword,
                    onTap: () => context.pushNamed(AppRoutes.changePasswordScreen),
                  ),
                  SizedBox(height: 16.h),

                  /// Privacy Policy
                  _buildMenuItem(
                    context: context,
                    label: context.l10n.privacyPolicy,
                    onTap: () => context.pushNamed(AppRoutes.privacyPolicyScreen),
                  ),
                  SizedBox(height: 16.h),

                  /// Terms & Conditions
                  _buildMenuItem(
                    context: context,
                    label: context.l10n.termsAndConditions,
                    onTap: () => context.pushNamed(AppRoutes.termsServicesScreen),
                  ),
                  SizedBox(height: 16.h),

                  /// Pin Settings
                  _buildMenuItem(
                    context: context,
                    label: context.l10n.pinSettings,
                    onTap: () {},
                  ),
                  SizedBox(height: 16.h),

                  /// About Us
                  _buildMenuItem(
                    context: context,
                    label: context.l10n.aboutUs,
                    onTap: () => context.pushNamed(AppRoutes.aboutUsScreen),
                  ),
                  SizedBox(height: 16.h),

                  /// Delete Account
                  _buildMenuItem(
                    context: context,
                    label: context.l10n.delete,
                    onTap: () => showDeleteAccountDialog(context),
                  ),
                  SizedBox(height: 16.h),

                  const Divider(),
                  SizedBox(height: 16.h),

                  /// Notification Toggle
                  Container(
                    width: 345.w,
                    height: 54.h,
                    margin: EdgeInsets.only(left: 2.w),
                    decoration: BoxDecoration(
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
                          child: CustomText(
                            text: context.l10n.notification,
                            fontsize: 16.sp,
                            color: AppColors.textColor5D5D5D,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          child: CustomToggle(
                            initialValue: false,
                            onChanged: (value) {
                              debugPrint('Notification toggled: $value');
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),

                  /// Logout Button
                  CustomButton(
                    title: context.l10n.logOut,
                    onpress: () {
                      _showLogoutConfirmationDialog(context);
                    },
                    color: AppColors.textColorA70D0D,
                    borderColor: AppColors.textColorA70D0D,
                  ),
                  SizedBox(height: 50.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 345.w,
        height: 54.h,
        margin: EdgeInsets.only(left: 2.w),
        decoration: BoxDecoration(
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
              child: CustomText(
                text: label,
                fontsize: 16.sp,
                color: AppColors.textColor5D5D5D,
                fontWeight: FontWeight.w500,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Assets.icons.chevron.svg(),
            ),
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
                  text: context.l10n.readyToLogOut,
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
                        title: context.l10n.cancel,
                        bgColor: AppColors.textColorE7E7E7,
                        textColor: AppColors.textColor3D3D3D,
                        onTap: () => Navigator.pop(context),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: CustomDeleteTwoButton(
                        title: context.l10n.logOut,
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