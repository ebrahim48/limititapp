import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';

/// ============================================================
///  Shared chrome for the welcome + onboarding pages.
///  CTA er jonno design-system er [AppButton] use kora hoy —
///  sign-up screen er button er sathe exact match.
/// ============================================================

/// Plain white canvas that every onboarding page sits on.
class OnboardingBackground extends StatelessWidget {
  const OnboardingBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(child: child),
    );
  }
}

/// Four segment bars at the top of the pager — active one is brand green.
class OnboardingStepBar extends StatelessWidget {
  const OnboardingStepBar({
    super.key,
    required this.count,
    required this.activeIndex,
  });

  final int count;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(count * 2 - 1, (i) {
        if (i.isOdd) return SizedBox(width: 16.w);
        final index = i ~/ 2;
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            height: 4.h,
            decoration: BoxDecoration(
              color: index == activeIndex
                  ? AppColors.brandGreen
                  : AppColors.stepInactive,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
        );
      }),
    );
  }
}

/// Heading + supporting line, centred under the illustration.
class OnboardingHeadline extends StatelessWidget {
  const OnboardingHeadline({
    super.key,
    required this.title,
    required this.subtitle,
    this.titleSize,
    this.subtitleSize,
  });

  final String title;
  final String subtitle;
  final double? titleSize;
  final double? subtitleSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppFont.family,
            fontSize: titleSize ?? 24.sp,
            fontWeight: AppFont.extraBold,
            height: 1.25,
            color: AppColors.ink,
          ),
        ),
        SizedBox(height: 10.h),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppFont.family,
            fontSize: subtitleSize ?? 14.sp,
            fontWeight: AppFont.regular,
            height: 1.45,
            color: AppColors.slateGreen,
          ),
        ),
      ],
    );
  }
}
