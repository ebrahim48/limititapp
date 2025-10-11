import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:limit_it_app/core/constants/app_colors.dart';
import '../../widgets/custom_text.dart';



class TermsServicesScreen extends StatelessWidget {
  TermsServicesScreen({super.key});

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
              text: "Terms & Conditions",
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
                      "assets/images/policy.png",
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
                text: 'Lorem ipsum dolor sit amet consectetur. Lacus at venenatis gravida vivamus mauris. Quisque mi est vel dis. Donec rhoncus laoreet odio orci sed risus elit accumsan. Mattis ut est tristique amet vitae at aliquet. Ac vel porttitor egestas scelerisque enim quisque senectus. Euismod ultricies vulputate id cras bibendum sollicitudin proin odio bibendum. Velit velit in scelerisque erat etiam rutrum phasellus nunc. Sed lectus sed a at et eget. Nunc purus sed quis at risus. Consectetur nibh justo proin placerat condimentum id at adipiscing.Vel blandit mi nulla sodales consectetur. Egestas tristique ultrices gravida duis nisl odio. Posuere curabitur eu platea pellentesque ut. Facilisi elementum neque mauris facilisis in. Cursus condimentum ipsum pretium consequat turpis at porttitor nisi.Scelerisque tellus praesent condimentum euismod a faucibus. Auctor at ultricies at urna aliquam massa pellentesque. Vitae vulputate nullam diam placerat at magna egestas. Lectus lectus consequat porta lectus purus. Nulla duis sem sit at imperdiet lobortis dui. Nunc tellus cursus maecenas phasellus sollicitudin donec dictum. Sodales in faucibus libero augue vestibulum urna mattis curabitur. Leo ac pretium elit egestas mi commodo odio neque. Ac quis vulputate vel sagittis. Tortor magna erat ultrices lacus urna sed sit egestas in. Suspendisse lacus diam pretium adipiscing ultrices penatibus ullamcorper in felis. Sed nullam consectetur euismod a laoreet dui. Nulla porttitor urna id blandit.Pretium pulvinar morbi suspendisse mattis.',
                fontsize: 14.sp,
                color: AppColors.textColor3D3D3D,
              ),



              SizedBox(height: 60.h),


            ],
          ),
        ),
      ),
    );
  }


}