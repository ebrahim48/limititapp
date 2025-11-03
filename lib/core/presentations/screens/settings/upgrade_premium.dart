import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:limit_it_app/controllers/upgrade_premium_controller.dart';
import 'package:limit_it_app/core/constants/app_colors.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_button.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_text.dart';
import 'package:limit_it_app/core/presentations/widgets/feature_item.dart';


class UpgradePremiumScreen extends StatelessWidget {
  const UpgradePremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UpgradePremiumController>();

    return Scaffold(
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 25.h),
                _buildPlanHeader(controller),
                SizedBox(height: 16.h),
                _buildFeatureList(controller),
                SizedBox(height: 32.h),
                _buildSubscribeButton(context),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) => AppBar(
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
          text: 'Upgrade to premium',
          fontsize: 24.sp,
          fontWeight: FontWeight.w500,
          color: AppColors.textColor3D3D3D,
        ),
      ],
    ),
  );

  Widget _buildPlanHeader(UpgradePremiumController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: 'Premium Monthly Plan',
          fontsize: 20.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textColor3D3D3D,
        ),
        SizedBox(height: 8.h),
        CustomText(
          textAlign: TextAlign.start,
          text: '€1/month',
          fontsize: 32.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryColor526E4B,
        ),
      ],
    );
  }

  Widget _buildFeatureList(UpgradePremiumController controller) {
    return Container(
      width: 345.w,
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Obx(() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: controller.features
            .map((feature) => FeatureItem(feature: feature))
            .toList(),
      )),
    );
  }

  Widget _buildSubscribeButton(BuildContext context) {
    return CustomButton(
      title: 'Subscribe Now',
      onpress: () => _showSubscriptionConfirmation(context),
    );
  }


  void _showSubscriptionConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        title: CustomText(
          text: 'Confirm Subscription',
          fontsize: 18.sp,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        content: CustomText(
          text: 'Subscribe to Premium Monthly Plan for €1/month?',
          fontsize: 14.sp,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF5D5D5D),
          maxline: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: CustomText(text: 'Cancel', color: Colors.grey),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF214432),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Subscription successful!'),
                  backgroundColor: Color(0xFF4C956C),
                ),
              );
            },
            child:  CustomText(text: 'Subscribe', color: Colors.white),
          ),
        ],
      ),
    );
  }
}
