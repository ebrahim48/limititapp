import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class CustomListviewShimmer extends StatelessWidget {
  const CustomListviewShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SizedBox(height: kToolbarHeight + 16.h), // space for AppBar
          
              // // Linear progress indicator placeholder
              // Container(
              //   height: 8.h,
              //   width: double.infinity,
              //   decoration: BoxDecoration(
              //     color: Colors.grey.shade300,
              //     borderRadius: BorderRadius.circular(4.r),
              //   ),
              // ),
              SizedBox(height: 20.h),
          
              // Generate multiple booking card placeholders
              ...List.generate(3, (_) => Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(14.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        offset: const Offset(0, 2),
                        blurRadius: 13,
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(20.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Row: status & location icon placeholders
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 80.w,
                            height: 12.h,
                            color: Colors.grey.shade400,
                          ),
                          Container(
                            width: 24.w,
                            height: 24.h,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade400,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
          
                      // Avatar & details row
                      Row(
                        children: [
                          // Avatar circle placeholder
                          Container(
                            width: 64.r,
                            height: 64.r,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade400,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Name placeholder
                                Container(
                                  width: 150.w,
                                  height: 20.h,
                                  color: Colors.grey.shade400,
                                ),
                                SizedBox(height: 8.h),
          
                                // Address placeholder
                                Container(
                                  width: 200.w,
                                  height: 14.h,
                                  color: Colors.grey.shade400,
                                ),
                                SizedBox(height: 8.h),
          
                                // Subtitle placeholder (car model)
                                Container(
                                  width: 120.w,
                                  height: 14.h,
                                  color: Colors.grey.shade400,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
          
                      SizedBox(height: 16.h),
          
                      // Action button placeholder
                      Container(
                        width: double.infinity,
                        height: 40.h,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(100.r),
                        ),
                      ),
                    ],
                  ),
                ),
              )),
              SizedBox(height: 70.h),
            ],
          ),
        ),
      ),
    );
  }
}
