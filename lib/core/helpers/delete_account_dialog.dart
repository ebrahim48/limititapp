import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:limit_it_app/controllers/auth_controller.dart';
import 'package:limit_it_app/core/constants/app_colors.dart';
import 'package:limit_it_app/core/helpers/localization_helper.dart';

void showDeleteAccountDialog(BuildContext context) {
  final passwordController = TextEditingController();
  final isPasswordObscure = true.obs;
  final passwordError = ''.obs;

  // Get or create AuthController (ensure it's initialized)
  AuthController authController;
  if (Get.isRegistered<AuthController>()) {
    authController = Get.find<AuthController>();
  } else {
    authController = Get.put(AuthController());
  }

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) => StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: AppColors.backGroundColor,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Warning Icon
                  Container(
                    width: 64.w,
                    height: 64.h,
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.warning_rounded,
                      color: Colors.red,
                      size: 32.sp,
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Title
                  Text(
                    context.l10n.deleteAccount,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor1A1A1A,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8.h),

                  // Description
                  Text(
                    context.l10n.deleteAccountWarning,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textColor5D5D5D,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24.h),

                  // Password Field
                  Obx(() => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: passwordController,
                        obscureText: isPasswordObscure.value,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: AppColors.textColor1A1A1A,
                        ),
                        decoration: InputDecoration(
                          labelText: context.l10n.password,
                          labelStyle: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.textColor5D5D5D,
                          ),
                          hintText: context.l10n.enterPassword,
                          hintStyle: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.borderColor,
                          ),
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: AppColors.textColor5D5D5D,
                            size: 24.sp,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              isPasswordObscure.value
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: AppColors.textColor5D5D5D,
                              size: 24.sp,
                            ),
                            onPressed: () {
                              isPasswordObscure.value = !isPasswordObscure.value;
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(
                              color: passwordError.value.isNotEmpty
                                  ? Colors.red
                                  : AppColors.borderColorD1D1D1,
                              width: 1.w,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(
                              color: passwordError.value.isNotEmpty
                                  ? Colors.red
                                  : AppColors.borderColorD1D1D1,
                              width: 1.w,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(
                              color: passwordError.value.isNotEmpty
                                  ? Colors.red
                                  : AppColors.primaryColor,
                              width: 1.w,
                            ),
                          ),
                          errorText: passwordError.value.isNotEmpty
                              ? passwordError.value
                              : null,
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(
                              color: Colors.red,
                              width: 1.w,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(
                              color: Colors.red,
                              width: 1.w,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 16.h,
                          ),
                        ),
                        onChanged: (value) {
                          // Clear error when user starts typing
                          if (passwordError.value.isNotEmpty) {
                            passwordError.value = '';
                          }
                        },
                      ),
                    ],
                  )),
                  SizedBox(height: 24.h),

                  // Buttons
                  Row(
                    children: [
                      // Cancel Button
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(dialogContext).pop();
                          },
                          child: Container(
                            height: 48.h,
                            decoration: BoxDecoration(
                              color: AppColors.backGroundColor,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: AppColors.borderColorD1D1D1,
                                width: 1.w,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                context.l10n.cancel,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textColor5D5D5D,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),

                      // Delete Button
                      Expanded(
                        child: Obx(() => GestureDetector(
                          onTap: authController.deleteLoading.value
                              ? null
                              : () {
                                  if (passwordController.text.trim().isEmpty) {
                                    passwordError.value = context.l10n.passwordRequired;
                                    return;
                                  }
                                  Navigator.of(dialogContext).pop();
                                  authController.deleteAccount(
                                    password: passwordController.text.trim(),
                                    context: context,
                                  );
                                },
                          child: Container(
                            height: 48.h,
                            decoration: BoxDecoration(
                              color: authController.deleteLoading.value
                                  ? AppColors.borderColorD1D1D1
                                  : Colors.red,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: authController.deleteLoading.value
                                ? Center(
                                    child: SizedBox(
                                      width: 20.w,
                                      height: 20.h,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.w,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                      ),
                                    ),
                                  )
                                : Center(
                                    child: Text(
                                      context.l10n.delete,
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                          ),
                        )),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}
