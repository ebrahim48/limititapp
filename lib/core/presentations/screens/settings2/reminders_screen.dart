import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:limit_it_app/controllers/reminders_controller.dart';
import 'package:limit_it_app/core/helpers/localization_helper.dart';
import 'package:limit_it_app/global/custom_assets/assets.gen.dart';
import '../../widgets/ui/ui.dart';

/// Notification reminder preferences.
class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final controller = Get.find<RemindersController>();

    return AppScaffold(
      appBar: AppTopBar(title: l10n.reminders),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(bottom: 24.h),
        children: [
          Text(
            l10n.remindersSubtitle,
            style: AppTextStyles.body(color: AppColors.slateGreen),
          ),
          SizedBox(height: 20.h),

          SectionLabel(l10n.daily),
          Obx(
            () => AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  AppToggleRow(
                    leading: AppIconBox(
                      child: AppIcon(Assets.icons.ui.sun,
                          size: 18.w, color: AppColors.fern),
                    ),
                    title: l10n.dailyCheckIn,
                    subtitle: l10n.dailyCheckInSubtitle,
                    value: controller.dailyCheckIn.value,
                    onChanged: controller.setDailyCheckIn,
                  ),
                  if (controller.dailyCheckIn.value) ...[
                    const Divider(height: 1, color: AppColors.haze),
                    _ReminderTimeRow(controller: controller),
                  ],
                ],
              ),
            ),
          ),
          SizedBox(height: 12.h),

          Obx(
            () => AppCard(
              padding: EdgeInsets.zero,
              child: AppToggleRow(
                leading: AppIconBox(
                  child: AppIcon(Assets.icons.ui.target,
                      size: 18.w, color: AppColors.fern),
                ),
                title: l10n.goalAlert,
                subtitle: l10n.goalAlertSubtitle,
                value: controller.goalAlert.value,
                onChanged: controller.setGoalAlert,
              ),
            ),
          ),

          SizedBox(height: 20.h),

          SectionLabel(l10n.weekly),
          Obx(
            () => AppCard(
              padding: EdgeInsets.zero,
              child: AppToggleRow(
                leading: AppIconBox(
                  child: AppIcon(Assets.icons.ui.calendar,
                      size: 18.w, color: AppColors.fern),
                ),
                title: l10n.weeklyReportReminder,
                subtitle: l10n.weeklyReportReminderSubtitle,
                value: controller.weeklyReport.value,
                onChanged: controller.setWeeklyReport,
              ),
            ),
          ),
          SizedBox(height: 12.h),

          Obx(
            () => AppCard(
              padding: EdgeInsets.zero,
              child: AppToggleRow(
                leading: AppIconBox(
                  child: AppIcon(Assets.icons.ui.clock,
                      size: 18.w, color: AppColors.fern),
                ),
                title: l10n.breakReminder,
                subtitle: l10n.breakReminderSubtitle,
                value: controller.breakReminder.value,
                onChanged: controller.setBreakReminder,
              ),
            ),
          ),

          SizedBox(height: 20.h),

          AppSoftCard(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Text(
              l10n.remindersDeliveryNote,
              style: AppTextStyles.small(color: AppColors.fern),
            ),
          ),
        ],
      ),
    );
  }
}

/// "Reminder time  ·  11:00 PM ⏱" row.
class _ReminderTimeRow extends StatelessWidget {
  const _ReminderTimeRow({required this.controller});

  final RemindersController controller;

  Future<void> _pick(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: controller.checkInTime.value,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: AppColors.forestGreen,
                onPrimary: AppColors.white,
              ),
        ),
        child: child!,
      ),
    );
    if (picked != null) await controller.setCheckInTime(picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              l10n.reminderTime,
              style: AppTextStyles.body(color: AppColors.slateGreen),
            ),
          ),
          GestureDetector(
            onTap: () => _pick(context),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.mint,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Obx(
                    () => Text(
                      controller.checkInTime.value.format(context),
                      style: AppTextStyles.h4(color: AppColors.forestGreen),
                    ),
                  ),
                  SizedBox(width: 6.w),
                  AppIcon(Assets.icons.ui.clock,
                      size: 15.w, color: AppColors.fern),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
