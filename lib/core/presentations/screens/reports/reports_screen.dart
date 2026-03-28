import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
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
import 'package:limit_it_app/controllers/ads_controller.dart';
import 'package:limit_it_app/global/custom_assets/assets.gen.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';



class ReportsScreen extends StatefulWidget {
  ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  List<AppUsageData>? _appUsageData;
  List<AppUsageData>? _allAppsData;
  bool _isLoading = true;
  final AdsController _adsController = Get.put(AdsController());

  @override
  void initState() {
    super.initState();
    _loadRealAppUsage();
  }

  Future<void> _loadRealAppUsage() async {
    try {
      // Get today's usage data
      final usageData = await AppUsageService.instance.getTodayAppUsage();

      // Get ALL installed apps
      final allApps = await AppUsageService.instance.getAllInstalledApps();

      if (!mounted) return;
      setState(() {
        _appUsageData = usageData;
        _allAppsData = allApps;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
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
                // Show real installed apps or loading state
                if (_isLoading)
                  // Loading skeleton
                  Column(
                    children: List.generate(
                      5,
                      (index) => Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: Container(
                          height: 80.h,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                      ),
                    ),
                  )
                else if (_allAppsData != null && _allAppsData!.isNotEmpty)
                  // Show real apps sorted by usage time
                  Column(
                    children: _allAppsData!
                        .take(10) // Show top 10 most used apps
                        .map((app) => Padding(
                              padding: EdgeInsets.only(bottom: 12.h),
                              child: YourAppCard(
                                app: AppDataHelper.convertToYourApp(app),
                                showBlockButton: false, // Hide block button in Reports screen
                              ),
                            ))
                        .toList(),
                  )
                else
                  // No apps found
                  CustomText(
                    text: 'No apps found on this device',
                    fontsize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textColor5D5D5D,
                  ),

                SizedBox(height: 24.h),
                CustomButton(
                    title: context.l10n.downloadReport,
                    onpress: _downloadReport,
                ),
                SizedBox(height: 29.h),
                Obx(() => _buildAnnouncementSection()),
                SizedBox(height: 80.h),
              ],
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildAnnouncementSection() {
    // Check if ads are loading
    if (_adsController.isLoading.value && _adsController.ads.isEmpty) {
      return SizedBox.shrink();
    }

    // Check if there are no ads
    if (_adsController.ads.isEmpty) {
      return SizedBox.shrink();
    }

    // Show all ads in a list
    return Column(
      children: _adsController.ads.map((ad) => Padding(
        padding: EdgeInsets.only(bottom: 12.h),
        child: _buildAnnouncementCard(ad),
      )).toList(),
    );
  }

  Widget _buildAnnouncementCard(dynamic ad) {
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
              color: Colors.white,
              child: CachedNetworkImage(
                imageUrl: ad.image,
                width: 74.w,
                height: 74.h,
                fit: BoxFit.cover,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: 74.w,
                    height: 74.h,
                    color: Colors.white,
                  ),
                ),
                errorWidget: (context, url, error) => Assets.images.banner.image(
                  width: 74.w,
                  height: 74.h,
                ),
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
                  text: ad.title,
                  fontsize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColor3D3D3D,
                  maxline: 2,
                ),
                SizedBox(height: 4.h),
                CustomText(
                  textAlign: TextAlign.start,
                  text: ad.description,
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
