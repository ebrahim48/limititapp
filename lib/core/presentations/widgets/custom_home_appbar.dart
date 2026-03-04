import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:limit_it_app/controllers/profile_controller.dart';
import 'package:limit_it_app/core/config/app_routes/app_routes.dart';
import 'package:limit_it_app/core/constants/app_colors.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_network_image.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_text.dart';
import 'package:limit_it_app/global/custom_assets/assets.gen.dart';

class CustomHomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomHomeAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    final ProfileController profileController = Get.find<ProfileController>();

    return Obx(() {
      final profile = profileController.userProfile.value;
      final String displayName = profile?.name ?? 'User';
      final String? profilePicture = profile?.profilePicture;

      return AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        leadingWidth: 200.w,
        toolbarHeight: 70.h,
        leading: Row(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 15.w),
              child: GestureDetector(
                onTap: () {
                  context.pushNamed(AppRoutes.viewProfileScreen);
                },
                child: _buildProfileImage(profilePicture),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: CustomText(
                textAlign: TextAlign.start,
                text: displayName,
                color: AppColors.textColor3D3D3D,
                fontsize: 16.sp,
                fontWeight: FontWeight.w500,
                maxline: 1,
                textOverflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 30.w),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () {
                    context.pushNamed(AppRoutes.notificationsScreen);
                  },
                  child: Assets.icons.notifications
                      .svg(width: 24.w, height: 24.h),
                ),
                SizedBox(width: 10.w),
                GestureDetector(
                  onTap: () {
                    context.pushNamed(AppRoutes.settingsScreen);
                  },
                  child: Assets.icons.settings.svg(width: 24.w, height: 24.h),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildProfileImage(String? profilePicture) {
    // Check if it's a network image URL
    if (profilePicture != null &&
        profilePicture.isNotEmpty &&
        (profilePicture.startsWith('http://') || profilePicture.startsWith('https://'))) {
      return Container(
        width: 32.w,
        height: 32.h,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.primaryColor4C956C,
            width: 3,
          ),
        ),
        child: ClipOval(
          child: CustomNetworkImage(
            imageUrl: profilePicture,
            borderRadius: BorderRadius.zero,
          ),
        ),
      );
    }

    // Fallback to local asset
    return Container(
      width: 32.w,
      height: 32.h,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primaryColor4C956C,
          width: 3,
        ),
      ),
      child: ClipOval(
        child: Image.asset(
          "assets/images/viewProfile.png",
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
