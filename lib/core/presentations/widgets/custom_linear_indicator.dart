// import 'package:autorevive/pregentaitions/widgets/custom_container.dart';
// import 'package:autorevive/pregentaitions/widgets/custom_text.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
//
// import '../../core/constants/app_colors.dart';
//
// class CustomLinearIndicator extends StatelessWidget {
//   const CustomLinearIndicator(
//       {super.key, required this.progressValue, this.label});
//
//   final double progressValue;
//   final double? label;
//
//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(builder: (context, constraints) {
//       double maxWidth = constraints.maxWidth;
//       double labelPosition = (progressValue * maxWidth) - 10;
//
//       return Stack(
//         children: [
//           CustomContainer(
//             height: 26.h,
//             paddingAll: 8.h,
//             child: LinearProgressIndicator(
//               color: AppColors.primaryColor,
//               backgroundColor: AppColors.integatorColor,
//               borderRadius: BorderRadius.circular(24.r),
//               minHeight: 9.h,
//               value: progressValue,
//             ),
//           ),
//           Positioned(
//             top: 0,
//             left: labelPosition,
//             child: CustomContainer(
//               color: AppColors.primaryColor,
//               shape: BoxShape.circle,
//               paddingAll: 6.r,
//               child: CustomText(
//                 fontsize: 10.sp,
//                 color: Colors.white,
//                 text: label != null
//                     ? '${label!.toStringAsFixed(0)}%'
//                     : '${(progressValue * 100).toStringAsFixed(0)}%',
//               ),
//             ),
//           ),
//         ],
//       );
//     });
//   }
// }
