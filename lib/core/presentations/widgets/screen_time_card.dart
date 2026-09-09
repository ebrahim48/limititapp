import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:limit_it_app/core/config/app_routes/app_routes.dart';
import 'package:limit_it_app/core/constants/app_colors.dart';
import 'package:limit_it_app/core/models/appinfo_model.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_delete_button.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_text.dart';
import 'package:limit_it_app/global/custom_assets/assets.gen.dart';
import 'package:limit_it_app/core/helpers/localization_helper.dart';

class ScreenTimeCard extends StatelessWidget {
  final AppInfo app;
  const ScreenTimeCard({super.key, required this.app});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 345.w,
      height: 80.h,
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFF888888), width: 1),
      ),
      child: Row(
        children: [

          Container(
            width: 48.w,
            height: 48.h,
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: SvgPicture.asset(
              app.icon,
              fit: BoxFit.contain,
            ),
          ),

          SizedBox(width: 12.w),

          // App Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomText(
                  text: app.name,
                  fontsize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textColor3D3D3D,
                ),
                CustomText(
                  text: app.usage,
                  fontsize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF5D5D5D),
                ),
              ],
            ),
          ),


          PopupMenuButton<String>(
            padding: EdgeInsets.zero,
            iconSize: 24.w,
            icon: Assets.icons.moreVert.svg(),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            onSelected: (value) {
              if (value == 'edit') {
                context.pushNamed(AppRoutes.editUsageLimitScreen);
              } else if (value == 'delete') {
                _showDeleteConfirmationDialog(context);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    const Icon(Icons.edit, color: Colors.black54, size: 18),
                    SizedBox(width: 8.w),
                    Text(context.l10n.edit),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete, color: Colors.redAccent, size: 18),
                    SizedBox(width: 8.w),
                    Text(context.l10n.delete),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


/// Delete confirmation dialog
void _showDeleteConfirmationDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        backgroundColor: AppColors.textColorFFFFFF,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 40.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomText(
                text: context.l10n.removeScreenTimeLimit,
                fontsize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textColor3D3D3D,
              ),
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: CustomDeleteTwoButton(
                      title: context.l10n.cancel,
                      bgColor: AppColors.textColorE7E7E7,
                      textColor: AppColors.textColor3D3D3D,
                      onTap: () => Navigator.pop(context),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: CustomDeleteTwoButton(
                      title: context.l10n.delete,
                      bgColor: AppColors.textColorA70D0D,
                      textColor: AppColors.textColorFFFFFF,
                      onTap: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(context.l10n.limitDeletedSuccessfully),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}



