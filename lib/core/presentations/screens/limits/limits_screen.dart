import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:limit_it_app/core/config/app_routes/app_routes.dart';
import 'package:limit_it_app/core/constants/app_colors.dart';
import 'package:limit_it_app/core/constants/limit_data_helper.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_text.dart';
import 'package:limit_it_app/core/presentations/widgets/limit_card.dart';
import 'package:limit_it_app/core/presentations/widgets/announcement_card.dart';

class LimitsScreen extends StatelessWidget {
  const LimitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final limitOptions = LimitDataHelper.limitOptions;

    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: CustomText(
          text: 'Limits',
          color: AppColors.textColor3D3D3D,
          fontsize: 20.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h),
          Wrap(
            spacing: 18.w,
            runSpacing: 24.h,
            children: limitOptions.map((option) {
              return LimitCard(
                option: option,
                onTap: () {
                  if (option.isPro) {
                    if (option.title == 'Pin Lock') {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Pro Feature"),
                          content: const Text(
                            "This feature is only available in the Pro version.",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                context.pushNamed(AppRoutes.pinLockLimitsScreen);
                              },
                              child: const Text("OK"),
                            ),
                          ],
                        ),
                      );
                    } else if (option.title == 'Detox Mode') {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Pro Feature"),
                          content: const Text(
                            "This feature is only available in the Pro version.",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                context.pushNamed(AppRoutes.detoxModeScreen);
                              },
                              child: const Text("OK"),
                            ),
                          ],
                        ),
                      );
                    }
                  } else {
                    switch (option.title) {
                      case 'Screen time':
                        context.pushNamed(AppRoutes.limitScreenTime);
                        break;
                      case 'Schedules':
                        context.pushNamed(AppRoutes.schedulesLimitsScreen);
                        break;
                      case 'App usage':
                        Navigator.pushNamed(context, '/appUsage');
                        break;
                      default:
                        break;
                    }
                  }
                },
              );
            }).toList(),
          ),

          SizedBox(height: 270.h),
            const AnnouncementCard(),
            SizedBox(height: 60.h),
          ],
        ),
      ),
    );
  }
}
