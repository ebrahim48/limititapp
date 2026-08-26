import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:limit_it_app/core/helpers/localization_helper.dart';
import 'package:limit_it_app/core/helpers/toast_message_helper.dart';
import '../../../../global/custom_assets/assets.gen.dart';
import '../../../config/app_routes/app_routes.dart';
import '../../widgets/ui/ui.dart';

/// Landing screen shown right after the splash when nobody is signed in.
/// The onboarding carousel is intentionally skipped.
class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  /// Social sign-in has no backend endpoint yet — the buttons are wired here
  /// so they only need the provider call dropped in.
  void _socialSignIn(BuildContext context, String provider) {
    ToastMessageHelper.showToastMessage(
      context.l10n.socialLoginComingSoon,
      title: provider,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: AppSpacing.screenPadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: _LanguagePill(
                            onTap: () =>
                                context.pushNamed(AppRoutes.languageScreen),
                          ),
                        ),
                        SizedBox(height: 24.h),

                        Center(
                          child: Assets.illustrations.leafLogo.svg(
                            width: 88.w,
                            height: 88.w,
                          ),
                        ),
                        SizedBox(height: 24.h),

                        Text(
                          l10n.takeBackYourTime,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.h1(),
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          l10n.getStartedSubtitle,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body(color: AppColors.slateGreen),
                        ),

                        SizedBox(height: 28.h),

                        _Feature(
                          icon: Assets.icons.ui.shieldLock,
                          title: l10n.featureProtectTitle,
                          subtitle: l10n.featureProtectSubtitle,
                        ),
                        SizedBox(height: 10.h),
                        _Feature(
                          icon: Assets.icons.ui.barChart,
                          title: l10n.featureInsightTitle,
                          subtitle: l10n.featureInsightSubtitle,
                        ),
                        SizedBox(height: 10.h),
                        _Feature(
                          icon: Assets.icons.ui.target,
                          title: l10n.featureGoalTitle,
                          subtitle: l10n.featureGoalSubtitle,
                        ),

                        SizedBox(height: 28.h),
                        const Spacer(),

                        /// ---------------- Sign-in options ----------------
                        AppSocialButton(
                          dark: true,
                          label: l10n.continueWithApple,
                          icon: AppIcon(
                            Assets.icons.ui.apple,
                            size: 19.w,
                            color: AppColors.white,
                          ),
                          onPressed: () => _socialSignIn(context, 'Apple'),
                        ),
                        SizedBox(height: 10.h),
                        AppSocialButton(
                          label: l10n.continueWithGoogle,
                          icon: Assets.icons.ui.google.svg(
                            width: 19.w,
                            height: 19.w,
                          ),
                          onPressed: () => _socialSignIn(context, 'Google'),
                        ),
                        SizedBox(height: 10.h),
                        AppButton(
                          label: l10n.continueWithEmail,
                          variant: AppButtonVariant.brand,
                          icon: AppIcon(
                            Assets.icons.ui.mail,
                            size: 19.w,
                            color: AppColors.white,
                          ),
                          onPressed: () =>
                              context.pushNamed(AppRoutes.signUpScreen),
                        ),

                        SizedBox(height: 14.h),
                        Center(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () =>
                                context.pushNamed(AppRoutes.logInScreen),
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 4.h),
                              child: RichText(
                                text: TextSpan(
                                  text: '${l10n.alreadyHaveAccount} ',
                                  style: AppTextStyles.small(
                                    color: AppColors.slateGreen,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: l10n.login,
                                      style: AppTextStyles.small(
                                        color: AppColors.forestGreen,
                                      ).copyWith(fontWeight: AppFont.semiBold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 12.h),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Feature extends StatelessWidget {
  const _Feature({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final SvgGenImage icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return AppSoftCard(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      child: Row(
        children: [
          AppIconBox(
            background: AppColors.white,
            child: AppIcon(icon, size: 20.w, color: AppColors.fern),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: AppTextStyles.h4(color: AppColors.fern)),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: AppTextStyles.small(color: AppColors.slateGreen),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguagePill extends StatelessWidget {
  const _LanguagePill({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final code = Localizations.localeOf(context).languageCode.toUpperCase();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: AppColors.fog,
          borderRadius: AppRadius.pillRadius,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.language_rounded,
                size: 15.sp, color: AppColors.slateGreen),
            SizedBox(width: 6.w),
            Text(
              code,
              style: AppTextStyles.label(color: AppColors.slateGreen)
                  .copyWith(fontWeight: AppFont.semiBold),
            ),
          ],
        ),
      ),
    );
  }
}
