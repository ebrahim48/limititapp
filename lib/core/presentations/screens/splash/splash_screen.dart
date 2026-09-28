import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:limit_it_app/core/app_constants/app_constants.dart';
import 'package:limit_it_app/core/helpers/localization_helper.dart';
import 'package:limit_it_app/core/helpers/prefs_helper.dart';
import '../../../../global/custom_assets/assets.gen.dart';
import '../../../config/app_routes/app_routes.dart';
import '../../widgets/ui/ui.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    )..forward();

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _checkAuthAndNavigate();
  }

  /// Auth gate — a saved bearer token goes straight to the app,
  /// otherwise the user starts at the welcome screen: Get Started →
  /// language → onboarding tour → sign up.
  Future<void> _checkAuthAndNavigate() async {
    await Future.delayed(const Duration(seconds: 3));

    final bearerToken = await PrefsHelper.getString(AppConstants.bearerToken);

    if (!mounted) return;

    if (bearerToken.isNotEmpty) {
      context.goNamed(AppRoutes.bottomNavBarScreen);
    } else {
      context.goNamed(AppRoutes.getStartedScreen);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Assets.icons.ui.limitItLogo.image(
                  width: 220.w,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: 16.h),
                Text(
                  context.l10n.takeBackYourTime,
                  style: AppTextStyles.body(color: AppColors.slateGreen),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
