import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:limit_it_app/controllers/upgrade_premium_controller.dart';
import 'package:limit_it_app/core/constants/app_colors.dart';
import 'package:limit_it_app/core/helpers/localization_helper.dart';
import 'package:limit_it_app/core/models/plan_model.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_button.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_text.dart';
import 'package:limit_it_app/core/services/plan_service.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';


class UpgradePremiumScreen extends StatelessWidget {
  const UpgradePremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UpgradePremiumController>();

    return Scaffold(
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return _buildLoadingState();
          } else if (controller.isError.value) {
            return _buildErrorState(context, controller);
          } else {
            return _buildPlanList(context, controller);
          }
        }),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: SpinKitFadingCircle(
        color: AppColors.primaryGreen,
        size: 40.r,
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, UpgradePremiumController controller) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60.r,
            ),
            SizedBox(height: 16.h),
            CustomText(
              text: 'Failed to load plans',
              fontsize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textColor3D3D3D,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            CustomText(
              text: controller.errorMessage.value,
              fontsize: 14.sp,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            CustomButton(
              title: 'Retry',
              onpress: () => controller.fetchPlans(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanList(BuildContext context, UpgradePremiumController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.h),
            ...controller.plans.map((plan) => _buildPlanCard(context, controller, plan)),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, UpgradePremiumController controller, PlanModel plan) {
    final isSelected = controller.selectedPlan.value == plan.id;
    
    return GestureDetector(
      onTap: () => controller.changePlan(plan.id),
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.backGroundColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor526E4B : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        textAlign: TextAlign.start,
                        text: plan.name,
                        fontsize: 20.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textColor3D3D3D,
                      ),
                      SizedBox(height: 4.h),
                      CustomText(
                        textAlign: TextAlign.start,
                        text: PlanService.getPlanDurationText(plan.duration),
                        fontsize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
                Radio<String>(
                  value: plan.id,
                  groupValue: controller.selectedPlan.value,
                  onChanged: (value) => controller.changePlan(value!),
                  activeColor: AppColors.primaryColor526E4B,
                ),
              ],
            ),
            SizedBox(height: 12.h),
            CustomText(
              textAlign: TextAlign.start,
              text: PlanService.formatPrice(plan.price),
              fontsize: 28.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryColor526E4B,
            ),
            SizedBox(height: 4.h),
            CustomText(
              textAlign: TextAlign.start,
              text: 'Price per month • ${plan.limits.maxApps} apps',
              fontsize: 12.sp,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
            SizedBox(height: 16.h),
            Divider(color: Colors.grey.shade300),
            SizedBox(height: 12.h),
            ...plan.benefits.map((benefit) => Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: AppColors.primaryGreen,
                    size: 18.r,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: CustomText(
                      textAlign: TextAlign.start,
                      text: benefit,
                      fontsize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textColor3D3D3D,
                    ),
                  ),
                ],
              ),
            )),
            SizedBox(height: 16.h),
            CustomButton(
              title: context.l10n.subscribeNow,
              onpress: () {},
            ),
          ],
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
          text: context.l10n.upgradeToPremium,
          fontsize: 24.sp,
          fontWeight: FontWeight.w500,
          color: AppColors.textColor3D3D3D,
        ),
      ],
    ),
  );
}
