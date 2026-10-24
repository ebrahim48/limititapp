import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:limit_it_app/core/config/app_routes/app_routes.dart';
import 'package:limit_it_app/core/helpers/localization_helper.dart';
import 'ui/ui.dart';

/// Auto-renew disclosure plus Terms / Privacy links.
///
/// App Store Review (3.1.2) requires both on every screen that sells an
/// auto-renewing subscription.
class SubscriptionLegalFooter extends StatelessWidget {
  const SubscriptionLegalFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.subscriptionAutoRenewNote,
          textAlign: TextAlign.center,
          style: AppTextStyles.caption(),
        ),
        SizedBox(height: 4.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppTextLink(
              label: l10n.termsAndConditions,
              style: AppTextStyles.caption(color: AppColors.slateGreen)
                  .copyWith(decoration: TextDecoration.underline),
              onPressed: () =>
                  context.pushNamed(AppRoutes.termsServicesScreen),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Text('·', style: AppTextStyles.caption()),
            ),
            AppTextLink(
              label: l10n.privacyPolicy,
              style: AppTextStyles.caption(color: AppColors.slateGreen)
                  .copyWith(decoration: TextDecoration.underline),
              onPressed: () =>
                  context.pushNamed(AppRoutes.privacyPolicyScreen),
            ),
          ],
        ),
      ],
    );
  }
}
