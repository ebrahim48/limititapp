import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:limit_it_app/core/config/app_routes/app_routes.dart';
import 'package:limit_it_app/core/constants/app_colors.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_button.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_text.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_text_field.dart';
import 'package:limit_it_app/global/custom_assets/assets.gen.dart';
import 'package:limit_it_app/controllers/auth_controller.dart';



class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  late final AuthController _authController;
  final TextEditingController oldPassCtrl = TextEditingController();
  final TextEditingController setNewPassCtrl = TextEditingController();
  final TextEditingController reenterNewPassCtrl = TextEditingController();

  bool isMatched = false;
  bool isChecked = false;

  @override
  void initState() {
    super.initState();
    // Initialize AuthController if not already done
    if (!Get.isRegistered<AuthController>()) {
      Get.put(AuthController());
    }
    _authController = Get.find<AuthController>();
  }

  @override
  void dispose() {
    oldPassCtrl.dispose();
    setNewPassCtrl.dispose();
    reenterNewPassCtrl.dispose();
    super.dispose();
  }

  void _handleChangePassword() {
    // Validate passwords match
    if (setNewPassCtrl.text != reenterNewPassCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('New passwords do not match'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate password strength
    if (setNewPassCtrl.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be at least 6 characters'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Call API
    _authController.changePassword(
      currentPassword: oldPassCtrl.text,
      newPassword: setNewPassCtrl.text,
      confirmPassword: reenterNewPassCtrl.text,
      context: context,
    );
  }

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

                Obx(() => CustomTextField(
                    hintextColor: AppColors.textColor5D5D5D,
                    controller: oldPassCtrl,
                    prefixIcon: Assets.icons.pass.svg(),
                    hintText: "Old Password",
                    isPassword: _authController.isObscure.value,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _authController.isObscure.value
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppColors.textColor5D5D5D,
                      ),
                      onPressed: () {
                        _authController.toggleIsObscure();
                      },
                    ),
                )),

                SizedBox(height: 16.h),

                Obx(() => CustomTextField(
                    hintextColor: AppColors.textColor5D5D5D,
                    controller: setNewPassCtrl,
                    prefixIcon: Assets.icons.pass.svg(),
                    hintText: "Set New Password",
                    isPassword: _authController.isObscureConfirmPassword.value,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _authController.isObscureConfirmPassword.value
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppColors.textColor5D5D5D,
                      ),
                      onPressed: () {
                        _authController.toggleIsObscureConfirmPassword();
                      },
                    ),
                )),

                SizedBox(height: 16.h),

                Obx(() => CustomTextField(
                  hintextColor: AppColors.textColor5D5D5D,
                  controller: reenterNewPassCtrl,
                  prefixIcon: Assets.icons.pass.svg(),
                  hintText: "Re-Enter New Password",
                  isPassword: _authController.isObscureConfirmPassword.value,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _authController.isObscureConfirmPassword.value
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: AppColors.textColor5D5D5D,
                    ),
                    onPressed: () {
                      _authController.toggleIsObscureConfirmPassword();
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      Future.delayed(Duration.zero, () => setState(() {
                        isMatched = false;
                      }));
                      return 'Please confirm your password';
                    } else if (setNewPassCtrl.text == value) {
                      Future.delayed(Duration.zero, () => setState(() {
                        isMatched = true;
                      }));
                      return null;
                    } else {
                      Future.delayed(Duration.zero, () => setState(() {
                        isMatched = false;
                      }));
                      return 'Password Not Matching';
                    }
                  },
                  onChanged: (value) {
                    setState(() {
                      isMatched = setNewPassCtrl.text == value;
                    });
                  },
                )),

                Align(
                    alignment: Alignment.centerLeft,
                    child: CustomText(
                      text: isMatched ? 'Password Matched' : "",
                      color: Colors.green,
                      fontsize: 14.sp,
                    )),

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

                Obx(() => CustomButton(
                    title: _authController.changePasswordLoading.value 
                        ? 'Updating...' 
                        : 'Update Password',
                    onpress: () {
                      if (!_authController.changePasswordLoading.value) {
                        _handleChangePassword();
                      }
                    },
                )),

                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
