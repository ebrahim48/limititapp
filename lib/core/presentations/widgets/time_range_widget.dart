import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_text.dart';

void showTimeRangeSelector(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    ),
    builder: (context) {
      return Container(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTimeOption(context, 'Today'),
            Divider(),
            _buildTimeOption(context, 'Weekly'),
            Divider(),
            _buildTimeOption(context, 'Monthly'),
            SizedBox(height: 20.h),
          ],
        ),
      );
    },
  );
}

Widget _buildTimeOption(BuildContext context, String option) {
  return ListTile(
    title: CustomText(
      text: option,
      fontsize: 16.sp,
      fontWeight: FontWeight.w500,
      color: Colors.black,
    ),
    trailing: Icon(Icons.chevron_right, color: Colors.grey),
    onTap: () {
      Navigator.pop(context);
      debugPrint('Selected: $option');
    },
  );
}
