import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../../../core/constants/app_colors.dart';

class CustomPinCodeTextField extends StatelessWidget {
  final TextEditingController? textEditingController;

  const CustomPinCodeTextField({super.key, this.textEditingController});

  @override
  Widget build(BuildContext context) {
    return PinCodeTextField(
      appContext: context,
      length: 6,
      controller: textEditingController,
      cursorColor: AppColors.textColor1A1A1A,
      textStyle: const TextStyle(color: AppColors.textColor1A1A1A),
      autoFocus: false,
      obscureText: false,
      keyboardType: TextInputType.number,

      enableActiveFill: true,

      pinTheme: PinTheme(
        shape: PinCodeFieldShape.box,
        borderRadius: BorderRadius.circular(8.r),
        fieldHeight: 57.h,
        fieldWidth: 44.w,

        // Box background
        activeFillColor: AppColors.textColorF6F6F6,
        inactiveFillColor: AppColors.backGroundColor,
        selectedFillColor: AppColors.textColorF6F6F6,

        activeColor: AppColors.primaryColor,
        inactiveColor: AppColors.primaryColor,
        selectedColor: AppColors.primaryColor,
      ),

      onChanged: (value) {},
      onCompleted: (value) {
        textEditingController?.text = value;
      },
    );
  }
}
