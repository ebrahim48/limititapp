import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:get/get.dart';
import 'package:limit_it_app/core/config/app_routes/app_routes.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_button.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_text.dart';
import 'package:limit_it_app/core/presentations/controller/locale_controller.dart';
import 'package:limit_it_app/l10n/app_localizations.dart';
import 'dart:ui';
import '../../../constants/app_colors.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late LocaleController localeController;
  String selectedLanguage = 'Italian';

  final List<String> languages = ['Italian', 'English', 'Spanish'];

  @override
  void initState() {
    super.initState();
    localeController = Get.find<LocaleController>();
    selectedLanguage = localeController.currentLanguageName;
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Force rebuild when locale changes
      final _ = localeController.locale.value;

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
                color: AppColors.primaryColor.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                child: Container(
                  decoration: BoxDecoration(color: Colors.transparent),
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
                color: AppColors.textColor803D20.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                child: Container(
                  decoration: BoxDecoration(color: Colors.transparent),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 198.h),

                  CustomText(
                    text: AppLocalizations.of(context)!.selectYourLanguage,
                    fontsize: 20.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textColor3D3D3D,
                  ),

                  SizedBox(height: 12.h),
                  ...languages.map(
                    (language) => _buildLanguageOption(language),
                  ),

                  SizedBox(height: 32.h),

                  CustomButton(
                    title: AppLocalizations.of(context)!.getStarted,
                    onpress: () {
                      context.pushNamed(AppRoutes.onBoardingStartScreen);
                    },
                  ),

                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
    });
  }

  Widget _buildLanguageOption(String language) {
    final isSelected = selectedLanguage == language;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedLanguage = language;
        });
        // Change locale immediately
        final languageCode = localeController.getLanguageCode(language);
        localeController.changeLocale(languageCode);
      },
      child: Container(
        width: 328.w,
        height: 54.h,
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100.r),
          border: Border.all(color: AppColors.borderColor, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomText(
              text: language,
              fontsize: 14.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.textColor5D5D5D,
            ),
            Container(
              width: 20.w,
              height: 20.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? Color(0xFF4C956C) : Colors.transparent,
                border: Border.all(
                  color: isSelected ? Color(0xFF4C956C) : Color(0xFF6D6D6D),
                  width: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
