import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_text.dart';

class NotificationItemWidget extends StatelessWidget {
  final String title;
  final String message;
  final String time;
  final String? avatarText;
  final Color? avatarColor;
  final bool isRead;

  const NotificationItemWidget({
    super.key,
    required this.title,
    required this.message,
    required this.time,
    this.avatarText,
    this.avatarColor,
    this.isRead = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isRead ? Colors.white : const Color(0xFFF0FAF4),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isRead ? const Color(0xFFD1D1D1) : const Color(0xFF8DA399),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            width: 48.w,
            height: 48.h,
            decoration: BoxDecoration(
              color: avatarColor ?? const Color(0xFFE5E5E5),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: CustomText(
              text: avatarText ?? 'N',
              fontsize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),

          SizedBox(width: 12.w),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: CustomText(
                        textAlign: TextAlign.start,
                        text: title,
                        fontsize: 16.sp,
                        fontWeight: isRead ? FontWeight.w600 : FontWeight.w700,
                        color: Colors.black,
                        maxline: 1,
                      ),
                    ),
                    SizedBox(width: 5.w),
                    if (!isRead)
                      Container(
                        width: 8.w,
                        height: 8.w,
                        margin: EdgeInsets.only(right: 4.w),
                        decoration: const BoxDecoration(
                          color: Color(0xFF8DA399),
                          shape: BoxShape.circle,
                        ),
                      ),
                    CustomText(
                      text: time,
                      fontsize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF8B8B8B),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                CustomText(
                  textAlign: TextAlign.start,
                  text: message,
                  fontsize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF5D5D5D),
                  maxline: 3,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}