import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:limit_it_app/core/constants/app_colors.dart';
import '../../widgets/custom_text.dart';



class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

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
              icon: Icon(Icons.arrow_back, color: Colors.black, size: 24.r),
              onPressed: () => Navigator.pop(context),
            ),
            SizedBox(width: 12.w),
            CustomText(
              text: "About Us",
              color: AppColors.textColor3D3D3D,
              fontsize: 24.sp,
              fontWeight: FontWeight.w500,
            ),
          ],
        ),

      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              SizedBox(height: 24.h),

              Container(
                width: 348.w,
                height: 172.h,
                decoration: BoxDecoration(
                  color:  Color(0xFFEDD69A),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40.r),
                    child: Image.asset(
                      "assets/images/aboutus.png",
                      width: 205.w,
                      height: 149.h,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24.h),

              CustomText(
                maxline: 40,
                textAlign: TextAlign.start,
                text: 'Lorem ipsum dolor sit amet consectetur.Vel blandit mi nulla sodales consectetur. Egestas tristique ultrices gravida duis nisl odio. Posuere curabitur eu platea pellentesque ut. Facilisi elementum neque mauris facilisis in. Cursus condimentum ipsum pretium consequat turpis at porttitor nisi.Scelerisque tellus praesent condimentum euismod a faucibus. Auctor at ultricies at urna aliquam massa pellentesque. Vitae vulputate nullam diam placerat at magna egestas. Lectus lectus consequat porta lectus purus.',
                fontsize: 14.sp,
                color: AppColors.textColor3D3D3D,
              ),

              SizedBox(height: 32.h),

              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CustomText(
                      text: 'Ebrahim',
                      fontsize: 16.sp,
                      color: AppColors.textColor3D3D3D,
                    ),
                    SizedBox(height: 16.h),

                    // Phone row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.phone,
                          size: 18.r,
                          color: AppColors.textColor3D3D3D,
                        ),
                        SizedBox(width: 8.w),
                        CustomText(
                          text: '+1623773738',
                          fontsize: 16.sp,
                          color: AppColors.textColor3D3D3D,
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    // Email row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.email_outlined,
                          size: 18.r,
                          color: AppColors.textColor3D3D3D,
                        ),
                        SizedBox(width: 8.w),
                        CustomText(
                          text: 'ebrahim.cse.bu@gmail.com',
                          fontsize: 16.sp,
                          color: AppColors.textColor3D3D3D,
                        ),
                      ],
                    ),
                  ],
                ),
              ),





              SizedBox(height: 60.h),


            ],
          ),
        ),
      ),
    );
  }


}