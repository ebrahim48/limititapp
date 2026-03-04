import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:limit_it_app/core/constants/app_colors.dart';
import 'package:limit_it_app/core/helpers/localization_helper.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_text.dart';
import 'package:limit_it_app/controllers/settings_controller.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SettingsController());
    controller.fetchAboutUs();

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
              text: context.l10n.aboutUs,
              color: AppColors.textColor3D3D3D,
              fontsize: 24.sp,
              fontWeight: FontWeight.w500,
            ),
          ],
        ),
      ),
      body: Obx(() {
        if (controller.isLoadingAboutUs.value) {
          return _buildLoadingView(context);
        }

        if (controller.hasErrorAboutUs.value) {
          return _buildErrorView(context, controller);
        }

        return _buildContent(context, controller);
      }),
    );
  }

  Widget _buildLoadingView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SpinKitFadingCircle(
            color: AppColors.primaryGreen,
            size: 50.r,
          ),
          SizedBox(height: 16.h),
          CustomText(
            text: context.l10n.loading,
            fontsize: 16.sp,
            color: AppColors.textColor3D3D3D,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, SettingsController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64.r,
            color: Colors.red,
          ),
          SizedBox(height: 16.h),
          CustomText(
            text: context.l10n.failedToLoadData,
            fontsize: 16.sp,
            color: AppColors.textColor3D3D3D,
          ),
          SizedBox(height: 24.h),
          TextButton(
            onPressed: () {
              controller.fetchAboutUs();
            },
            child: CustomText(
              text: context.l10n.retry,
              fontsize: 16.sp,
              color: AppColors.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, SettingsController controller) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 24.h),

            Container(
              width: 348.w,
              height: 172.h,
              decoration: BoxDecoration(
                color: const Color(0xFFEDD69A),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(40.r),
                  child: Image.asset(
                    "assets/images/aboutus.png",
                    width: 205.w,
                    height: 149.h,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            SizedBox(height: 24.h),

            // Display content from API
            if (controller.aboutUsContent.isNotEmpty)
              CustomText(
                maxline: 200,
                textAlign: TextAlign.start,
                text: controller.aboutUsContent.value,
                fontsize: 14.sp,
                color: AppColors.textColor3D3D3D,
              ),

            SizedBox(height: 32.h),

            // Contact information
            if (controller.aboutUsName.isNotEmpty ||
                controller.aboutUsEmail.isNotEmpty ||
                controller.aboutUsPhone.isNotEmpty)
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (controller.aboutUsName.isNotEmpty)
                      CustomText(
                        text: controller.aboutUsName.value,
                        fontsize: 16.sp,
                        color: AppColors.textColor3D3D3D,
                      ),
                    SizedBox(height: 16.h),

                    // Phone row
                    if (controller.aboutUsPhone.isNotEmpty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.phone,
                            size: 18.r,
                            color: AppColors.textColor3D3D3D,
                          ),
                          SizedBox(width: 8.w),
                          CustomText(
                            text: controller.aboutUsPhone.value,
                            fontsize: 16.sp,
                            color: AppColors.textColor3D3D3D,
                          ),
                        ],
                      ),
                    SizedBox(height: 16.h),

                    // Email row
                    if (controller.aboutUsEmail.isNotEmpty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.email_outlined,
                            size: 18.r,
                            color: AppColors.textColor3D3D3D,
                          ),
                          SizedBox(width: 8.w),
                          CustomText(
                            text: controller.aboutUsEmail.value,
                            fontsize: 16.sp,
                            color: AppColors.textColor3D3D3D,
                          ),
                        ],
                      ),
                  ],
                ),
              ),

            SizedBox(height: 60.h),
          ],
        ),
      ),
    );
  }
}
