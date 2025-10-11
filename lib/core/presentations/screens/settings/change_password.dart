import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:limit_it_app/core/config/app_routes/app_routes.dart';
import 'package:limit_it_app/core/constants/app_colors.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_button.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_text.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_text_field.dart';
import 'package:limit_it_app/global/custom_assets/assets.gen.dart';



class ChangePasswordScreen extends StatelessWidget {
   ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(Icons.arrow_back, color: Colors.black, size: 20.r),
              onPressed: () => Navigator.pop(context),
            ),
            SizedBox(width: 12.w),
            CustomText(
              text: 'Change Password',
              fontsize: 24.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textColor3D3D3D,
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                SizedBox(height: 25.h),

                CustomTextField(
                    hintextColor: AppColors.textColor5D5D5D,
                    controller: oldPassCtrl,
                    prefixIcon: Assets.icons.pass.svg(),
                    hintText: "Old Password",
                    isPassword: true),

                CustomTextField(
                    hintextColor: AppColors.textColor5D5D5D,
                    controller: setNewPassCtrl,
                    prefixIcon: Assets.icons.pass.svg(),
                    hintText: "Set New Password",
                    isPassword: true),
                CustomTextField(
                  hintextColor: AppColors.textColor5D5D5D,
                  controller: reenterNewPassCtrl,
                  prefixIcon: Assets.icons.pass.svg(),
                  hintText: "Re-Enter New Password",
                  isPassword: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      Future.delayed(Duration.zero, () => isMatched.value = false);
                      return 'Please enter your confirm password';
                    } else if (setNewPassCtrl.text == value) {
                      Future.delayed(Duration.zero, () => isMatched.value = true);
                      return null;
                    } else {
                      Future.delayed(Duration.zero, () => isMatched.value = false);
                      return 'Password Not Matching';
                    }
                  },
                  onChanged: (value) {
                    isMatched.value = setNewPassCtrl.text == value;
                  },
                ),
                Obx(() => Align(
                    alignment: Alignment.centerLeft,
                    child: CustomText(
                      text: isMatched.value ? 'Password Matched' : "",
                      color: Colors.green,
                      fontsize: 14.sp,
                    ))),

                GestureDetector(
                  onTap: () {
                    context.pushNamed(AppRoutes.forgetPasswordScreen);
                  },
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: CustomText(
                      textAlign: TextAlign.start,
                      text: 'Forget password?',
                      color: AppColors.primaryColor,
                      fontsize: 12.sp,

                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                CustomButton(
                    title: "Update Password",
                    onpress: () {

                    }),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
  final TextEditingController oldPassCtrl = TextEditingController();
  final TextEditingController setNewPassCtrl = TextEditingController();
  final TextEditingController reenterNewPassCtrl = TextEditingController();



  RxBool isMatched = false.obs;
  RxBool isObscureConfirmPassword = true.obs;
  toggleIsObscureConfirmPassword() {
    isObscureConfirmPassword.value = !isObscureConfirmPassword.value;
  }

  ismMatchedColor() {
    isMatched.value = !isMatched.value;
  }

  RxBool isChecked = false.obs;

}
