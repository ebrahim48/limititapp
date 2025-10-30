import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:limit_it_app/core/models/app_model_pin.dart';
import 'package:limit_it_app/core/presentations/widgets/check_box.dart';
import 'custom_text.dart';
import '../../../core/constants/app_colors.dart';

class AppCardItem extends StatelessWidget {
  final AppModel app;
  final int index;
  final bool isSelected;
  final VoidCallback onTap;

  const AppCardItem({
    super.key,
    required this.app,
    required this.index,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 345.w,
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color:
              isSelected ? const Color(0xFFEDD69A) : AppColors.backGroundColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFFD1D1D1), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 48.w,
              height: 48.h,
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: SvgPicture.asset(app.icon, fit: BoxFit.contain),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: app.name,
                    fontsize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  SizedBox(height: 2.h),
                  CustomText(
                    text: "45 min today • 12 Opens",
                    fontsize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF8B8B8B),
                  ),
                ],
              ),
            ),
            CircularCheckbox(isSelected: isSelected),
          ],
        ),
      ),
    );
  }
}
