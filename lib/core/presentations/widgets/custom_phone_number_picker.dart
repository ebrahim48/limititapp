// import 'package:autorevive/pregentaitions/widgets/custom_container.dart';
// import 'package:autorevive/pregentaitions/widgets/custom_text.dart';
// import 'package:autorevive/pregentaitions/widgets/custom_text_field.dart';
// import 'package:country_code_picker/country_code_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter/services.dart';
//
// import '../../core/constants/app_colors.dart';
//
// class CustomPhoneNumberPicker extends StatelessWidget {
//   const CustomPhoneNumberPicker({super.key, required this.controller, required this.lebelText});
//
//   final TextEditingController controller;
//   final String lebelText;
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         CustomText(text: lebelText,bottom: 6.h),
//         Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             CustomContainer(
//               bordersColor: AppColors.borderColor,
//               radiusAll: 16.r,
//               child: CountryCodePicker(
//                 padding: EdgeInsets.zero,
//                 onChanged: (country) {
//                   print("Selected country code: ${country.dialCode}");
//                 },
//                 initialSelection: 'US',
//                 showOnlyCountryWhenClosed: false,
//               ),
//             ),
//             SizedBox(width: 8.w),
//             Expanded(
//               child: CustomTextField(
//                 keyboardType: TextInputType.number,
//                 controller: controller,
//                 hintText: 'number',
//                 maxLength: 10,
//                 inputFormatters: [
//                   LengthLimitingTextInputFormatter(10),
//                   FilteringTextInputFormatter.digitsOnly,
//                 ],
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter phone number';
//                   } else if (value.length < 10) {
//                     return 'Phone number must be 10 digits';
//                   } else if (value.length > 10) {
//                     return 'Phone number cannot exceed 10 digits';
//                   }
//                   return null;
//                 },
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }
