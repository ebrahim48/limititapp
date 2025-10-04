import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';






class Themes {
  final lightTheme = ThemeData.light().copyWith(
    ///-------------------------elevated button theme------------------------->
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(20),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.maxFinite, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle:  TextStyle(
          fontSize: 16.h,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    ),


    ///-----------------app bar theme------------------>
    appBarTheme: const  AppBarTheme(
        scrolledUnderElevation: 0,
        color: AppColors.bgColor,
        centerTitle: true,
        elevation: 0),

    inputDecorationTheme: InputDecorationTheme(fillColor: Colors.black87),

    iconTheme: IconThemeData(color: Colors.black),
    scaffoldBackgroundColor: AppColors.bgColor,
  );


  ///----------------------------dart theme------------------------------->
  final darkTheme = ThemeData.dark().copyWith(

    ///------------------------- button theme------------------------->
    primaryColor: AppColors.primaryColorC79235,
    scaffoldBackgroundColor: AppColors.bgColor,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(20),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.maxFinite, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),


        textStyle:  TextStyle(
          fontSize: 16.h,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    ),



    scrollbarTheme: ScrollbarThemeData(
        thumbColor: MaterialStatePropertyAll(Colors.red.withOpacity(.50))
    ),

    ///-----------------app bar theme------------------>
    appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.white10),

    // ///--------------------text filed themes----------------------->
    // inputDecorationTheme: InputDecorationTheme(
    //     contentPadding:
    //     EdgeInsets.symmetric(vertical: 14.h, horizontal: 10.h),
    //     filled: true,
    //     fillColor: AppColors.fieldColor,
    //     hintStyle: TextStyle(
    //         fontSize: 16.h, fontWeight: FontWeight.w400, color: Colors.white),
    //     focusedBorder: OutlineInputBorder(
    //         borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
    //         borderSide: BorderSide(color: AppColors.borderColor, width: 1)),
    //     enabledBorder: OutlineInputBorder(
    //         borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
    //         borderSide: BorderSide(color: AppColors.borderColor, width: 1)))
  );
}