import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:limit_it_app/core/constants/app_colors.dart';

import 'custom_network_image.dart';

class CustomProfileImage extends StatelessWidget {

  final String imagePath;

  const CustomProfileImage({
    super.key,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32.w,
      height: 32.h,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primaryColor4C956C,
          width: 3, // border width
        ),
      ),
      child: ClipOval(
        child: CustomNetworkImage(
          imageUrl: imagePath,
          borderRadius: BorderRadius.zero,
        ),

        // Image.network(
        //   imageUrl,
        //   fit: BoxFit.cover,
        // ),
      ),
    );
  }
}
