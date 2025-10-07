import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:limit_it_app/core/constants/app_strings.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_button.dart';

class SelectAppsManageScreen extends StatefulWidget {
  SelectAppsManageScreen({super.key});

  @override
  State<SelectAppsManageScreen> createState() => _SelectAppsManageScreenState();
}

class _SelectAppsManageScreenState extends State<SelectAppsManageScreen> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [






                  SizedBox(height: 63.h),

                  // Get Started button
                  CustomButton(
                    title: AppString.getStarted,
                    onpress: () {



                    },
                  ),

                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),

    );
  }






}