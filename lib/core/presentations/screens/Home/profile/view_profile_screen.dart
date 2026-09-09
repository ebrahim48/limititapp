import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:limit_it_app/controllers/profile_controller.dart';
import 'package:limit_it_app/core/config/app_routes/app_routes.dart';
import 'package:limit_it_app/core/models/profile_model.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_text.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_text_field.dart';
import 'package:limit_it_app/global/custom_assets/assets.gen.dart';
import '../../../../../core/constants/app_colors.dart';
import 'package:shimmer/shimmer.dart';
import 'package:limit_it_app/core/helpers/localization_helper.dart';


class ViewProfileScreen extends StatelessWidget {
  ViewProfileScreen({super.key});

  final ProfileController controller = Get.put(ProfileController());
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();

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
              text: context.l10n.viewProfile,
              color: AppColors.textColor3D3D3D,
              fontsize: 24.sp,
              fontWeight: FontWeight.w500,
            ),
          ],
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 10.w),
            child: IconButton(
              onPressed: () {
                context.pushNamed(AppRoutes.editProfileScreen);
              },
              icon: Assets.icons.edit.svg(),
            ),
          ),
        ],
      ),
      body: Obx(() {
        // Show shimmer only during loading
        if (controller.profileLoading.value) {
          return _buildShimmerLoading();
        }

        final profile = controller.userProfile.value;
        
        // If profile failed to load, show placeholder
        if (profile == null) {
          return Center(
            child: CustomText(
              text: context.l10n.failedToLoadProfile,
              fontsize: 16.sp,
              color: AppColors.textColor5D5D5D,
            ),
          );
        }

        // Set text in controllers
        nameCtrl.text = profile.name ?? '';
        emailCtrl.text = profile.email ?? '';
        phoneCtrl.text = profile.phone ?? '';

        // Format join date
        String joinDate = _formatJoinDate(context, profile.createdAt);

        return _buildProfileContent(profile, joinDate);
      }),
    );
  }

  String _formatJoinDate(BuildContext context, String? createdAt) {
    if (createdAt != null && createdAt.isNotEmpty) {
      try {
        DateTime date = DateTime.parse(createdAt);
        return context.l10n.joinedIn(
            '${date.day} ${_getMonthName(date.month)} ${date.year}');
      } catch (e) {
        return context.l10n.joinedRecently;
      }
    }
    return context.l10n.joinedRecently;
  }

  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 24.h),
            // Profile picture shimmer
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: 90.w,
                height: 90.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40.r),
                ),
              ),
            ),
            SizedBox(height: 8.h),
            // Name shimmer
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: 150.w,
                height: 24.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ),
            SizedBox(height: 8.h),
            // Join date shimmer
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: 100.w,
                height: 12.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ),
            SizedBox(height: 48.h),
            // Name field shimmer
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: double.infinity,
                height: 50.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            // Phone field shimmer
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: double.infinity,
                height: 50.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            // Email field shimmer
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: double.infinity,
                height: 50.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
            SizedBox(height: 60.h),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent(GetProfileModel profile, String joinDate) {
    return Stack(
      children: [
        Positioned(
          top: 18.h,
          left: 109.w,
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
        Container(
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
        SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 24.h),
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40.r),
                    child: _buildProfileImage(profile.profilePicture),
                  ),
                ),
                SizedBox(height: 8.h),
                CustomText(
                  text: profile.name ?? 'User',
                  fontsize: 24.sp,
                  color: AppColors.textColor3D3D3D,
                ),
                CustomText(
                  text: joinDate,
                  fontsize: 12.sp,
                  color: AppColors.textColor5D5D5D,
                ),
                SizedBox(height: 48.h),
                CustomTextField(
                    hintextColor: AppColors.textColor5D5D5D,
                    controller: nameCtrl,
                    hintText: profile.name ?? 'Name',
                    prefixIcon: Assets.icons.profileview.svg()),
                SizedBox(height: 16.h),
                CustomTextField(
                    hintextColor: AppColors.textColor5D5D5D,
                    controller: phoneCtrl,
                    hintText: profile.phone ?? 'Phone',
                    prefixIcon: Icon(Icons.phone_outlined, color: AppColors.primaryColor, size: 24.r)),
                SizedBox(height: 16.h),
                CustomTextField(
                    hintextColor: AppColors.textColor5D5D5D,
                    controller: emailCtrl,
                    hintText: profile.email ?? 'Email',
                    prefixIcon: Assets.icons.email.svg(),
                    isEmail: true),
                SizedBox(height: 60.h),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileImage(String? profilePictureUrl) {
    // Check if URL is valid (not null, not empty, and is a valid HTTP URL)
    if (profilePictureUrl != null && 
        profilePictureUrl.isNotEmpty && 
        (profilePictureUrl.startsWith('https://') || profilePictureUrl.startsWith('http://'))) {
      
      return Image.network(
        profilePictureUrl,
        width: 90.w,
        height: 90.h,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // On error, show local asset
          return Image.asset(
            "assets/images/viewProfile.png",
            width: 90.w,
            height: 90.h,
            fit: BoxFit.cover,
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          // Show shimmer while loading
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 90.w,
              height: 90.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40.r),
              ),
            ),
          );
        },
      );
    }
    // Fallback to local asset
    return Image.asset(
      "assets/images/viewProfile.png",
      width: 90.w,
      height: 90.h,
      fit: BoxFit.cover,
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }
}