import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:limit_it_app/controllers/auth_controller.dart';
import 'package:limit_it_app/core/constants/app_colors.dart';
import 'package:limit_it_app/core/helpers/localization_helper.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_button.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_text.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_text_field.dart';
import 'package:limit_it_app/global/custom_assets/assets.gen.dart';

class ForgetPasswordScreen extends StatefulWidget {
  ForgetPasswordScreen({super.key,required this.email});

  final String email;

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  // Controllers
  final TextEditingController emailCtrl = TextEditingController();
  final GlobalKey<FormState> _logKey = GlobalKey<FormState>();

  @override
  void initState() {
    debugPrint("====================${widget.email}");
    setState(() {
      emailCtrl.text = widget.email;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

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
              text: context.l10n.forgetPasswordTitle,
              color: AppColors.textColor3D3D3D,
              fontsize: 24.sp,
              fontWeight: FontWeight.w500,
            ),
          ],
        ),
      ),
      body: Stack(
        children: [

          Positioned(
            top: 18.h,
            right: 20.w,
            child: Container(
              width: 259.w,
              height: 195.h,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                  ),
                ),
              ),
            ),
          ),


          Positioned(
            bottom: 0,
            left: 0,
            child: Container(
              width: 158.w,
              height: 219.h,
              decoration: BoxDecoration(
                color: AppColors.textColor803D20.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                  ),
                ),
              ),
            ),
          ),


          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Form(
                  key: _logKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [




                      SizedBox(height: 32.h),

                      CustomTextField(
                        hintextColor: AppColors.textColor5D5D5D,
                        controller: emailCtrl,
                        hintText: context.l10n.email,
                        prefixIcon: Assets.icons.email.svg(),
                        isEmail: true,
                      ),






                      SizedBox(height: 32.h),


                      Obx(()=>
                         CustomButton(
                           loading: authController.forgotLoading.value,
                          title: context.l10n.getOtp,
                          onpress: () {
                            if(_logKey.currentState?.validate()??true){
                              authController.handleForgot(
                                  emailCtrl.text,
                                  "forgot",
                                  context: context);
                            }
                          },
                        ),
                      ),
                      SizedBox(height: 12.h),

                      SizedBox(height: 40.h),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}