import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:limit_it_app/core/config/app_routes/app_routes.dart';
import 'package:limit_it_app/core/helpers/localization_helper.dart';
import 'package:limit_it_app/core/presentations/widgets/ui/ui.dart';

class ResetPasswordScreen extends StatelessWidget {
  ResetPasswordScreen({super.key});

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController newPassWordCtrl = TextEditingController();
  final TextEditingController confirmNewPassWordCtrl = TextEditingController();

  final RxBool isMatched = false.obs;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppScaffold(
      appBar: AppTopBar(title: l10n.resetPassword),
      scrollable: true,
      resizeToAvoidBottomInset: true,
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 8.h),
            Text(
              l10n.resetPasswordSubtitle,
              style: AppTextStyles.body(color: AppColors.slateGreen),
            ),
            SizedBox(height: 28.h),

            AppTextField(
              controller: newPassWordCtrl,
              label: l10n.setNewPassword,
              hintText: '••••••••',
              isPassword: true,
            ),
            SizedBox(height: 16.h),

            AppTextField(
              controller: confirmNewPassWordCtrl,
              label: l10n.confirmNewPassword,
              hintText: '••••••••',
              isPassword: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  isMatched.value = false;
                  return 'Please enter your confirm password';
                } else if (newPassWordCtrl.text == value) {
                  isMatched.value = true;
                  return null;
                } else {
                  isMatched.value = false;
                  return 'Password Not Matching';
                }
              },
              onChanged: (value) {
                isMatched.value = newPassWordCtrl.text == value;
              },
            ),

            Obx(
              () => isMatched.value
                  ? Padding(
                      padding: EdgeInsets.only(top: 8.h, left: 2.w),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            size: 15.sp,
                            color: AppColors.leafGreen,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            l10n.passwordMatched,
                            style: AppTextStyles.caption(
                              color: AppColors.fern,
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            SizedBox(height: 28.h),

            AppButton(
              label: l10n.resetPassword,
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  context.pushNamed(AppRoutes.resetSuccessFullyScreen);
                }
              },
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
}
