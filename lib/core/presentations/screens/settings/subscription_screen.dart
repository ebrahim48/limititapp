import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:limit_it_app/core/config/app_routes/app_routes.dart';
import 'package:limit_it_app/core/constants/app_colors.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_text.dart';
import 'package:limit_it_app/core/helpers/localization_helper.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
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
            CustomText(
              text: context.l10n.subscription,
              fontsize: 24.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textColor3D3D3D,
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 25.h),

                // Free Member Card
                Container(
                  width: 345.w,
                  height: 148.h,
                  padding: EdgeInsets.symmetric(horizontal: 23.h),
                  decoration: BoxDecoration(
                    color: Color(0xFFEDD69A),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: Color(0xFFD1D1D1),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomText(
                        text: context.l10n.youAreFreeMemberNow,
                        fontsize: 16.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textColor2C2C2C,
                        textAlign: TextAlign.center,
                        maxline: 2,
                      ),
                      SizedBox(height: 20.h),

                      GestureDetector(
                        onTap: () {
                          context.pushNamed(AppRoutes.inAppPurchaseSubscriptionScreen);
                        },
                        child: Container(
                          width: 206.w,
                          height: 48.h,
                          decoration: BoxDecoration(
                            color: Color(0xFF214432),
                            borderRadius: BorderRadius.circular(100.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: CustomText(
                            text: context.l10n.upgradeToPremium,
                            fontsize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),


                    ],
                  ),
                ),


                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }


}