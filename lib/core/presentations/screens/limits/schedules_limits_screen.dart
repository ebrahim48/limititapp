import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:limit_it_app/controllers/schedules_limits_controller.dart';
import 'package:limit_it_app/core/constants/app_colors.dart';
import 'package:limit_it_app/core/helpers/localization_helper.dart';
import 'package:limit_it_app/core/helpers/toast_message_helper.dart';
import 'package:limit_it_app/core/presentations/widgets/app_block_card.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_button.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_text.dart';

class SchedulesLimitsScreen extends StatelessWidget {
  const SchedulesLimitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SchedulesLimitsController>();

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
              icon: Icon(Icons.arrow_back, color: Colors.black, size: 20.r),
              onPressed: () => Navigator.pop(context),
            ),
            SizedBox(width: 12.w),
            CustomText(
              text: context.l10n.schedules,
              fontsize: 24.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textColor3D3D3D,
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h),
            
            // App Block Lists Header with Count
            Obx(() {
              final count = controller.blockedAppsCount.value;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomText(
                        text: context.l10n.appBlockLists,
                        color: AppColors.textColor3D3D3D,
                        fontsize: 20.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      if (count > 0)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen,
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: CustomText(
                            text: '$count ${count == 1 ? 'App' : 'Apps'}',
                            color: Colors.white,
                            fontsize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                  if (count == 0 && !controller.isLoading.value)
                    Padding(
                      padding: EdgeInsets.only(top: 16.h),
                      child: CustomText(
                        text: 'No blocked apps yet. Block apps from the home screen to set schedules.',
                        color: AppColors.textColor5D5D5D,
                        fontsize: 14.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                ],
              );
            }),
            
            SizedBox(height: 16.h),
            
            // Loading indicator or app blocks list
            Obx(() {
              if (controller.isLoading.value) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40.h),
                    child: CircularProgressIndicator(
                      color: AppColors.primaryGreen,
                    ),
                  ),
                );
              }

              if (controller.appBlocks.isEmpty) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40.h),
                    child: Column(
                      children: [
                        Icon(
                          Icons.app_blocking_outlined,
                          size: 64.r,
                          color: AppColors.textColor5D5D5D,
                        ),
                        SizedBox(height: 16.h),
                        CustomText(
                          text: 'No blocked apps',
                          color: AppColors.textColor3D3D3D,
                          fontsize: 18.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        SizedBox(height: 8.h),
                        CustomText(
                          text: 'Apps you block will appear here',
                          color: AppColors.textColor5D5D5D,
                          fontsize: 14.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ],
                    ),
                  ),
                );
              }

              final items = controller.isExpanded.value
                  ? controller.appBlocks
                  : controller.appBlocks.take(1).toList();
                  
              return Column(
                children: items
                    .map((app) => AppBlockCard(
                          app: app,
                          onSelectTime: _selectTime,
                        ))
                    .toList(),
              );
            }),
            
            SizedBox(height: 16.h),
            
            // Expand/Collapse button (only show if there are multiple apps)
            Obx(() {
              if (controller.appBlocks.length <= 1) {
                return const SizedBox.shrink();
              }
              return Center(
                child: GestureDetector(
                  onTap: () => controller.isExpanded.value =
                      !controller.isExpanded.value,
                  child: Obx(() => Icon(
                        controller.isExpanded.value
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        size: 24.r,
                        color: Colors.black,
                      )),
                ),
              );
            }),
            
            SizedBox(height: 32.h),
            
            // Save button
            Obx(() {
              final hasEnabledApps = controller.appBlocks.any((app) => app.isEnabled.value);
              return Opacity(
                opacity: hasEnabledApps ? 1.0 : 0.5,
                child: CustomButton(
                  title: context.l10n.saveAppBlock,
                  onpress: hasEnabledApps
                      ? () {
                          controller.saveSchedules().then((_) {
                            ToastMessageHelper.showToastMessage(
                              'Schedules saved successfully!',
                              title: 'Success',
                            );
                          });
                        }
                      : () {},
                ),
              );
            }),
            
            SizedBox(height: 60.h),
          ],
        ),
      ),
    );
  }

  Future<void> _selectTime(
      BuildContext context, RxString timeString, bool isStartTime) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF214432),
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      final hour = picked.hourOfPeriod == 0 ? 12 : picked.hourOfPeriod;
      final minute = picked.minute.toString().padLeft(2, '0');
      final period = picked.period == DayPeriod.am ? 'AM' : 'PM';
      timeString.value = '$hour:$minute $period';
    }
  }
}