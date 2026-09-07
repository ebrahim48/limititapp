import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:limit_it_app/controllers/premium_controller.dart';
import 'package:limit_it_app/controllers/profile_controller.dart';
import 'package:limit_it_app/controllers/stats_controller.dart';
import 'package:limit_it_app/core/config/app_routes/app_routes.dart';
import 'package:limit_it_app/core/helpers/delete_account_dialog.dart';
import 'package:limit_it_app/core/helpers/localization_helper.dart';
import 'package:limit_it_app/global/custom_assets/assets.gen.dart';
import '../../widgets/ui/ui.dart';

/// Settings tab root — account card, the two headline stats, and the menu.
class SettingsHomeScreen extends StatefulWidget {
  const SettingsHomeScreen({super.key});

  @override
  State<SettingsHomeScreen> createState() => _SettingsHomeScreenState();
}

class _SettingsHomeScreenState extends State<SettingsHomeScreen> {
  final PremiumController _premium = Get.find<PremiumController>();
  final ProfileController _profile = Get.find<ProfileController>();
  final StatsController _stats = Get.put(StatsController());

  @override
  void initState() {
    super.initState();
    if (_profile.userProfile.value == null) {
      _profile.getProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppScaffold(
      appBar: AppTopBar(title: l10n.settings, showBack: false),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(bottom: 24.h),
        children: [
          /// ---------------- Account ----------------
          Obx(() {
            final profile = _profile.userProfile.value;
            final isPremium = _premium.isPremium.value;

            return AppSoftCard(
              padding: EdgeInsets.all(16.w),
              onTap: () => context.pushNamed(AppRoutes.viewProfileScreen),
              child: Row(
                children: [
                  Assets.illustrations.leafBadge.svg(width: 48.w, height: 48.w),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          profile?.name?.trim().isNotEmpty == true
                              ? profile!.name!
                              : l10n.appTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.h3(color: AppColors.fern),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          isPremium ? l10n.premiumMember : l10n.freePlan,
                          style: AppTextStyles.small(color: AppColors.fern),
                        ),
                      ],
                    ),
                  ),
                  if (isPremium)
                    AppBadge.premium(
                      label: l10n.premium.toUpperCase(),
                      icon: AppIcon(
                        Assets.icons.ui.crown,
                        size: 13.w,
                        color: AppColors.warmText,
                      ),
                    ),
                ],
              ),
            );
          }),

          SizedBox(height: 12.h),

          /// ---------------- Headline stats ----------------
          Obx(
            () => Row(
              children: [
                Expanded(
                  child: StatTile.green(
                    value: StatsController.formatMinutes(
                      _stats.savedMinutes.value,
                    ),
                    label: l10n.timeSaved,
                    onTap: () => context.pushNamed(AppRoutes.timeSavedScreen),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: StatTile.green(
                    value: '${_stats.blockedOpens.value}',
                    label: l10n.openingsBlocked,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20.h),

          /// ---------------- Main menu ----------------
          AppCardList(
            children: [
              AppListRow(
                leading: AppIconBox(
                  child: AppIcon(Assets.icons.ui.gear,
                      size: 18.w, color: AppColors.fern),
                ),
                title: l10n.appProtections,
                onTap: () => context.pushNamed(AppRoutes.appProtectionScreen),
              ),
              AppListRow(
                leading: AppIconBox(
                  child: AppIcon(Assets.icons.ui.bell,
                      size: 18.w, color: AppColors.fern),
                ),
                title: l10n.reminders,
                onTap: () => context.pushNamed(AppRoutes.remindersScreen),
              ),
              AppListRow(
                leading: AppIconBox(
                  child: AppIcon(Assets.icons.ui.shieldLock,
                      size: 18.w, color: AppColors.fern),
                ),
                title: l10n.privacy,
                onTap: () => context.pushNamed(AppRoutes.privacyScreen),
              ),
              AppListRow(
                leading: AppIconBox(
                  child: AppIcon(Assets.icons.ui.help,
                      size: 18.w, color: AppColors.fern),
                ),
                title: l10n.helpAndFaq,
                onTap: () => context.pushNamed(AppRoutes.helpSupportScreen),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          /// ---------------- Secondary menu ----------------
          AppCardList(
            children: [
              AppListRow(
                title: l10n.backupAndRestore,
                onTap: () => context.pushNamed(AppRoutes.backupRestoreScreen),
              ),
              AppListRow(
                title: l10n.aboutLimitIt,
                onTap: () => context.pushNamed(AppRoutes.aboutLimitItScreen),
              ),
              AppListRow(
                title: l10n.language,
                onTap: () => context.pushNamed(AppRoutes.languageScreen),
              ),
              AppListRow(
                title: l10n.changePassword,
                onTap: () => context.pushNamed(AppRoutes.changePasswordScreen),
              ),
              AppListRow(
                title: l10n.pinSettings,
                onTap: () => context.pushNamed(AppRoutes.pinSettingsScreen),
              ),
              AppListRow(
                title: l10n.motivationalPhrases,
                onTap: () =>
                    context.pushNamed(AppRoutes.motivationPhrasesScreen),
              ),
              AppListRow(
                titleColor: AppColors.alertRed,
                title: l10n.deleteAccount,
                onTap: () => showDeleteAccountDialog(context),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          /// ---------------- Log out ----------------
          AppCard(
            padding: EdgeInsets.zero,
            borderColor: AppColors.alertRed.withValues(alpha: 0.35),
            child: AppListRow(
              showChevron: false,
              titleColor: AppColors.alertRed,
              leading: AppIcon(
                Assets.icons.ui.logout,
                size: 20.w,
                color: AppColors.alertRed,
              ),
              title: l10n.logOut,
              onTap: () => context.pushNamed(AppRoutes.logoutScreen),
            ),
          ),
        ],
      ),
    );
  }
}
