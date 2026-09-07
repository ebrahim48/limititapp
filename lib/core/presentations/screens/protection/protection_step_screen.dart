import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:limit_it_app/core/config/app_routes/app_routes.dart';
import 'package:limit_it_app/core/helpers/localization_helper.dart';
import 'package:limit_it_app/core/models/app_limit_model.dart';
import 'package:limit_it_app/core/models/protection_draft.dart';
import 'package:limit_it_app/global/custom_assets/assets.gen.dart';
import 'package:limit_it_app/l10n/app_localizations.dart';
import '../../widgets/ui/ui.dart';

/// Step 3 of the add-protection wizard: configure the chosen protection.
///
/// One screen per [ProtectionType] — how long the pause is, the daily limit,
/// the number of openings, or the blocked time range — then on to the review.
class ProtectionStepScreen extends StatefulWidget {
  const ProtectionStepScreen({super.key, required this.draft});

  final ProtectionDraft draft;

  @override
  State<ProtectionStepScreen> createState() => _ProtectionStepScreenState();
}

class _ProtectionStepScreenState extends State<ProtectionStepScreen> {
  /// Pause lengths offered by the design; 10s is the recommended one.
  static const List<int> _pauseOptions = [5, 10, 15, 20, 30];
  static const int _recommendedPause = 10;

  late ProtectionDraft _draft = widget.draft;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppScaffold(
      appBar: AppTopBar(title: _title(l10n), titleStyle: AppTextStyles.h3()),
      body: switch (_draft.type) {
        ProtectionType.delayOpening => _buildPauseStep(l10n),
        ProtectionType.dailyLimit => _buildDailyLimitStep(l10n),
        ProtectionType.maxOpens => _buildOpeningsStep(l10n),
        ProtectionType.timeBlock => _buildTimeBlockStep(l10n),
      },
      bottomBar: AppButton(label: l10n.next, onPressed: _goToReview),
    );
  }

  String _title(AppLocalizations l10n) => switch (_draft.type) {
        ProtectionType.delayOpening => l10n.howLongShouldThePauseBe,
        ProtectionType.dailyLimit => l10n.whatsYourDailyLimit,
        ProtectionType.maxOpens => l10n.howManyTimesPerDay,
        ProtectionType.timeBlock => l10n.whenDoYouWantToBlockIt,
      };

  void _goToReview() {
    context.pushNamed(AppRoutes.protectionReviewScreen, extra: _draft);
  }

  /// ---------------- Delay app opening ----------------

  Widget _buildPauseStep(AppLocalizations l10n) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(bottom: 100.h),
      children: [
        Text(
          l10n.pauseStepHint,
          style: AppTextStyles.body(color: AppColors.mist),
        ),
        SizedBox(height: 20.h),
        for (final seconds in _pauseOptions) ...[
          _PauseOption(
            label: l10n.secondsShort(seconds),
            selected: _draft.delaySeconds == seconds,
            recommended: seconds == _recommendedPause,
            recommendedLabel: l10n.recommended,
            onTap: () =>
                setState(() => _draft = _draft.copyWith(delaySeconds: seconds)),
          ),
          SizedBox(height: 12.h),
        ],
      ],
    );
  }

  /// ---------------- Daily time limit ----------------

  Widget _buildDailyLimitStep(AppLocalizations l10n) {
    final hours = _draft.dailyLimitMinutes ~/ 60;
    final minutes = _draft.dailyLimitMinutes % 60;

    void setTotal(int total) => setState(
          () => _draft = _draft.copyWith(dailyLimitMinutes: total.clamp(5, 1439)),
        );

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.setAMaximumTimePerDay,
            style: AppTextStyles.body(color: AppColors.mist),
          ),
          SizedBox(height: 28.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _UnitSpinner(
                value: hours.toString().padLeft(2, '0'),
                unit: l10n.hoursLabel,
                onIncrease: hours < 23
                    ? () => setTotal(_draft.dailyLimitMinutes + 60)
                    : null,
                onDecrease: hours > 0
                    ? () => setTotal(_draft.dailyLimitMinutes - 60)
                    : null,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: Text(':', style: AppTextStyles.display()),
              ),
              _UnitSpinner(
                value: minutes.toString().padLeft(2, '0'),
                unit: l10n.minutesLabel,
                onIncrease: () => setTotal(_draft.dailyLimitMinutes + 5),
                onDecrease: () => setTotal(_draft.dailyLimitMinutes - 5),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// ---------------- Opening limit ----------------

  Widget _buildOpeningsStep(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.setMaximumOpeningsPerDay,
            textAlign: TextAlign.center,
            style: AppTextStyles.body(color: AppColors.mist),
          ),
          SizedBox(height: 24.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _RoundStepButton(
                icon: Icons.remove_rounded,
                onTap: _draft.maxOpens > 1
                    ? () => setState(() =>
                        _draft = _draft.copyWith(maxOpens: _draft.maxOpens - 1))
                    : null,
              ),
              SizedBox(width: 28.w),
              Text('${_draft.maxOpens}', style: AppTextStyles.display()),
              SizedBox(width: 28.w),
              _RoundStepButton(
                icon: Icons.add_rounded,
                onTap: _draft.maxOpens < 50
                    ? () => setState(() =>
                        _draft = _draft.copyWith(maxOpens: _draft.maxOpens + 1))
                    : null,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            l10n.openingsPerDay,
            style: AppTextStyles.small(color: AppColors.mist),
          ),
        ],
      ),
    );
  }

  /// ---------------- Time block ----------------

  Widget _buildTimeBlockStep(AppLocalizations l10n) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(bottom: 100.h),
      children: [
        Text(
          l10n.selectTimePeriodToBlock,
          style: AppTextStyles.body(color: AppColors.mist),
        ),
        SizedBox(height: 20.h),
        Row(
          children: [
            Expanded(
              child: _TimeField(
                label: l10n.from,
                time: _draft.blockStart,
                onTap: () => _pickTime(isStart: true),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _TimeField(
                label: l10n.to,
                time: _draft.blockEnd,
                onTap: () => _pickTime(isStart: false),
              ),
            ),
          ],
        ),
        SizedBox(height: 20.h),
        AppSoftCard(
          color: AppColors.mint,
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.blockedTime,
                style: AppTextStyles.small(color: AppColors.fern),
              ),
              SizedBox(height: 4.h),
              Text(
                '${ProtectionDraft.formatTime(_draft.blockStart)} – '
                '${ProtectionDraft.formatTime(_draft.blockEnd)}',
                style: AppTextStyles.h3(color: AppColors.fern),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _pickTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _draft.blockStart : _draft.blockEnd,
    );
    if (picked == null || !mounted) return;
    setState(() {
      _draft = isStart
          ? _draft.copyWith(blockStart: picked)
          : _draft.copyWith(blockEnd: picked);
    });
  }
}

class _PauseOption extends StatelessWidget {
  const _PauseOption({
    required this.label,
    required this.selected,
    required this.recommended,
    required this.recommendedLabel,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool recommended;
  final String recommendedLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      color: selected ? AppColors.mint : AppColors.white,
      borderColor: selected ? AppColors.leafGreen : AppColors.haze,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: selected
                  ? AppTextStyles.h3(color: AppColors.fern)
                  : AppTextStyles.h3(),
            ),
          ),
          if (recommended) ...[
            AppBadge.leaf(recommendedLabel),
            SizedBox(width: 10.w),
          ],
          if (selected)
            Icon(Icons.check_circle_rounded,
                size: 24.sp, color: AppColors.leafGreen),
        ],
      ),
    );
  }
}

/// The ▲ / value / ▼ column the daily-limit step uses for hours and minutes.
class _UnitSpinner extends StatelessWidget {
  const _UnitSpinner({
    required this.value,
    required this.unit,
    required this.onIncrease,
    required this.onDecrease,
  });

  final String value;
  final String unit;
  final VoidCallback? onIncrease;
  final VoidCallback? onDecrease;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Arrow(icon: Icons.arrow_drop_up_rounded, onTap: onIncrease),
        SizedBox(height: 6.h),
        Text(value, style: AppTextStyles.display()),
        SizedBox(height: 6.h),
        _Arrow(icon: Icons.arrow_drop_down_rounded, onTap: onDecrease),
        SizedBox(height: 8.h),
        Text(unit, style: AppTextStyles.small(color: AppColors.mist)),
      ],
    );
  }
}

class _Arrow extends StatelessWidget {
  const _Arrow({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44.w,
        height: 40.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.fog,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: AppColors.haze),
        ),
        child: Icon(
          icon,
          size: 28.sp,
          color: onTap == null ? AppColors.mist : AppColors.ink,
        ),
      ),
    );
  }
}

class _RoundStepButton extends StatelessWidget {
  const _RoundStepButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44.w,
        height: 44.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.haze),
        ),
        child: Icon(
          icon,
          size: 22.sp,
          color: onTap == null ? AppColors.mist : AppColors.ink,
        ),
      ),
    );
  }
}

class _TimeField extends StatelessWidget {
  const _TimeField({
    required this.label,
    required this.time,
    required this.onTap,
  });

  final String label;
  final TimeOfDay time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.small(color: AppColors.mist)),
        SizedBox(height: 6.h),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 52.h,
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            decoration: BoxDecoration(
              color: AppColors.fog,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.haze),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    time.format(context),
                    style: AppTextStyles.bodyMedium(),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Assets.icons.ui.clock.svg(
                  width: 18.w,
                  height: 18.w,
                  colorFilter:
                      const ColorFilter.mode(AppColors.mist, BlendMode.srcIn),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
