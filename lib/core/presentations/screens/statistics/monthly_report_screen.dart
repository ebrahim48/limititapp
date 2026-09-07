import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:limit_it_app/controllers/stats_controller.dart';
import 'package:limit_it_app/core/helpers/localization_helper.dart';
import 'package:limit_it_app/core/services/usage_history_service.dart';
import 'package:limit_it_app/global/custom_assets/assets.gen.dart';
import '../../widgets/ui/ui.dart';

/// The month in one page — totals, reduction, streaks and progress.
class MonthlyReportScreen extends StatefulWidget {
  const MonthlyReportScreen({super.key});

  @override
  State<MonthlyReportScreen> createState() => _MonthlyReportScreenState();
}

class _MonthlyReportScreenState extends State<MonthlyReportScreen> {
  final StatsController _stats = Get.put(StatsController());

  DateTime _anchor = DateTime.now();
  List<DailyStats> _month = const [];
  List<DailyStats> _previousMonth = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final history = UsageHistoryService.instance;
    final first = DateTime(_anchor.year, _anchor.month, 1);
    final last = DateTime(_anchor.year, _anchor.month + 1, 0);

    final month = await history.getRange(first, last);
    final previous = await history.getRange(
      DateTime(_anchor.year, _anchor.month - 1, 1),
      DateTime(_anchor.year, _anchor.month, 0),
    );

    if (mounted) {
      setState(() {
        _month = month;
        _previousMonth = previous;
      });
    }
  }

  void _shiftMonth(int delta) {
    setState(() => _anchor = DateTime(_anchor.year, _anchor.month + delta, 1));
    _load();
  }

  int get _daysInMonth => DateTime(_anchor.year, _anchor.month + 1, 0).day;

  int get _daysCompleted {
    final now = DateTime.now();
    if (_anchor.year == now.year && _anchor.month == now.month) return now.day;
    return _daysInMonth;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final savedTotal = _month.fold<int>(0, (s, d) => s + d.savedMinutes);
    final blockedTotal = _month.fold<int>(0, (s, d) => s + d.blockedOpens);
    final reduction = StatsController.reduction(_month, _previousMonth);
    final progress = _daysInMonth == 0 ? 0.0 : _daysCompleted / _daysInMonth;

    return AppScaffold(
      appBar: AppTopBar(title: l10n.monthlyReport),
      bottomBar: AppButton(
        label: l10n.continueYourMonth,
        onPressed: () => context.pop(),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(bottom: 110.h),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => _shiftMonth(-1),
                icon: Icon(Icons.chevron_left_rounded,
                    size: 24.sp, color: AppColors.slateGreen),
              ),
              Text(
                DateFormat.yMMMM(Localizations.localeOf(context).toString())
                    .format(_anchor),
                style: AppTextStyles.h4(),
              ),
              IconButton(
                onPressed: () => _shiftMonth(1),
                icon: Icon(Icons.chevron_right_rounded,
                    size: 24.sp, color: AppColors.slateGreen),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          ClipRRect(
            borderRadius: AppRadius.cardRadius,
            child: Assets.illustrations.mountainScene.svg(
              width: double.infinity,
              height: 128.h,
              fit: BoxFit.cover,
            ),
          ),

          SizedBox(height: 16.h),

          AppCardList(
            children: [
              _ReportRow(
                label: l10n.timeSaved,
                value: StatsController.formatMinutes(savedTotal),
              ),
              _ReportRow(
                label: l10n.blockedOpens,
                value: '$blockedTotal',
              ),
              _ReportRow(
                label: l10n.usageReduction,
                value:
                    '${reduction < 0 ? '−' : '+'}${reduction.abs().round()}%',
                valueColor: reduction <= 0
                    ? AppColors.forestGreen
                    : AppColors.alertRed,
              ),
              _ReportRow(
                label: l10n.goalStreak,
                value: l10n.daysCount(_stats.currentStreak.value),
              ),
              _ReportRow(
                label: l10n.bestStreak,
                value: l10n.daysCount(_stats.bestStreak.value),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          AppSoftCard(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.monthProgress,
                        style: AppTextStyles.h4(color: AppColors.fern),
                      ),
                    ),
                    Text(
                      '${(progress * 100).round()}%',
                      style: AppTextStyles.h4(color: AppColors.forestGreen),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                AppProgressBar(value: progress, trackColor: AppColors.white),
                SizedBox(height: 8.h),
                Text(
                  l10n.daysCompleted(_daysCompleted, _daysInMonth),
                  style: AppTextStyles.caption(color: AppColors.fern),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportRow extends StatelessWidget {
  const _ReportRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.body(color: AppColors.slateGreen),
            ),
          ),
          Text(
            value,
            style: AppTextStyles.h4(color: valueColor ?? AppColors.ink),
          ),
        ],
      ),
    );
  }
}
