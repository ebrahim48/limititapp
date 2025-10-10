import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:limit_it_app/core/config/app_routes/app_routes.dart';
import 'package:limit_it_app/core/constants/app_colors.dart';
import 'package:limit_it_app/core/constants/app_strings.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_button.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_slider.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_text.dart';
import 'package:limit_it_app/global/custom_assets/assets.gen.dart';

class EditUsageLimitScreen extends StatefulWidget {
  const EditUsageLimitScreen({super.key});

  @override
  State<EditUsageLimitScreen> createState() => _EditUsageLimitScreenState();
}

class _EditUsageLimitScreenState extends State<EditUsageLimitScreen> {

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
            CustomText(text: 'Edit Usage Limit',
              fontsize: 24.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textColor3D3D3D,
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),

                CustomText(
                  text: AppString.dailyScreen,
                  fontsize: 20.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textColor3D3D3D,
                ),
                /// ==================================> Slider ==============================>
                SizedBox(height: 20.h),
                CustomSoundSlider(),
                SizedBox(height: 20.h),

                /// =================== Facebook Section ===================
                _buildAppLimitSection(
                  icon: Assets.icons.facebook.svg(width: 32.w, height: 32.h),
                  appName: "Facebook",
                  opensValue: facebookOpens,
                  durationValue: facebookDuration,
                  onOpensChanged: (value) {
                    setState(() => facebookOpens = value!);
                  },
                  onDurationChanged: (value) {
                    setState(() => facebookDuration = value!);
                  },
                ),
                SizedBox(height: 30.h),

                /// =================== Netflix Section ===================
                _buildAppLimitSection(
                  icon: Assets.icons.netflix.svg(width: 32.w, height: 32.h),
                  appName: "Netflix",
                  opensValue: netflixOpens,
                  durationValue: netflixDuration,
                  onOpensChanged: (value) {
                    setState(() => netflixOpens = value!);
                  },
                  onDurationChanged: (value) {
                    setState(() => netflixDuration = value!);
                  },
                ),
                SizedBox(height: 48.h),
                CustomButton(
                  title: 'Next',
                  onpress: () {
                    context.pushNamed(AppRoutes.editTimerSettingsScreen);
                  },),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
  double totalScreenTime = 120;
  String facebookOpens = '5 Times';
  String facebookDuration = '30 Mins';
  String netflixOpens = '5 Times';
  String netflixDuration = '30 Mins';

  final List<String> opensList = ['1 Time', '3 Times', '5 Times', '10 Times'];
  final List<String> durationList = ['15 Mins', '30 Mins', '45 Mins', '60 Mins'];

  Widget _buildAppLimitSection({
    required Widget icon,
    required String appName,
    required String opensValue,
    required String durationValue,
    required ValueChanged<String?> onOpensChanged,
    required ValueChanged<String?> onDurationChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            icon,
            SizedBox(width: 12.w),
            CustomText(
              text: appName,
              fontsize: 24.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textColor3D3D3D,
            ),
          ],
        ),
        SizedBox(height: 12.h),
        CustomText(
          text: "Daily Opens Limit",
          fontsize: 16.sp,
          color: AppColors.textColor3D3D3D,
          fontWeight: FontWeight.w400,
        ),
        SizedBox(height: 8.h),
        _buildDropdown(opensValue, opensList, onOpensChanged),
        SizedBox(height: 16.h),
        CustomText(
          text: "Session Duration",
          fontsize: 16.sp,
          color: AppColors.textColor3D3D3D,
          fontWeight: FontWeight.w400,
        ),
        SizedBox(height: 8.h),
        _buildDropdown(durationValue, durationList, onDurationChanged),
      ],
    );
  }

  Widget _buildDropdown(
      String selectedValue,
      List<String> items,
      ValueChanged<String?> onChanged,
      ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderColorD1D1D1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedValue,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey.shade600),
          items: items
              .map((value) => DropdownMenuItem(
            value: value,
            child: CustomText(text: value),
          ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

}
