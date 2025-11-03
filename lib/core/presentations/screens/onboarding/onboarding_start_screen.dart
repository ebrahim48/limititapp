import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:limit_it_app/core/config/app_routes/app_routes.dart';
import 'package:limit_it_app/core/helpers/localization_helper.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_button.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_text.dart';
import 'dart:ui';
import '../../../../global/custom_assets/assets.gen.dart';
import '../../../constants/app_colors.dart';

class OnboardingStartScreen extends StatefulWidget {
  const OnboardingStartScreen({super.key});

  @override
  State<OnboardingStartScreen> createState() => _OnboardingStartScreenState();
}

class _OnboardingStartScreenState extends State<OnboardingStartScreen> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Stack(
        children: [

          Positioned(
            top: 18.h,
            left: 109.w,
            child: Container(
              width: 259.w,
              height: 195.h,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                  ),
                ),
              ),
            ),
          ),


          Positioned(
            bottom: 0,
            left: 0,
            child: Container(
              width: 158.w,
              height: 219.h,
              decoration: BoxDecoration(
                color: AppColors.textColor803D20.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                  ),
                ),
              ),
            ),
          ),


          SafeArea(
            child: Column(
              children: [
                SizedBox(height: 23.h),

                // Page indicators
                _buildPageIndicator(),

                // PageView
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      return _buildPageContent(_pages[index]);
                    },
                  ),
                ),

                // Next button
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
                  child: CustomButton(
                    title: _currentPage == _pages.length - 1 ? context.l10n.signUpNow : context.l10n.next,
                    onpress: _nextPage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _pages.length,
            (index) => Container(
          width: 64.w,
          height: 5.h,
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100.r),
            color: _currentPage == index
                ? Color(0xFF4C956C)
                : Color(0xFF888888),
          ),
        ),
      ),
    );
  }

  Widget _buildPageContent(OnboardingData data) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Image
        data.image.image(
          width: 311.w,
          height: 319.h,
        ),

        SizedBox(height: 58.h),

        // Title
        CustomText(
          text: data.title,
          fontsize: 24.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.textColor3D3D3D,
          maxline: 2,
          textAlign: TextAlign.center,
        ),

        SizedBox(height: 12.h),

        // Subtitle
        CustomText(
          text: data.subtitle,
          fontsize: 14.sp,
          fontWeight: FontWeight.w400,
          color: AppColors.textColor5D5D5D,
          maxline: 2,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }


  final PageController _pageController = PageController();
  int _currentPage = 0;

  List<OnboardingData> get _pages => [
    OnboardingData(
      image: Assets.images.screentime,
      title: context.l10n.takeControlScreenTime,
      subtitle: context.l10n.regainControl,
    ),
    OnboardingData(
      image: Assets.images.limit,
      title: context.l10n.limitDistractingApps,
      subtitle: context.l10n.chooseAppsToLimit,
    ),
    OnboardingData(
      image: Assets.images.resets,
      title: context.l10n.smartScheduling,
      subtitle: context.l10n.createPerfectSchedule,
    ),
    OnboardingData(
      image: Assets.images.progress,
      title: context.l10n.trackYourProgress,
      subtitle: context.l10n.stayMotivated,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      context.pushNamed(AppRoutes.signUpScreen);

    }
  }
}


class OnboardingData {
  final dynamic image;
  final String title;
  final String subtitle;

  OnboardingData({
    required this.image,
    required this.title,
    required this.subtitle,
  });
}