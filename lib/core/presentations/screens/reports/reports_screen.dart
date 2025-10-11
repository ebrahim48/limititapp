import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:limit_it_app/core/constants/app_colors.dart';
import 'package:limit_it_app/core/constants/app_data_helper.dart';
import 'package:limit_it_app/core/presentations/widgets/background_layers.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_button.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_text.dart';
import 'package:limit_it_app/core/presentations/widgets/daily_usage_card.dart';
import 'package:limit_it_app/core/presentations/widgets/your_appcard-widget.dart';
import 'package:limit_it_app/global/custom_assets/assets.gen.dart';



class ReportsScreen extends StatelessWidget {
  ReportsScreen({super.key});


  final apps = AppDataHelper.dailyApps;
  final myApps = AppDataHelper.yourApps;


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
            SizedBox(width: 24.w),
            CustomText(
              text: 'Reports',
              fontsize: 24.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textColor3D3D3D,
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          BackgroundBlurLayers(),
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                SizedBox(height: 24.h),
                DailyUsageCard(dailyApps: AppDataHelper.dailyApps),

                SizedBox(height: 24.h),
                CustomText(
                  text: 'Most Used Apps',
                  fontsize: 20.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textColor2C2C2C,
                ),

                SizedBox(height: 12.h),
                ...AppDataHelper.yourApps.map((app) => YourAppCard(app: app)).toList(),
                SizedBox(height: 24.h),
                CustomButton(
                    title: 'Download Report',
                    onpress: () {

                    },
                ),
                SizedBox(height: 29.h),
                _buildAnnouncementCard(),
                SizedBox(height: 80.h),
              ],
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildAnnouncementCard() {
    return Container(
      width: 345.w,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Color(0xFFEDD69A),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: Container(
              width: 80.w,
              height: 80.h,
              color: Colors.blue.shade100,
              child:  Assets.images.banner.image(
                width: 74.w,
                height: 74.h,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  textAlign: TextAlign.start,
                  text: 'Big Announce for Figma\nmake',
                  fontsize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textColor3D3D3D,
                  maxline: 2,
                ),
                SizedBox(height: 4.h),
                CustomText(
                  textAlign: TextAlign.start,
                  text: 'Stay focused, take control\nof your time',
                  fontsize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textColor3D3D3D,
                  maxline: 2,
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }
}
