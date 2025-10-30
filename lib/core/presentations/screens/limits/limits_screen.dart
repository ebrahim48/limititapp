import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:limit_it_app/core/config/app_routes/app_routes.dart';
import 'package:limit_it_app/core/constants/app_colors.dart';
import 'package:limit_it_app/core/constants/limit_data_helper.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_text.dart';
import 'package:limit_it_app/core/presentations/widgets/limit_card.dart';
import 'package:limit_it_app/core/presentations/widgets/announcement_card.dart';

import '../../../constants/app_data_helper.dart';

class LimitsScreen extends StatefulWidget {
  const LimitsScreen({super.key});

  @override
  State<LimitsScreen> createState() => _LimitsScreenState();
}

class _LimitsScreenState extends State<LimitsScreen> {
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;
  final apps = AppDataHelper.dailyApps;
  String _statusMessage = 'AdMob Demo - Tap buttons to show ads';

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
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
              children:
                  limitOptions.map((option) {
                    return LimitCard(
                      option: option,
                      onTap: () {
                        if (option.isPro) {
                          if (option.title == 'Pin Lock') {
                            showDialog(
                              context: context,
                              builder:
                                  (context) => AlertDialog(
                                    title: const Text("Pro Feature"),
                                    content: const Text(
                                      "This feature is only available in the Pro version.",
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          context.pushNamed(
                                            AppRoutes.pinLockLimitsScreen,
                                          );
                                        },
                                        child: const Text("OK"),
                                      ),
                                    ],
                                  ),
                            );
                          } else if (option.title == 'Detox Mode') {
                            showDialog(
                              context: context,
                              builder:
                                  (context) => AlertDialog(
                                    title: const Text("Pro Feature"),
                                    content: const Text(
                                      "This feature is only available in the Pro version.",
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          context.pushNamed(
                                            AppRoutes.detoxModeScreen,
                                          );
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
                              context.pushNamed(
                                AppRoutes.schedulesLimitsScreen,
                              );
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
            SizedBox(height: 24.h),
            // Banner Ad Section
            if (_isBannerAdReady && _bannerAd != null)
              Center(
                child: Container(
                  width: _bannerAd!.size.width.toDouble(),
                  height: _bannerAd!.size.height.toDouble(),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: AdWidget(ad: _bannerAd!),
                  ),
                ),
              )
            else if (!_isBannerAdReady)
              // Show placeholder while ad is loading
              Center(
                child: Container(
                  width: 320.w,
                  height: 50.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Center(
                    child: CustomText(
                      text: 'Loading Ad...',
                      fontsize: 12.sp,
                      color: Colors.grey[600]!,
                    ),
                  ),
                ),
              ),
            SizedBox(height: 60.h),
          ],
        ),
      ),
    );
  }
}
