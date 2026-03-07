import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:limit_it_app/core/config/app_routes/app_routes.dart';
import 'package:limit_it_app/core/constants/app_colors.dart';
import 'package:limit_it_app/core/constants/limit_data_helper.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_text.dart';
import 'package:limit_it_app/core/presentations/widgets/limit_card.dart';
import 'package:limit_it_app/controllers/ads_controller.dart';
import 'package:limit_it_app/global/custom_assets/assets.gen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shimmer/shimmer.dart';

import '../../../constants/app_data_helper.dart';

class LimitsScreen extends StatefulWidget {
  const LimitsScreen({super.key});

  @override
  State<LimitsScreen> createState() => _LimitsScreenState();
}

class _LimitsScreenState extends State<LimitsScreen> {
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;
  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;
  final apps = AppDataHelper.dailyApps;
  final AdsController _adsController = Get.put(AdsController());

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
    _loadInterstitialAd();
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
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    );
    _bannerAd?.load();
  }

  // 2. Interstitial Ad
  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/1033173712', // Test Interstitial ID
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdReady = true;

          // Set up full screen content callback
          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _isInterstitialAdReady = false;
              _loadInterstitialAd(); // Load a new ad for next time
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _isInterstitialAdReady = false;
              _loadInterstitialAd(); // Load a new ad
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isInterstitialAdReady = false;
        },
      ),
    );
  }

  void _showInterstitialAdAndNavigate() {
    if (_isInterstitialAdReady && _interstitialAd != null) {
      _interstitialAd!.show();
      // Navigation will happen after ad is dismissed via callback
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _isInterstitialAdReady = false;
          _loadInterstitialAd(); // Load a new ad for next time
          // Navigate after ad is dismissed
          context.pushNamed(AppRoutes.limitScreenTime);
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _isInterstitialAdReady = false;
          _loadInterstitialAd(); // Load a new ad
          // Navigate anyway if ad fails to show
          context.pushNamed(AppRoutes.limitScreenTime);
        },
      );
    } else {
      // If ad is not ready, navigate directly
      context.pushNamed(AppRoutes.limitScreenTime);
    }
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
                              _showInterstitialAdAndNavigate();
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
            SizedBox(height: 24.h),
            // Announcement Section
            Obx(() => _buildAnnouncementSection()),
            SizedBox(height: 60.h),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  Widget _buildAnnouncementSection() {
    if (_adsController.isLoading.value && _adsController.ads.isEmpty) {
      return SizedBox.shrink();
    }

    if (_adsController.ads.isEmpty) {
      return SizedBox.shrink();
    }

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
                  fontWeight: FontWeight.w500,
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
