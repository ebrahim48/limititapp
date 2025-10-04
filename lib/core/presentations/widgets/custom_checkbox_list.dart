// import 'package:autorevive/pregentaitions/widgets/custom_text.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
//
// import '../../core/constants/app_colors.dart';
//
// class CustomCheckboxList extends StatefulWidget {
//   const CustomCheckboxList({super.key, required this.items,  this.isAllChecked = false});
//
//   final Map<String, bool> items;
//   final bool isAllChecked;
//
//   @override
//   State<CustomCheckboxList> createState() => _CustomCheckboxListState();
// }
//
// class _CustomCheckboxListState extends State<CustomCheckboxList> {
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: widget.items.entries.map((entry) {
//         return Row(
//           children: [
//             Checkbox(
//               value: entry.value,
//               activeColor: AppColors.primaryColor,
//               side: const BorderSide(color: AppColors.primaryColor),
//               onChanged: (val) {
//                 setState(() {
//                   if(!widget.isAllChecked) {
//                     widget.items.updateAll((key, value) => false);
//                   }
//                   widget.items[entry.key] = val ?? false;
//                 });
//               },
//             ),
//             Expanded(
//                 child: CustomText(
//                   fontsize: 13.sp,
//                     maxline: 3, textAlign: TextAlign.start, text: entry.key)),
//           ],
//         );
//       }).toList(),
//     );
//   }
// }
