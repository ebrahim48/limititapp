import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:limit_it_app/controllers/premium_controller.dart';
import 'package:limit_it_app/core/config/app_routes/app_routes.dart';
import 'package:limit_it_app/core/helpers/localization_helper.dart';
import 'package:limit_it_app/global/custom_assets/assets.gen.dart';
import '../../widgets/ui/ui.dart';

/// Current plan, renewal date and the actions around it.
///
/// [embedded] renders it as the Premium tab root (no back button).
class ManageSubscriptionScreen extends StatelessWidget {
  const ManageSubscriptionScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final premium = Get.find<PremiumController>();

    return AppScaffold(
      appBar: AppTopBar(
        title: l10n.manageSubscription,
        showBack: !embedded,
      ),
      body: Obx(() {
        final renewal = premium.renewalDate;
        final renewalLabel = renewal == null
            ? '—'
            : DateFormat.yMMMMd(Localizations.localeOf(context).toString())
                .format(renewal);

        return ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(bottom: 24.h),
          children: [
            /// ---------------- Current plan ----------------
            AppSoftCard(
              padding: EdgeInsets.all(18.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44.w,
                        height: 44.w,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: AppIcon(
                          Assets.icons.ui.crown,
                          size: 22.w,
                          color: AppColors.gold,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              premium.planName.value.isEmpty
                                  ? l10n.limitItPremium
                                  : premium.planName.value,
                              style: AppTextStyles.h3(color: AppColors.fern),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              l10n.activeSubscription,
                              style: AppTextStyles.small(color: AppColors.fern),
                            ),
                          ],
                        ),
                      ),
                      AppBadge.leaf(l10n.active),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Expanded(
                        child: _MetaBlock(
                          label: l10n.price,
                          value: premium.planPrice.value.isEmpty
                              ? '—'
                              : premium.planPrice.value,
                        ),
                      ),
                      Expanded(
                        child: _MetaBlock(
                          label: l10n.renewsOn,
                          value: renewalLabel,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            SectionLabel(l10n.options),
            AppCardList(
              children: [
                AppListRow(
                  title: l10n.changePlan,
                  subtitle: l10n.changePlanSubtitle,
                  onTap: () => context.pushNamed(AppRoutes.choosePlanScreen),
                ),
                AppListRow(
                  title: l10n.billingHistory,
                  subtitle: l10n.billingHistorySubtitle,
                  onTap: () => context.pushNamed(AppRoutes.subscriptionScreen),
                ),
              ],
            ),

            SizedBox(height: 20.h),

            AppButton(
              label: l10n.cancelSubscription,
              variant: AppButtonVariant.destructiveOutline,
              onPressed: () =>
                  context.pushNamed(AppRoutes.cancelSubscriptionScreen),
            ),
          ],
        );
      }),
    );
  }
}

class _MetaBlock extends StatelessWidget {
  const _MetaBlock({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: AppTextStyles.caption(color: AppColors.fern)),
        SizedBox(height: 2.h),
        Text(value, style: AppTextStyles.h4(color: AppColors.forestGreen)),
      ],
    );
  }
}
