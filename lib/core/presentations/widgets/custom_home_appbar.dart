import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:limit_it_app/core/config/app_routes/app_routes.dart';
import 'package:limit_it_app/core/constants/app_colors.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_profile.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_text.dart';
import 'package:limit_it_app/global/custom_assets/assets.gen.dart';

class CustomHomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomHomeAppBar({super.key});

  @override
  Size get preferredSize => Size.fromHeight(70.h);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      leadingWidth: 200.w,
      toolbarHeight: 70.h,
      leading: Row(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 15.w),
            child: CustomProfileImage(
              imagePath:
              "https://templates.joomla-monster.com/joomla30/jm-news-portal/components/com_djclassifieds/assets/images/default_profile.png",
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: CustomText(
              text: 'Ebrahim Hossen',
              color: AppColors.textColor3D3D3D,
              fontsize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: 30.w),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {

                },
                child: Assets.icons.notifications
                    .svg(width: 24.w, height: 24.h),
              ),
              SizedBox(width: 10.w),
              GestureDetector(
                onTap: () {
                  context.pushNamed(AppRoutes.settingsScreen);
                },
                child: Assets.icons.settings.svg(width: 24.w, height: 24.h),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
