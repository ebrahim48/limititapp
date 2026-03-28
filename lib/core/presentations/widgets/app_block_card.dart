import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:limit_it_app/core/constants/app_colors.dart';
import 'package:limit_it_app/core/models/app_bock_item.dart';
import 'package:limit_it_app/core/presentations/widgets/app_icon_widget.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_text.dart';

class AppBlockCard extends StatelessWidget {
  final AppBlockItem app;
  final Future<void> Function(BuildContext, RxString, bool) onSelectTime;

  const AppBlockCard({
    super.key,
    required this.app,
    required this.onSelectTime,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 345.w,
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: const Color(0xFFEDD69A),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            children: [
              _buildAppIcon(),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomText(
                      text: app.name,
                      fontsize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textColor3D3D3D,
                    ),
                    CustomText(
                      text: app.usage,
                      fontsize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textColor5D5D5D,
                    ),
                  ],
                ),
              ),
              Obx(
                () => Switch(
                  value: app.isEnabled.value,
                  activeColor: AppColors.textColorDDA742,
                  activeTrackColor: AppColors.textColor3D3D3D,
                  inactiveThumbColor: AppColors.textColor888888,
                  inactiveTrackColor: AppColors.borderColorD1D1D1,
                  onChanged: (v) => app.isEnabled.value = v,
                ),
              ),
            ],
          ),
        ),

        // Time pickers only visible when enabled
        Obx(
          () =>
              app.isEnabled.value
                  ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTimePicker(
                        context,
                        'Start Time',
                        app.startTime,
                        true,
                      ),
                      SizedBox(height: 16.h),
                      _buildTimePicker(context, 'End Time', app.endTime, false),
                      SizedBox(height: 24.h),
                    ],
                  )
                  : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildAppIcon() {
    return AppIconWidget(
      packageName: app.packageName ?? '',
      preloadedIcon: app.icon is Uint8List ? app.icon as Uint8List : null,
      size: 40,
      borderRadius: 10,
    );
  }

  Widget _buildTimePicker(
    BuildContext context,
    String label,
    RxString time,
    bool isStart,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: label,
          color: AppColors.textColor3D3D3D,
          fontsize: 20.sp,
          fontWeight: FontWeight.w500,
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: () => onSelectTime(context, time, isStart),
          child: Container(
            width: 345.w,
            height: 54.h,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: const Color(0xFFD1D1D1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(
                  () => CustomText(
                    text: time.value,
                    fontsize: 16.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
                Icon(
                  Icons.access_time,
                  size: 24.r,
                  color: const Color(0xFF5D5D5D),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
