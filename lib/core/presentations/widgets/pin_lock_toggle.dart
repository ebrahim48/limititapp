import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/presentations/widgets/custom_text.dart';

class PinLockToggle extends StatelessWidget {
  final RxBool isPinLockEnabled;
  const PinLockToggle({super.key, required this.isPinLockEnabled});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 345.w,
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: const Color(0xFFEDD69A),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText(
            text: 'Pin Lock',
            fontsize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          Obx(() => GestureDetector(
            onTap: () => isPinLockEnabled.value = !isPinLockEnabled.value,
            child: Container(
              width: 48.w,
              height: 24.h,
              decoration: BoxDecoration(
                color: isPinLockEnabled.value
                    ? const Color(0xFF3D3D3D)
                    : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(100.r),
              ),
              alignment: isPinLockEnabled.value
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              child: Container(
                width: 20.w,
                height: 20.h,
                decoration: BoxDecoration(
                  color: isPinLockEnabled.value
                      ? const Color(0xFFDDA742)
                      : Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }
}
