import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:limit_it_app/core/config/app_routes/app_routes.dart';
import 'package:limit_it_app/core/helpers/localization_helper.dart';
import 'package:limit_it_app/global/custom_assets/assets.gen.dart';
import '../../widgets/ui/ui.dart';

/// App identity, version and the legal links.
class AboutLimitItScreen extends StatelessWidget {
  const AboutLimitItScreen({super.key});

  /// Keep in sync with `version:` in pubspec.yaml.
  static const String appVersion = '1.0.0';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppScaffold(
      appBar: AppTopBar(title: l10n.aboutLimitIt),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(bottom: 24.h),
        children: [
          SizedBox(height: 40.h),
          Center(
            child: Assets.illustrations.leafLogo.svg(
              width: 88.w,
              height: 88.w,
            ),
          ),
          SizedBox(height: 18.h),
          Text(
            l10n.appTitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.h2(),
          ),
          SizedBox(height: 10.h),
          Center(child: AppBadge.mint('${l10n.version} $appVersion')),
          SizedBox(height: 18.h),
          Text(
            l10n.aboutLimitItBody,
            textAlign: TextAlign.center,
            style: AppTextStyles.body(color: AppColors.slateGreen),
          ),

          SizedBox(height: 28.h),

          AppCardList(
            children: [
              AppListRow(
                title: l10n.privacyPolicy,
                onTap: () => context.pushNamed(AppRoutes.privacyPolicyScreen),
              ),
              AppListRow(
                title: l10n.termsAndConditions,
                onTap: () => context.pushNamed(AppRoutes.termsServicesScreen),
              ),
              AppListRow(
                title: l10n.aboutUs,
                onTap: () => context.pushNamed(AppRoutes.aboutUsScreen),
              ),
            ],
          ),

          SizedBox(height: 28.h),
          Text(
            l10n.copyrightLine(DateTime.now().year),
            textAlign: TextAlign.center,
            style: AppTextStyles.caption(),
          ),
        ],
      ),
    );
  }
}
