import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:limit_it_app/core/config/app_routes/app_routes.dart';
import 'package:limit_it_app/core/helpers/localization_helper.dart';
import 'package:limit_it_app/core/models/app_limit_model.dart';
import 'package:limit_it_app/global/custom_assets/assets.gen.dart';
import '../../widgets/ui/ui.dart';

/// First step of adding a protection: pick what the protection should do.
///
/// The chosen [ProtectionType] is carried into the app picker and lands
/// preselected in the editor, so the rest of the flow is unchanged.
class ChooseFunctionScreen extends StatelessWidget {
  const ChooseFunctionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppScaffold(
      appBar: const AppTopBar(),
      scrollable: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Assets.icons.ui.leaf.svg(
              width: 28.w,
              height: 28.w,
              colorFilter: const ColorFilter.mode(
                AppColors.leafGreen,
                BlendMode.srcIn,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Text(l10n.whatWouldYouLikeToDo, style: AppTextStyles.h1()),
          SizedBox(height: 8.h),
          Text(
            l10n.chooseAFunctionToGetStarted,
            style: AppTextStyles.body(color: AppColors.mist),
          ),
          SizedBox(height: 24.h),

          _FunctionTile(
            icon: Assets.icons.ui.clock,
            title: l10n.delayAppOpening,
            subtitle: l10n.delayAppOpeningHint,
            badge: l10n.recommended,
            highlighted: true,
            onTap: () => _pick(context, ProtectionType.delayOpening),
          ),
          SizedBox(height: 12.h),
          _FunctionTile(
            icon: Assets.icons.ui.restore,
            title: l10n.dailyTimeLimit,
            subtitle: l10n.dailyTimeLimitFunctionHint,
            onTap: () => _pick(context, ProtectionType.dailyLimit),
          ),
          SizedBox(height: 12.h),
          _FunctionTile(
            icon: Assets.icons.ui.device,
            title: l10n.openingLimit,
            subtitle: l10n.openingLimitHint,
            onTap: () => _pick(context, ProtectionType.maxOpens),
          ),
          SizedBox(height: 12.h),
          _FunctionTile(
            icon: Assets.icons.ui.moon,
            title: l10n.timeBlock,
            subtitle: l10n.timeBlockFunctionHint,
            onTap: () => _pick(context, ProtectionType.timeBlock),
          ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  void _pick(BuildContext context, ProtectionType type) {
    context.pushNamed(
      AppRoutes.searchAppScreen,
      extra: {'protectionType': type},
    );
  }
}

class _FunctionTile extends StatelessWidget {
  const _FunctionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badge,
    this.highlighted = false,
  });

  final SvgGenImage icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final String? badge;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      color: highlighted ? AppColors.mint : AppColors.white,
      borderColor: highlighted ? AppColors.leafGreen : AppColors.haze,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: highlighted ? AppColors.leafGreen : AppColors.fog,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: icon.svg(
              width: 22.w,
              height: 22.w,
              colorFilter: ColorFilter.mode(
                highlighted ? AppColors.white : AppColors.ink,
                BlendMode.srcIn,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: Text(title, style: AppTextStyles.h4())),
                    if (badge != null) ...[
                      SizedBox(width: 8.w),
                      AppBadge.leaf(badge!),
                    ],
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: AppTextStyles.small(color: AppColors.mist),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Padding(
            padding: EdgeInsets.only(top: 10.h),
            child: Assets.icons.ui.chevronRight.svg(
              width: 16.w,
              height: 16.w,
              colorFilter: const ColorFilter.mode(
                AppColors.mist,
                BlendMode.srcIn,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
