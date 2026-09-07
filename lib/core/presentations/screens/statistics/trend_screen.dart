import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:limit_it_app/controllers/stats_controller.dart';
import 'package:limit_it_app/core/helpers/localization_helper.dart';
import 'package:limit_it_app/core/services/usage_history_service.dart';
import '../../widgets/ui/ui.dart';

/// Screen-time trend against the previous period, with a written insight.
class TrendScreen extends StatefulWidget {
  const TrendScreen({super.key});

  @override
  State<TrendScreen> createState() => _TrendScreenState();
}

class _TrendScreenState extends State<TrendScreen> {
  int _rangeIndex = 1; // Month, as in the design
  DateTime _anchor = DateTime.now();

  List<DailyStats> _current = const [];
  List<DailyStats> _previous = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final history = UsageHistoryService.instance;

    if (_rangeIndex == 0) {
      final end = _anchor;
      final start = end.subtract(const Duration(days: 6));
      final current = await history.getRange(start, end);
      final previous = await history.getRange(
        start.subtract(const Duration(days: 7)),
        start.subtract(const Duration(days: 1)),
      );
      if (mounted) {
        setState(() {
          _current = current;
          _previous = previous;
        });
      }
      return;
    }

    final first = DateTime(_anchor.year, _anchor.month, 1);
    final last = DateTime(_anchor.year, _anchor.month + 1, 0);
    final prevFirst = DateTime(_anchor.year, _anchor.month - 1, 1);
    final prevLast = DateTime(_anchor.year, _anchor.month, 0);

    final current = await history.getRange(first, last);
    final previous = await history.getRange(prevFirst, prevLast);
    if (mounted) {
      setState(() {
        _current = current;
        _previous = previous;
      });
    }
  }

  void _shiftPeriod(int delta) {
    setState(() {
      _anchor = _rangeIndex == 0
          ? _anchor.add(Duration(days: 7 * delta))
          : DateTime(_anchor.year, _anchor.month + delta, 1);
    });
    _load();
  }

  double get _reduction => StatsController.reduction(_current, _previous);

  /// Weekly buckets, so the month chart reads W1…W5 like the design.
  List<double> get _chartValues {
    if (_rangeIndex == 0) {
      return _current.map((d) => d.screenTimeMinutes.toDouble()).toList();
    }

    final buckets = <double>[];
    for (var i = 0; i < _current.length; i += 7) {
      final end = (i + 7).clamp(0, _current.length);
      final slice = _current.sublist(i, end);
      final total = slice.fold<int>(0, (s, d) => s + d.screenTimeMinutes);
      buckets.add(slice.isEmpty ? 0 : total / slice.length);
    }
    return buckets;
  }

  List<String> get _chartLabels {
    if (_rangeIndex == 0) {
      const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
      return _current.map((d) => labels[d.date.weekday - 1]).toList();
    }
    return List.generate(_chartValues.length, (i) => 'W${i + 1}');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final reduced = _reduction < 0;
    final pct = _reduction.abs().round();

    return AppScaffold(
      appBar: AppTopBar(title: l10n.trend),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(bottom: 24.h),
        children: [
          _PeriodStepper(
            label: _periodLabel(context),
            onPrevious: () => _shiftPeriod(-1),
            onNext: () => _shiftPeriod(1),
          ),
          SizedBox(height: 16.h),

          AppSegmentedTabs(
            segments: [l10n.week, l10n.month],
            selectedIndex: _rangeIndex,
            onChanged: (i) {
              setState(() {
                _rangeIndex = i;
                _anchor = DateTime.now();
              });
              _load();
            },
          ),
          SizedBox(height: 20.h),

          AppSoftCard(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.screenTimeReduction,
                  style: AppTextStyles.label(color: AppColors.fern),
                ),
                SizedBox(height: 4.h),
                Text(
                  '${reduced ? '−' : '+'}$pct%',
                  style: AppTextStyles.display(
                    color: reduced ? AppColors.forestGreen : AppColors.alertRed,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  _rangeIndex == 0 ? l10n.vsLastWeek : l10n.vsLastMonth,
                  style: AppTextStyles.small(color: AppColors.fern),
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.screenTimeHours, style: AppTextStyles.h4()),
                SizedBox(height: 16.h),
                AppLineChart(
                  values: _chartValues,
                  labels: _chartLabels,
                  height: 90.h,
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.insight, style: AppTextStyles.h4()),
                SizedBox(height: 8.h),
                Text(
                  reduced ? l10n.insightPositive : l10n.insightNeutral,
                  style: AppTextStyles.body(color: AppColors.slateGreen),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _periodLabel(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    if (_rangeIndex == 1) {
      return DateFormat.yMMMM(locale).format(_anchor);
    }
    final start = _anchor.subtract(const Duration(days: 6));
    return '${DateFormat.MMMd(locale).format(start)} – '
        '${DateFormat.MMMd(locale).format(_anchor)}';
  }
}

/// "‹ May 2025 ›" period switcher.
class _PeriodStepper extends StatelessWidget {
  const _PeriodStepper({
    required this.label,
    required this.onPrevious,
    required this.onNext,
  });

  final String label;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: onPrevious,
          icon: Icon(Icons.chevron_left_rounded,
              size: 24.sp, color: AppColors.slateGreen),
        ),
        Text(label, style: AppTextStyles.h4()),
        IconButton(
          onPressed: onNext,
          icon: Icon(Icons.chevron_right_rounded,
              size: 24.sp, color: AppColors.slateGreen),
        ),
      ],
    );
  }
}
