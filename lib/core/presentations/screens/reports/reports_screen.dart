import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:limit_it_app/core/constants/app_colors.dart';
import 'package:limit_it_app/core/constants/app_data_helper.dart';
import 'package:limit_it_app/core/helpers/localization_helper.dart';
import 'package:limit_it_app/core/helpers/toast_message_helper.dart';
import 'package:limit_it_app/core/models/daily_usage.dart';
import 'package:limit_it_app/core/presentations/widgets/background_layers.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_button.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_text.dart';
import 'package:limit_it_app/core/presentations/widgets/daily_usage_card.dart';
import 'package:limit_it_app/core/presentations/widgets/your_appcard_widget.dart';
import 'package:limit_it_app/core/services/app_usage_service.dart';
import 'package:limit_it_app/core/services/report_generator_service.dart';
import 'package:limit_it_app/global/custom_assets/assets.gen.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';



class ReportsScreen extends StatefulWidget {
  ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  List<AppUsageData>? _appUsageData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRealAppUsage();
  }

  Future<void> _loadRealAppUsage() async {
    try {
      final usageData = await AppUsageService.instance.getTodayAppUsage();
      setState(() {
        _appUsageData = usageData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _downloadReport() async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SpinKitFadingCircle(
                color: AppColors.primaryGreen,
                size: 50.r,
              ),
              SizedBox(height: 16.h),
              CustomText(
                text: context.l10n.generatingReport,
                fontsize: 16.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textColor2C2C2C,
              ),
              SizedBox(height: 8.h),
              CustomText(
                text: context.l10n.preparingYourReport,
                fontsize: 12.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF666666),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      // Convert real usage data to DailyUsageApp format for the report
      List<DailyUsageApp> dailyApps;
      if (_appUsageData != null && _appUsageData!.isNotEmpty) {
        dailyApps = AppDataHelper.convertToDailyUsageApps(_appUsageData!);
      } else {
        dailyApps = AppDataHelper.dailyApps;
      }

      // Generate and download report
      await ReportGeneratorService.generateAndDownloadReport(
        dailyApps: dailyApps,
        yourApps: AppDataHelper.yourApps,
        appUsageData: _appUsageData,
      );

      // Close loading dialog
      if (context.mounted) {
        Navigator.pop(context);
        
        // Show success toast
        ToastMessageHelper.showToastMessage(
          context.l10n.reportReadyToShare,
          title: context.l10n.reportDownloaded,
        );
      }
    } catch (e) {
      // Close loading dialog
      if (context.mounted) {
        Navigator.pop(context);
        
        // Show error toast
        ToastMessageHelper.showToastMessage(
          context.l10n.failedToDownloadReport,
          title: context.l10n.error,
        );
      }
    }
  }

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
            SizedBox(width: 24.w),
            CustomText(
              text: context.l10n.reports,
              fontsize: 24.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textColor3D3D3D,
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          BackgroundBlurLayers(),
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                SizedBox(height: 24.h),
                DailyUsageCard(
                  dailyApps: _isLoading 
                      ? AppDataHelper.dailyApps 
                      : (_appUsageData != null && _appUsageData!.isNotEmpty
                          ? AppDataHelper.convertToDailyUsageApps(_appUsageData!)
                          : AppDataHelper.dailyApps),
                  appUsageData: _appUsageData,
                  isLoading: _isLoading,
                ),

                SizedBox(height: 24.h),
                CustomText(
                  text: context.l10n.mostUsedApps,
                  fontsize: 20.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textColor2C2C2C,
                ),

                SizedBox(height: 12.h),
                ...AppDataHelper.yourApps.map((app) => YourAppCard(app: app)),
                SizedBox(height: 24.h),
                CustomButton(
                    title: context.l10n.downloadReport,
                    onpress: _downloadReport,
                ),
                SizedBox(height: 29.h),
                _buildAnnouncementCard(),
                SizedBox(height: 80.h),
              ],
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildAnnouncementCard() {
    return Container(
      width: 345.w,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Color(0xFFEDD69A),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: Container(
              width: 80.w,
              height: 80.h,
              color: Colors.blue.shade100,
              child:  Assets.images.banner.image(
                width: 74.w,
                height: 74.h,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  textAlign: TextAlign.start,
                  text: 'Big Announce for Figma\nmake',
                  fontsize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textColor3D3D3D,
                  maxline: 2,
                ),
                SizedBox(height: 4.h),
                CustomText(
                  textAlign: TextAlign.start,
                  text: 'Stay focused, take control\nof your time',
                  fontsize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textColor3D3D3D,
                  maxline: 2,
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }
}
