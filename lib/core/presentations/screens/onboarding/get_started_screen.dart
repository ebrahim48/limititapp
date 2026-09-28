import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../global/custom_assets/assets.gen.dart';
import '../../../config/app_routes/app_routes.dart';
import '../../../helpers/localization_helper.dart';
import '../../widgets/ui/ui.dart';
import 'onboarding_widgets.dart';

/// First screen after the splash — "Welcome to LimitIt".
/// CTA ta language picker e niye jay, tarpor onboarding pager.
class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return OnboardingBackground(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          children: [
            const Spacer(flex: 3),

            Assets.images.onboarding.image(
              width: 300.w,
              fit: BoxFit.contain,
            ),

            const Spacer(flex: 3),

            OnboardingHeadline(
              title: l10n.welcomeToLimitIt,
              subtitle: l10n.startingToday,
              titleSize: 28.sp,
              subtitleSize: 16.sp,
            ),

            const Spacer(flex: 3),

            AppButton(
              label: l10n.getStarted,
              onPressed: () => context.pushNamed(
                AppRoutes.languageScreen,
                queryParameters: const {'from': 'onboarding'},
              ),
            ),

            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }
}
