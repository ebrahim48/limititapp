import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:limit_it_app/core/config/app_routes/app_routes.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_text.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_text_field.dart';
import 'package:limit_it_app/global/custom_assets/assets.gen.dart';
import '../../../../../core/constants/app_colors.dart';


class ViewProfileScreen extends StatelessWidget {
  ViewProfileScreen({super.key});

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
              icon: Icon(Icons.arrow_back, color: Colors.black, size: 24.r),
              onPressed: () => Navigator.pop(context),
            ),
            SizedBox(width: 12.w),
            CustomText(
              text: "View Profile",
              color: AppColors.textColor3D3D3D,
              fontsize: 24.sp,
              fontWeight: FontWeight.w500,
            ),
          ],
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 10.w),
            child: IconButton(
              onPressed: () {
                context.pushNamed(AppRoutes.editProfileScreen);
              },
              icon: Assets.icons.edit.svg(),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned(
            top: 18.h,
            left: 109.w,
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
          Container(
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
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 24.h),
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(40.r),
                      child: Image.asset(
                        "assets/images/viewProfile.png",
                        width: 90.w,
                        height: 90.h,
                        fit: BoxFit.cover,
                      ),),
                  ),
                  SizedBox(height: 8.h),
                  CustomText(
                    text: 'Ebrahim Hossen',
                    fontsize: 24.sp,
                    color: AppColors.textColor3D3D3D,
                  ),
                  CustomText(
                    text: 'Joined in 24 May',
                    fontsize: 12.sp,
                    color: AppColors.textColor5D5D5D,
                  ),

                  SizedBox(height: 48.h),

                  CustomTextField(
                      hintextColor: AppColors.textColor5D5D5D,
                      controller: nameCtrl,
                      hintText: "Ebrahim",
                      prefixIcon: Assets.icons.profileview.svg()),
                  CustomTextField(
                      hintextColor: AppColors.textColor5D5D5D,
                      controller: emailCtrl,
                      hintText: "ebrahim.cse.bu@gmail.com",
                      prefixIcon: Assets.icons.email.svg(),
                      isEmail: true),




                  SizedBox(height: 60.h),


                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();


}