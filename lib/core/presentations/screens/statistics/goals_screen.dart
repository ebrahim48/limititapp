import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:limit_it_app/controllers/motivation_controller.dart';
import 'package:limit_it_app/controllers/stats_controller.dart';
import 'package:limit_it_app/core/helpers/localization_helper.dart';
import 'package:limit_it_app/core/services/usage_history_service.dart';
import '../../widgets/ui/ui.dart';

/// Daily screen-time goal, the month's hit/miss grid and streaks.
class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final StatsController _stats = Get.put(StatsController());
  final MotivationController _motivation = Get.put(MotivationController());

  List<DailyStats> _month = const [];

  @override
  void initState() {
    super.initState();
    _load();
    if (_motivation.motivations.isEmpty) {
      _motivation.getMotivationalPhrases();
    }
  }

  Future<void> _load() async {
    final month = await _stats.seriesFor(StatsRange.month);
    if (mounted) setState(() => _month = month);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppScaffold(
      appBar: AppTopBar(title: l10n.goals),
      body: Obx(() {
        final goal = _stats.goalMinutes.value;
        final used = _stats.screenTimeMinutes.value;
        final progress = goal == 0 ? 0.0 : (used / goal).clamp(0.0, 1.0);
        final tracked = _month.where((d) => d.goalMinutes > 0).toList();
        final met = tracked.where((d) => d.goalMet).length;

        return ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(bottom: 24.h),
          children: [
            /// ---------------- Daily goal ----------------
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.dailyGoal, style: AppTextStyles.h4()),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      AppRingMeter(
                        value: progress,
                        size: 92.w,
                        stroke: 9.w,
                        child: FittedBox(
                          child: Text(
                            '${(progress * 100).round()}%',
                            style: AppTextStyles.h3(
                              color: AppColors.forestGreen,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              goal == 0
                                  ? l10n.noGoalSet
                                  : StatsController.formatMinutes(goal),
                              style: AppTextStyles.h2(
                                color: AppColors.forestGreen,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              l10n.dailyScreenTimeLimit,
                              style: AppTextStyles.small(
                                color: AppColors.slateGreen,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            AppProgressBar(value: progress),
                            SizedBox(height: 6.h),
                            Text(
                              l10n.usedToday(
                                StatsController.formatMinutes(used),
                              ),
                              style: AppTextStyles.caption(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            /// ---------------- Days goal was met ----------------
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(l10n.daysGoalWasMet,
                            style: AppTextStyles.h4()),
                      ),
                      Text(
                        '$met/${tracked.length}',
                        style: AppTextStyles.h4(color: AppColors.forestGreen),
                      ),
                    ],
                  ),
                  SizedBox(height: 14.h),
                  if (_month.isEmpty)
                    Text(
                      l10n.noHistoryYet,
                      style: AppTextStyles.small(color: AppColors.mist),
                    )
                  else
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: [
                        for (final day in _month)
                          _GoalDot(
                            state: day.goalMinutes == 0
                                ? _GoalState.untracked
                                : (day.goalMet
                                    ? _GoalState.met
                                    : _GoalState.missed),
                          ),
                      ],
                    ),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            /// ---------------- Streaks ----------------
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.streaks, style: AppTextStyles.h4()),
                  SizedBox(height: 14.h),
                  Row(
                    children: [
                      Expanded(
                        child: StatTile.green(
                          value: '${_stats.currentStreak.value}',
                          label: l10n.currentStreak,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: StatTile.amber(
                          value: '${_stats.bestStreak.value}',
                          label: l10n.bestStreak,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            /// ---------------- Motivation ----------------
            Obx(() {
              final quotes = _motivation.motivations;
              if (quotes.isEmpty) return const SizedBox.shrink();
              return AppSoftCard(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                child: Text(
                  '“${quotes.first.content}”',
                  style: AppTextStyles.body(color: AppColors.fern)
                      .copyWith(fontStyle: FontStyle.italic),
                ),
              );
            }),
          ],
        );
      }),
    );
  }
}

enum _GoalState { met, missed, untracked }

class _GoalDot extends StatelessWidget {
  const _GoalDot({required this.state});

  final _GoalState state;

  @override
  Widget build(BuildContext context) {
    final size = 28.w;

    switch (state) {
      case _GoalState.met:
        return Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.leafGreen,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check_rounded, size: 16.sp, color: AppColors.white),
        );
      case _GoalState.missed:
        return Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.alertRed, width: 1.4),
          ),
          child: Icon(Icons.close_rounded, size: 15.sp, color: AppColors.alertRed),
        );
      case _GoalState.untracked:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.haze),
          ),
        );
    }
  }
}
