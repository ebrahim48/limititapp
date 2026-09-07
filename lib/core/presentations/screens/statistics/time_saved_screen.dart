import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:limit_it_app/controllers/stats_controller.dart';
import 'package:limit_it_app/core/helpers/localization_helper.dart';
import 'package:limit_it_app/core/services/usage_history_service.dart';
import '../../widgets/ui/ui.dart';

/// How much time the protections kept back, this week or this month.
class TimeSavedScreen extends StatefulWidget {
  const TimeSavedScreen({super.key});

  @override
  State<TimeSavedScreen> createState() => _TimeSavedScreenState();
}

class _TimeSavedScreenState extends State<TimeSavedScreen> {
  final StatsController _stats = Get.put(StatsController());

  int _rangeIndex = 0;
  List<DailyStats> _series = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final range = _rangeIndex == 0 ? StatsRange.week : StatsRange.month;
    final series = await _stats.seriesFor(range);
    if (mounted) setState(() => _series = series);
  }

  int get _totalSaved =>
      _series.fold<int>(0, (sum, s) => sum + s.savedMinutes);

  /// Progress against a soft target of 1h saved per day in the period.
  double get _ringValue {
    if (_series.isEmpty) return 0;
    final target = _series.length * 60;
    return target == 0 ? 0 : (_totalSaved / target).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppScaffold(
      appBar: AppTopBar(title: l10n.timeSaved),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(bottom: 24.h),
        children: [
          AppSegmentedTabs(
            segments: [l10n.week, l10n.month],
            selectedIndex: _rangeIndex,
            onChanged: (i) {
              setState(() => _rangeIndex = i);
              _load();
            },
          ),
          SizedBox(height: 20.h),

          AppSoftCard(
            padding: EdgeInsets.symmetric(vertical: 24.h),
            child: Column(
              children: [
                AppRingMeter(
                  value: _ringValue,
                  size: 150.w,
                  stroke: 10.w,
                  child: FittedBox(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          StatsController.formatMinutes(_totalSaved),
                          style: AppTextStyles.h2(color: AppColors.forestGreen),
                        ),
                        SizedBox(height: 2.h),
                        Text(l10n.timeSaved,
                            style: AppTextStyles.caption(color: AppColors.fern)),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  _rangeIndex == 0 ? l10n.thisWeek : l10n.thisMonth,
                  style: AppTextStyles.small(color: AppColors.fern),
                ),
              ],
            ),
          ),

          SizedBox(height: 20.h),

          SectionLabel(l10n.savedByApp),
          Obx(() {
            final savings = _stats.savedByApp;
            if (savings.isEmpty) {
              return AppCard(
                padding: EdgeInsets.symmetric(vertical: 28.h),
                child: Center(
                  child: Text(
                    l10n.nothingSavedYet,
                    style: AppTextStyles.body(color: AppColors.mist),
                  ),
                ),
              );
            }

            final max = savings.first.savedMinutes;
            return AppCard(
              padding: EdgeInsets.symmetric(vertical: 4.h),
              child: Column(
                children: [
                  for (final saving in savings)
                    AppUsageRow(
                      icon: AppLogoTile(
                        packageName: saving.packageName,
                        appName: saving.appName,
                        preloadedIcon: saving.icon,
                        size: 32.w,
                      ),
                      name: saving.appName,
                      value:
                          StatsController.formatMinutes(saving.savedMinutes),
                      fraction: max == 0 ? 0 : saving.savedMinutes / max,
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
