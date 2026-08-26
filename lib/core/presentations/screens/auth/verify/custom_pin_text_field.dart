import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../widgets/ui/ui.dart';

class CustomPinCodeTextField extends StatelessWidget {
  final TextEditingController? textEditingController;

  const CustomPinCodeTextField({super.key, this.textEditingController});

  @override
  Widget build(BuildContext context) {
    return PinCodeTextField(
      appContext: context,
      length: 6,
      controller: textEditingController,
      cursorColor: AppColors.forestGreen,
      textStyle: AppTextStyles.h3(color: AppColors.ink),
      autoFocus: false,
      obscureText: false,
      keyboardType: TextInputType.number,
      enableActiveFill: true,
      animationType: AnimationType.scale,
      animationDuration: const Duration(milliseconds: 160),
      pinTheme: PinTheme(
        shape: PinCodeFieldShape.box,
        borderRadius: BorderRadius.circular(12.r),
        fieldHeight: 56.h,
        fieldWidth: 48.w,
        borderWidth: 1.4,
        activeFillColor: AppColors.mint,
        inactiveFillColor: AppColors.white,
        selectedFillColor: AppColors.white,
        activeColor: AppColors.leafGreen,
        inactiveColor: AppColors.haze,
        selectedColor: AppColors.leafGreen,
      ),
      onChanged: (value) {},
      onCompleted: (value) {
        textEditingController?.text = value;
      },
    );
  }
}
