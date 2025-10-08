import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:limit_it_app/core/config/app_routes/app_routes.dart';
import 'package:limit_it_app/core/constants/app_colors.dart';
import 'package:limit_it_app/core/constants/app_strings.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_text.dart';

class SelectAppsManageScreen extends StatefulWidget {
  const SelectAppsManageScreen({super.key});

  @override
  State<SelectAppsManageScreen> createState() => _SelectAppsManageScreenState();
}

class _SelectAppsManageScreenState extends State<SelectAppsManageScreen> {

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
            CustomText(text: AppString.selectApp,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),
              SizedBox(
                height: 48.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  separatorBuilder: (_, __) => SizedBox(width: 8.w),
                  itemCount: days.length + 1,
                  itemBuilder: (context, index) {
                    if (index == days.length) {
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDEEDE2),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Row(
                          children: [
                            Checkbox(
                              value: allSelected,
                              activeColor: const Color(0xFF214432),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              onChanged: (val) => toggleAllDays(val ?? false),
                            ),
                            CustomText(text:
                              AppString.all,
                             fontsize: 10.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textColor3D3D3D,
                            ),
                          ],
                        ),
                      );
                    }

                    final day = days[index];
                    final isSelected = selectedDays.contains(day);

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            selectedDays.remove(day);
                          } else {
                            selectedDays.add(day);
                          }
                          allSelected = selectedDays.length == days.length;
                        });
                      },
                      child: Container(
                        width: 48.w,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF214432)
                              : const Color(0xFFDEEDE2),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: CustomText(text:
                          day,
                          color: isSelected ? AppColors.textColorF6F6F6 : AppColors.textColor3D3D3D,
                          fontWeight: FontWeight.w400,
                          fontsize: 10.sp,
                        ),


                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: 24.h),


              Expanded(
                child: ListView.builder(
                  itemCount: apps.length,
                  itemBuilder: (context, index) {
                    final app = apps[index];
                    final isSelected = selectedApps.contains(app['name']);

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            selectedApps.remove(app['name']);
                          } else {
                            selectedApps.add(app['name']);
                          }
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 12.h),
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 12.h),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFEDD69A)
                              : AppColors.backGroundColor,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: const Color(0xFFD1D1D1)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32.w,
                              height: 32.w,
                              padding: EdgeInsets.all(4.w),
                              child: SvgPicture.asset(
                                app['icon'],
                                fit: BoxFit.contain,
                              ),
                            ),
                            SizedBox(width: 12.w),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    app['name'],
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    "45 min today • 12 Opens",
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Container(
                              width: 20.w,
                              height: 20.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.grey,
                                  width: 1.4,
                                ),
                                color: isSelected
                                    ? const Color(0xFF214432)
                                    : Colors.transparent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              /// ===================================> Continue Button ===============================>
              GestureDetector(
                onTap: () {
                  context.pushNamed(AppRoutes.setUsageLimitScreen);
                },
                child: Container(
                  width: double.infinity,
                  height: 56.h,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFF214432),
                    borderRadius: BorderRadius.circular(28.r),
                  ),
                  child: CustomText(text:
                    "Continue (${selectedApps.length} apps Selected)",
                    fontsize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textColorF6F6F6,
                  ),
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }


  final List<String> days = ['SAT', 'SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI'];
  bool allSelected = false;
  Set<String> selectedDays = {'WED','TUE'};

  final List<Map<String, dynamic>> apps = [
    {'name': 'Instagram', 'icon': 'assets/icons/instagram.svg'},
    {'name': 'Facebook', 'icon': 'assets/icons/facebook.svg'},
    {'name': 'Twitter', 'icon': 'assets/icons/twitter.svg'},
    {'name': 'Youtube', 'icon': 'assets/icons/youtube.svg'},
    {'name': 'Snapchat', 'icon': 'assets/icons/snapshot.svg'},
    {'name': 'Netflix', 'icon': 'assets/icons/netflix.svg'},
  ];

  Set<String> selectedApps = {'Facebook', 'Netflix'};

  void toggleAllDays(bool value) {
    setState(() {
      allSelected = value;
      if (allSelected) {
        selectedDays = days.toSet();
      } else {
        selectedDays.clear();
      }
    });
  }

}
