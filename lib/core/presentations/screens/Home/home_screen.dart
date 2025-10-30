import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:limit_it_app/core/constants/app_colors.dart';
import 'package:limit_it_app/core/constants/app_data_helper.dart';
import 'package:limit_it_app/core/presentations/widgets/background_layers.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_home_appbar.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_text.dart';
import 'package:limit_it_app/core/presentations/widgets/daily_usage_card.dart';
import 'package:limit_it_app/core/presentations/widgets/screen_time_slider.dart';
import 'package:limit_it_app/core/presentations/widgets/your_appcard-widget.dart';
import 'package:limit_it_app/core/services/app_usage_service.dart';
import 'package:limit_it_app/global/custom_assets/assets.gen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;
  final apps = AppDataHelper.dailyApps;
  String _statusMessage = 'AdMob Demo - Tap buttons to show ads';

  bool _isLoading = true;
  bool _hasPermission = false;
  List<AppUsageData> _appUsageList = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
    _loadAppUsageData();
  }

  // 1. Banner Ad
  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111', // Test Banner ID
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isBannerAdReady = true;
            _statusMessage = 'Banner Ad loaded';
          });
        },
        onAdFailedToLoad: (ad, error) {
          setState(() {
            _statusMessage = 'Banner Ad failed: ${error.message}';
          });
          ad.dispose();
        },
      ),
    );
    _bannerAd?.load();
  }

  /// Load app usage data
  Future<void> _loadAppUsageData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Check if platform supports app usage tracking
      if (!Platform.isAndroid) {
        setState(() {
          _isLoading = false;
          _hasPermission = false;
          _errorMessage =
              'App usage tracking is only available on Android devices';
        });
        return;
      }

      // Check permission
      bool hasPermission = await AppUsageService.hasPermission();

      if (!hasPermission) {
        // Request permission
        hasPermission = await AppUsageService.requestPermission();
      }

      setState(() {
        _hasPermission = hasPermission;
      });

      if (hasPermission) {
        // Get app usage data
        List<AppUsageData> usageData = await AppUsageService.getTodayAppUsage();

        setState(() {
          _appUsageList = usageData;
          _isLoading = false;
          if (usageData.isEmpty) {
            _errorMessage = 'No app usage data available for today';
          }
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'Permission denied. Please grant usage access permission in settings';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading app usage data: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomHomeAppBar(),
      body: Stack(
        children: [
          BackgroundBlurLayers(),
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),

                /// -====================================> slider ==========================
                CustomScreenTimeSlider(),
                SizedBox(height: 24.h),
                DailyUsageCard(dailyApps: AppDataHelper.dailyApps),
                SizedBox(height: 24.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomText(
                      text: 'Your Apps',
                      fontsize: 20.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textColor2C2C2C,
                    ),
                    if (_isLoading)
                      SizedBox(
                        width: 16.w,
                        height: 16.h,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(
                            AppColors.textColor2C2C2C,
                          ),
                        ),
                      )
                    else if (!_hasPermission && Platform.isAndroid)
                      TextButton(
                        onPressed: _loadAppUsageData,
                        child: CustomText(
                          text: 'Grant Permission',
                          fontsize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFDDA742),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 12.h),
                _buildYourAppsSection(),
                SizedBox(height: 24.h),
                if (_isBannerAdReady && _bannerAd != null)
                  Container(
                    color: Colors.grey[200],
                    child: SizedBox(
                      width: _bannerAd!.size.width.toDouble(),
                      height: _bannerAd!.size.height.toDouble(),
                      child: AdWidget(ad: _bannerAd!),
                    ),
                  ),
                SizedBox(height: 80.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build the Your Apps section with edge case handling
  Widget _buildYourAppsSection() {
    // Show error message if there's an error
    if (_errorMessage != null) {
      return _buildInfoCard(
        _errorMessage!,
        icon: Icons.info_outline,
        color: const Color(0xFFFF9800),
      );
    }

    // Show loading state
    if (_isLoading) {
      return _buildLoadingCards();
    }

    // Show actual app usage data if available
    if (_appUsageList.isNotEmpty) {
      // Remove duplicates by package name - keep the first occurrence
      final seen = <String>{};
      final uniqueApps = _appUsageList.where((appData) {
        if (seen.contains(appData.packageName)) {
          return false;
        }
        seen.add(appData.packageName);
        return true;
      }).toList();

      return Column(
        children:
            uniqueApps.asMap().entries.map((entry) {
              final index = entry.key;
              final appData = entry.value;
              return YourAppCard(
                appData: appData,
                key: ValueKey('${appData.packageName}_$index'),
              );
            }).toList(),
      );
    }

    // Fallback to dummy data if no real data available (iOS or no data)
    return Column(
      children:
          AppDataHelper.yourApps.asMap().entries.map((entry) {
            final index = entry.key;
            final app = entry.value;
            return YourAppCard(
              app: app,
              key: ValueKey('dummy_app_$index'),
            );
          }).toList(),
    );
  }

  /// Build info card for messages
  Widget _buildInfoCard(String message, {IconData? icon, Color? color}) {
    return Container(
      width: 345.w,
      padding: EdgeInsets.all(16.w),
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: (color ?? const Color(0xFFDDA742)).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color ?? const Color(0xFFDDA742), width: 1),
      ),
      child: Row(
        children: [
          Icon(
            icon ?? Icons.info_outline,
            color: color ?? const Color(0xFFDDA742),
            size: 24.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: CustomText(
              text: message,
              fontsize: 14.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.textColor3D3D3D,
              maxline: 3,
            ),
          ),
        ],
      ),
    );
  }

  /// Build loading shimmer cards
  Widget _buildLoadingCards() {
    return Column(
      children: List.generate(3, (index) {
        return Container(
          width: 345.w,
          height: 80.h,
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            children: [
              Container(
                width: 48.w,
                height: 48.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120.w,
                      height: 16.h,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      width: 80.w,
                      height: 12.h,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 32.w,
                height: 32.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }
}
