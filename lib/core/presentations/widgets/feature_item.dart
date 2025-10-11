import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:limit_it_app/core/models/feature_premium-model.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_text.dart';

class FeatureItem extends StatelessWidget {
  final PremiumFeature feature;

  const FeatureItem({super.key, required this.feature});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20.w,
            height: 20.h,
            decoration: const BoxDecoration(
              color: Color(0xFFDCFCE7),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check, size: 14.r, color: Color(0xFF4C956C)),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: CustomText(
              textAlign: TextAlign.start,
              text: feature.description,
              fontsize: 12.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF6D6D6D),
              maxline: 3,
            ),
          ),
        ],
      ),
    );
  }
}
