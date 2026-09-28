import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../global/custom_assets/assets.gen.dart';
import '../../../config/app_routes/app_routes.dart';
import '../../../helpers/localization_helper.dart';
import '../../../../l10n/app_localizations.dart';
import '../../widgets/ui/ui.dart';
import 'onboarding_widgets.dart';

/// One slide of the four-page onboarding pager.
class _OnboardingPage {
  const _OnboardingPage({
    required this.image,
    required this.title,
    required this.subtitle,
    required this.cta,
  });

  final AssetGenImage image;
  final String Function(AppLocalizations) title;
  final String Function(AppLocalizations) subtitle;
  final String Function(AppLocalizations) cta;
}

final List<_OnboardingPage> _pages = [
  _OnboardingPage(
    image: Assets.images.screentime,
    title: (l) => l.takeControlScreenTime,
    subtitle: (l) => l.regainControl,
    cta: (l) => l.next,
  ),
  _OnboardingPage(
    image: Assets.images.limit,
    title: (l) => l.limitDistractingApps,
    subtitle: (l) => l.chooseAppsToLimit,
    cta: (l) => l.next,
  ),
  _OnboardingPage(
    image: Assets.images.resets,
    title: (l) => l.smartScheduling,
    subtitle: (l) => l.createPerfectSchedule,
    cta: (l) => l.next,
  ),
  _OnboardingPage(
    image: Assets.images.progress,
    title: (l) => l.trackYourProgress,
    subtitle: (l) => l.stayMotivated,
    cta: (l) => l.signUpNow,
  ),
];

/// Swipeable feature tour shown after the language picker.
/// Last page er CTA sign-up e niye jay.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onCtaPressed() {
    if (_index == _pages.length - 1) {
      context.pushNamed(AppRoutes.signUpScreen);
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return OnboardingBackground(
      child: Column(
        children: [
          SizedBox(height: 16.h),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 44.w),
            child: OnboardingStepBar(
              count: _pages.length,
              activeIndex: _index,
            ),
          ),

          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: _pages.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (context, i) {
                final page = _pages[i];
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    children: [
                      const Spacer(flex: 3),
                      page.image.image(width: 280.w, fit: BoxFit.contain),
                      const Spacer(flex: 3),
                      OnboardingHeadline(
                        title: page.title(l10n),
                        subtitle: page.subtitle(l10n),
                      ),
                      const Spacer(flex: 2),
                    ],
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 40.h),
            child: AppButton(
              label: _pages[_index].cta(l10n),
              onPressed: _onCtaPressed,
            ),
          ),
        ],
      ),
    );
  }
}
