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
        color: AppColors.backGroundColor,
        centerTitle: true,
        elevation: 0),

    inputDecorationTheme: InputDecorationTheme(fillColor: Colors.black87),

    iconTheme: IconThemeData(color: Colors.black),
    scaffoldBackgroundColor: AppColors.backGroundColor,
  );


  ///----------------------------dart theme------------------------------->
  final darkTheme = ThemeData.dark().copyWith(

    ///------------------------- button theme------------------------->
    primaryColor: AppColors.primaryColor,
    scaffoldBackgroundColor: AppColors.backGroundColor,
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

  );
}