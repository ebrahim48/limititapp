import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:get/get.dart';
import 'package:limit_it_app/core/services/ad_service.dart';
import 'package:limit_it_app/core/config/app_routes/app_routes.dart';
import 'package:limit_it_app/core/constants/app_colors.dart';
import 'package:limit_it_app/core/constants/limit_data_helper.dart';
import 'package:limit_it_app/core/models/limit_option_model.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_text.dart';
import 'package:limit_it_app/core/presentations/widgets/limit_card.dart';
import 'package:limit_it_app/controllers/ads_controller.dart';
import 'package:limit_it_app/global/custom_assets/assets.gen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:limit_it_app/core/helpers/localization_helper.dart';


class LimitsScreen extends StatefulWidget {
  const LimitsScreen({super.key});

  @override
  State<LimitsScreen> createState() => _LimitsScreenState();
}

class _LimitsScreenState extends State<LimitsScreen> {
  final AdsController _adsController = Get.put(AdsController());

  /// Shows a (frequency-capped) interstitial for Free users, then navigates.
  Future<void> _showInterstitialAdAndNavigate() async {
    await AdService.instance.maybeShowInterstitial();
    if (!mounted) return;
    context.pushNamed(AppRoutes.limitScreenTime);
  }

  @override
  Widget build(BuildContext context) {
    final limitOptions = LimitDataHelper.limitOptions(context);

    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: CustomText(
          text: context.l10n.limits,
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
                          if (option.id == LimitOptionId.pinLock) {
                            showDialog(
                              context: context,
                              builder:
                                  (context) => AlertDialog(
                                    title: Text(context.l10n.proFeature),
                                    content: Text(
                                      context.l10n.proFeatureMessage,
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          context.pushNamed(
                                            AppRoutes.pinLockLimitsScreen,
                                          );
                                        },
                                        child: Text(context.l10n.ok),
                                      ),
                                    ],
                                  ),
                            );
                          } else if (option.id == LimitOptionId.detoxMode) {
                            showDialog(
                              context: context,
                              builder:
                                  (context) => AlertDialog(
                                    title: Text(context.l10n.proFeature),
                                    content: Text(
                                      context.l10n.proFeatureMessage,
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          context.pushNamed(
                                            AppRoutes.detoxModeScreen,
                                          );
                                        },
                                        child: Text(context.l10n.ok),
                                      ),
                                    ],
                                  ),
                            );
                          }
                        } else {
                          switch (option.id) {
                            case LimitOptionId.screenTime:
                              _showInterstitialAdAndNavigate();
                              break;
                            case LimitOptionId.schedules:
                              context.pushNamed(
                                AppRoutes.schedulesLimitsScreen,
                              );
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
            const AppBannerAd(),
            SizedBox(height: 24.h),
            // Announcement Section
            Obx(() => _buildAnnouncementSection()),
            SizedBox(height: 60.h),
          ],
        ),
      ),
    );
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
