import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:limit_it_app/controllers/schedules_limits_controller.dart';
import 'package:limit_it_app/core/constants/app_colors.dart';
import 'package:limit_it_app/core/helpers/localization_helper.dart';
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
            CustomText(
              text: context.l10n.appBlockLists,
              color: AppColors.textColor3D3D3D,
              fontsize: 20.sp,
              fontWeight: FontWeight.w500,
            ),
            SizedBox(height: 16.h),
            Obx(() {
              final items = controller.isExpanded.value
                  ? controller.appBlocks
                  : [controller.appBlocks.first];
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
            Center(
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
            ),
            SizedBox(height: 32.h),
            CustomButton(
              title: context.l10n.saveAppBlock,
              onpress: () {
                controller.appBlocks.forEach((app) {
                  if (app.isEnabled.value) {
                    print(
                        '${app.name}: ${app.startTime.value} - ${app.endTime.value}');
                  }
                });
              },
            ),
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
