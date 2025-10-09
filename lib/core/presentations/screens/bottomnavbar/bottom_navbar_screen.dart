import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:limit_it_app/core/presentations/screens/limits/limits_screen.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../global/custom_assets/assets.gen.dart';
import '../home/home_screen.dart';

class BottomNavBarScreen extends StatefulWidget {
  const BottomNavBarScreen({super.key});

  @override
  State<BottomNavBarScreen> createState() => _BottomNavBarScreenState();
}

class _BottomNavBarScreenState extends State<BottomNavBarScreen> {
  final List<Widget> screens = [
     HomeScreen(),
     LimitsScreen(),
  ];

  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        backgroundColor: AppColors.primaryColor,
        type: BottomNavigationBarType.fixed,
        elevation: 1,
        selectedItemColor: AppColors.textColorFFFFFF,
        unselectedItemColor: AppColors.borderColor,
        selectedLabelStyle: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w400,
        ),
        items: [
          BottomNavigationBarItem(
            icon: Assets.icons.home.svg(
              color: AppColors.borderColor,
              width: 22.w,
              height: 22.h,
            ),
            activeIcon: Assets.icons.home.svg(
              color: AppColors.textColorFFFFFF,
              width: 22.w,
              height: 22.h,
            ),
            label: "Homepage",
          ),
          BottomNavigationBarItem(
            icon: Assets.icons.limit.svg(
              color: AppColors.borderColor,
              width: 22.w,
              height: 22.h,
            ),
            activeIcon: Assets.icons.limit.svg(
              color: AppColors.textColorFFFFFF,
              width: 22.w,
              height: 22.h,
            ),
            label: "Limits",
          ),
          BottomNavigationBarItem(
            icon: Assets.icons.reports.svg(
              color: AppColors.borderColor,
              width: 22.w,
              height: 22.h,
            ),
            activeIcon: Assets.icons.reports.svg(
              color: AppColors.textColorFFFFFF,
              width: 22.w,
              height: 22.h,
            ),
            label: "Reports",
          ),
        ],
      ),
    );
  }
}
