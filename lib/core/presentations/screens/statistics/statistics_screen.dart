import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:limit_it_app/controllers/premium_controller.dart';
import 'package:limit_it_app/controllers/stats_controller.dart';
import 'package:limit_it_app/core/config/app_routes/app_routes.dart';
import 'package:limit_it_app/core/helpers/localization_helper.dart';
import 'package:limit_it_app/core/services/usage_history_service.dart';
import 'package:limit_it_app/global/custom_assets/assets.gen.dart';
import '../../widgets/ui/ui.dart';

/// Statistics tab. Locked behind Premium; once unlocked it summarises today
/// and links out to the detail reports.
class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final PremiumController _premium = Get.find<PremiumController>();
  final StatsController _stats = Get.put(StatsController());

  List<DailyStats> _week = const [];

  @override
  void initState() {
    super.initState();
    // Wait for the controller's own load so today's entry is already stored
    // before the week series is read.
    _refresh();
  }

  Future<void> _loadWeek() async {
    final week = await _stats.seriesFor(StatsRange.week);
    if (mounted) setState(() => _week = week);
  }

  Future<void> _refresh() async {
    await _stats.load();
    await _loadWeek();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppScaffold(
      appBar: AppTopBar(title: l10n.statistics, showBack: false),
      body: Obx(() {
        if (!_premium.isPremium.value) return const _LockedStats();

        if (_stats.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.leafGreen),
          );
        }

        return RefreshIndicator(
          color: AppColors.leafGreen,
          onRefresh: _refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: EdgeInsets.only(bottom: 24.h),
            children: [
              /// ---------------- KPI grid ----------------
              Row(
                children: [
                  Expanded(
                    child: StatTile.green(
                      value: StatsController.formatMinutes(
                        _stats.savedMinutes.value,
                      ),
                      label: l10n.timeSaved,
                      sublabel: l10n.today,
                      onTap: () => context.pushNamed(AppRoutes.timeSavedScreen),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: StatTile.blue(
                      value: '${_stats.blockedOpens.value}',
                      label: l10n.blockedOpens,
                      sublabel: l10n.today,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: StatTile.amber(
                      value: StatsController.formatMinutes(
                        _stats.screenTimeMinutes.value,
                      ),
                      label: l10n.screenTime,
                      sublabel: l10n.today,
                      onTap: () => context.pushNamed(AppRoutes.appUsageScreen),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: StatTile.green(
                      value: '${_stats.currentStreak.value}',
                      label: l10n.goalStreak,
                      sublabel: l10n.days,
                      onTap: () => context.pushNamed(AppRoutes.goalsScreen),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20.h),

              /// ---------------- Weekly usage ----------------
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.weeklyUsage, style: AppTextStyles.h4()),
                    SizedBox(height: 16.h),
                    AppBarChart(
                      values: _week
                          .map((d) => d.screenTimeMinutes.toDouble())
                          .toList(),
                      labels: _week.map(_dayLabel).toList(),
                      highlightedIndex: _week.isEmpty ? null : _week.length - 1,
                      height: 96.h,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20.h),

              /// ---------------- Detail reports ----------------
              SectionLabel(l10n.reports),
              AppCardList(
                children: [
                  AppListRow(
                    leading: AppIconBox(
                      child: AppIcon(Assets.icons.ui.clock,
                          size: 18.w, color: AppColors.fern),
                    ),
                    title: l10n.timeSaved,
                    onTap: () => context.pushNamed(AppRoutes.timeSavedScreen),
                  ),
                  AppListRow(
                    leading: AppIconBox(
                      child: AppIcon(Assets.icons.ui.barChart,
                          size: 18.w, color: AppColors.fern),
                    ),
                    title: l10n.appUsage,
                    onTap: () => context.pushNamed(AppRoutes.appUsageScreen),
                  ),
                  AppListRow(
                    leading: AppIconBox(
                      child: AppIcon(Assets.icons.ui.restore,
                          size: 18.w, color: AppColors.fern),
                    ),
                    title: l10n.trend,
                    onTap: () => context.pushNamed(AppRoutes.trendScreen),
                  ),
                  AppListRow(
                    leading: AppIconBox(
                      child: AppIcon(Assets.icons.ui.target,
                          size: 18.w, color: AppColors.fern),
                    ),
                    title: l10n.goals,
                    onTap: () => context.pushNamed(AppRoutes.goalsScreen),
                  ),
                  AppListRow(
                    leading: AppIconBox(
                      child: AppIcon(Assets.icons.ui.calendar,
                          size: 18.w, color: AppColors.fern),
                    ),
                    title: l10n.monthlyReport,
                    onTap: () =>
                        context.pushNamed(AppRoutes.monthlyReportScreen),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }

  String _dayLabel(DailyStats d) {
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return labels[d.date.weekday - 1];
  }
}

/// Free-plan state — the design's "Unlock your stats" screen.
class _LockedStats extends StatelessWidget {
  const _LockedStats();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          SizedBox(height: 24.h),
          Assets.illustrations.statsLocked.svg(width: 190.w, height: 218.w),
          SizedBox(height: 28.h),
          Text(
            l10n.unlockYourStats,
            textAlign: TextAlign.center,
            style: AppTextStyles.h2(),
          ),
          SizedBox(height: 10.h),
          Text(
            l10n.unlockYourStatsSubtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.body(color: AppColors.slateGreen),
          ),
          SizedBox(height: 24.h),
          AppSoftCard(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Column(
              children: [
                _LockedFeature(label: l10n.lockedFeatureTimeSaved),
                SizedBox(height: 10.h),
                _LockedFeature(label: l10n.lockedFeatureTrends),
                SizedBox(height: 10.h),
                _LockedFeature(label: l10n.lockedFeatureGoals),
                SizedBox(height: 10.h),
                _LockedFeature(label: l10n.lockedFeatureReports),
              ],
            ),
          ),
          SizedBox(height: 28.h),
          AppButton(
            label: l10n.unlockWithPremium,
            icon: AppIcon(Assets.icons.ui.crown,
                size: 18.w, color: AppColors.gold),
            onPressed: () => context.pushNamed(AppRoutes.choosePlanScreen),
          ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }
}

class _LockedFeature extends StatelessWidget {
  const _LockedFeature({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.check_circle_rounded, size: 18.sp, color: AppColors.leafGreen),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(label, style: AppTextStyles.bodyMedium(color: AppColors.fern)),
        ),
      ],
    );
  }
}
