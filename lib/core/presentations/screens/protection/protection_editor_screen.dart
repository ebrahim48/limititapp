import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:limit_it_app/core/config/app_routes/app_routes.dart';
import 'package:limit_it_app/core/helpers/localization_helper.dart';
import 'package:limit_it_app/core/models/app_limit_model.dart';
import 'package:limit_it_app/core/services/app_limit_storage_service.dart';
import 'package:limit_it_app/global/custom_assets/assets.gen.dart';
import '../../widgets/ui/ui.dart';

/// Create or edit the protection for one app.
///
/// Opened with `{'selectedApp': SelectedAppInfo}` to create, or
/// `{'packageName': String}` to edit an existing protection.
class ProtectionEditorScreen extends StatefulWidget {
  const ProtectionEditorScreen({
    super.key,
    this.selectedApp,
    this.packageName,
    this.initialType,
  });

  final SelectedAppInfo? selectedApp;
  final String? packageName;

  /// Picked on the function chooser when creating a new protection.
  final ProtectionType? initialType;

  @override
  State<ProtectionEditorScreen> createState() => _ProtectionEditorScreenState();
}

class _ProtectionEditorScreenState extends State<ProtectionEditorScreen> {
  static const List<String> _weekDays = [
    'SUN',
    'MON',
    'TUE',
    'WED',
    'THU',
    'FRI',
    'SAT',
  ];

  AppLimitModel? _existing;
  bool _isLoading = true;
  bool _isSaving = false;

  late String _packageName;
  late String _appName;
  dynamic _appIcon;

  ProtectionType _type = ProtectionType.dailyLimit;
  int _dailyLimitMinutes = 30;
  int _maxOpens = 4;
  int _delaySeconds = 10;
  TimeOfDay _blockStart = const TimeOfDay(hour: 23, minute: 0);
  TimeOfDay _blockEnd = const TimeOfDay(hour: 8, minute: 5);
  Set<String> _activeDays = _weekDays.toSet();
  String? _customMessage;

  bool get _isEditing => _existing != null;

  @override
  void initState() {
    super.initState();
    _type = widget.initialType ?? _type;
    _packageName = widget.selectedApp?.packageName ?? widget.packageName ?? '';
    _appName = widget.selectedApp?.appName ?? '';
    _appIcon = widget.selectedApp?.appIcon;
    _load();
  }

  Future<void> _load() async {
    try {
      final limit =
          await AppLimitStorageService.instance.getAppLimit(_packageName);

      if (limit != null) {
        _existing = limit;
        _appName = limit.appName;
        _appIcon = limit.appIcon ?? _appIcon;
        _type = limit.protectionType;
        _maxOpens = limit.maxDailyOpens > 0 ? limit.maxDailyOpens : 4;
        _delaySeconds = limit.delaySeconds > 0 ? limit.delaySeconds : 10;
        _dailyLimitMinutes = limit.maxSessionDurationMinutes > 0
            ? limit.maxSessionDurationMinutes
            : 30;
        _customMessage = limit.customMessage;
        if (limit.activeDays.isNotEmpty) {
          _activeDays = limit.activeDays.toSet();
        }
        _blockStart = _parseTime(limit.scheduleStartTime?.value) ?? _blockStart;
        _blockEnd = _parseTime(limit.scheduleEndTime?.value) ?? _blockEnd;
      }
    } catch (e) {
      debugPrint('Error loading protection: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  TimeOfDay? _parseTime(String? raw) {
    if (raw == null || !raw.contains(':')) return null;
    final parts = raw.split(':');
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return TimeOfDay(hour: h, minute: m);
  }

  String _format(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  String get _typeLabel {
    final l10n = context.l10n;
    switch (_type) {
      case ProtectionType.delayOpening:
        return l10n.delayAppOpening;
      case ProtectionType.dailyLimit:
        return l10n.dailyTimeLimit;
      case ProtectionType.maxOpens:
        return l10n.maxOpeningsLabel;
      case ProtectionType.timeBlock:
        return l10n.timeBlock;
    }
  }

  String get _daysLabel {
    final l10n = context.l10n;
    if (_activeDays.length == 7) return l10n.everyDay;
    const weekdays = {'MON', 'TUE', 'WED', 'THU', 'FRI'};
    const weekend = {'SAT', 'SUN'};
    if (_activeDays.length == 5 && _activeDays.containsAll(weekdays)) {
      return l10n.weekdays;
    }
    if (_activeDays.length == 2 && _activeDays.containsAll(weekend)) {
      return l10n.weekends;
    }
    return l10n.custom;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (_isLoading) {
      return AppScaffold(
        appBar: AppTopBar(title: l10n.editProtection),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.leafGreen),
        ),
      );
    }

    return AppScaffold(
      appBar: AppTopBar(
        title: _isEditing ? l10n.editProtection : l10n.newProtection,
      ),
      bottomBar: AppButton(
        label: _isEditing ? l10n.saveChanges : l10n.activateProtection,
        loading: _isSaving,
        onPressed: _save,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(bottom: 110.h),
        children: [
          /// ---------------- App identity ----------------
          Center(
            child: Column(
              children: [
                AppLogoTile(
                  packageName: _packageName,
                  appName: _appName,
                  preloadedIcon: _appIcon,
                  size: 48.w,
                ),
                if (_appName.trim().isNotEmpty) ...[
                  SizedBox(height: 10.h),
                  Text(_appName, style: AppTextStyles.h3()),
                ],
                SizedBox(height: 8.h),
                AppBadge.mint(_typeLabel),
              ],
            ),
          ),

          SizedBox(height: 28.h),

          /// ---------------- Protection type ----------------
          SectionLabel(l10n.protection),
          AppSelectableTile(
            selected: _type == ProtectionType.delayOpening,
            onTap: () => setState(() => _type = ProtectionType.delayOpening),
            child: _TileLabel(
              icon: Assets.icons.ui.clock,
              title: l10n.delayAppOpening,
              subtitle: l10n.delayAppOpeningHint,
            ),
          ),
          SizedBox(height: 8.h),
          AppSelectableTile(
            selected: _type == ProtectionType.dailyLimit,
            onTap: () => setState(() => _type = ProtectionType.dailyLimit),
            child: _TileLabel(
              icon: Assets.icons.ui.restore,
              title: l10n.dailyTimeLimit,
              subtitle: l10n.dailyTimeLimitHint,
            ),
          ),
          SizedBox(height: 8.h),
          AppSelectableTile(
            selected: _type == ProtectionType.maxOpens,
            onTap: () => setState(() => _type = ProtectionType.maxOpens),
            child: _TileLabel(
              icon: Assets.icons.ui.device,
              title: l10n.maxOpeningsLabel,
              subtitle: l10n.maxOpeningsHint,
            ),
          ),
          SizedBox(height: 8.h),
          AppSelectableTile(
            selected: _type == ProtectionType.timeBlock,
            onTap: () => setState(() => _type = ProtectionType.timeBlock),
            child: _TileLabel(
              icon: Assets.icons.ui.moon,
              title: l10n.timeBlock,
              subtitle: l10n.timeBlockHint,
            ),
          ),

          SizedBox(height: 20.h),

          /// ---------------- Type-specific control ----------------
          if (_type == ProtectionType.delayOpening)
            _StepperCard(
              label: l10n.pauseDuration,
              value: l10n.secondsShort(_delaySeconds),
              onDecrease: _delaySeconds > 5
                  ? () => setState(() => _delaySeconds -= 5)
                  : null,
              onIncrease: _delaySeconds < 60
                  ? () => setState(() => _delaySeconds += 5)
                  : null,
            )
          else if (_type == ProtectionType.dailyLimit)
            _StepperCard(
              label: l10n.dailyTimeLimit,
              value: '${_dailyLimitMinutes ~/ 60}h ${_dailyLimitMinutes % 60}m',
              onDecrease: _dailyLimitMinutes > 5
                  ? () => setState(() => _dailyLimitMinutes -= 5)
                  : null,
              onIncrease: _dailyLimitMinutes < 480
                  ? () => setState(() => _dailyLimitMinutes += 5)
                  : null,
            )
          else if (_type == ProtectionType.maxOpens)
            _StepperCard(
              label: l10n.maxOpeningsLabel,
              value: '$_maxOpens / ${l10n.day}',
              onDecrease:
                  _maxOpens > 1 ? () => setState(() => _maxOpens -= 1) : null,
              onIncrease:
                  _maxOpens < 50 ? () => setState(() => _maxOpens += 1) : null,
            )
          else
            AppCard(
              child: Row(
                children: [
                  Expanded(
                    child: _TimeButton(
                      label: l10n.from,
                      value: _format(_blockStart),
                      onTap: () => _pickTime(isStart: true),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _TimeButton(
                      label: l10n.to,
                      value: _format(_blockEnd),
                      onTap: () => _pickTime(isStart: false),
                    ),
                  ),
                ],
              ),
            ),

          SizedBox(height: 24.h),

          /// ---------------- More options ----------------
          SectionLabel(l10n.moreOptions),
          AppCardList(
            children: [
              AppListRow(
                title: l10n.customizeMessage,
                subtitle: (_customMessage?.trim().isNotEmpty ?? false)
                    ? _customMessage
                    : l10n.defaultLabel,
                onTap: _openCustomizeMessage,
              ),
              AppListRow(
                title: l10n.customizeDays,
                subtitle: _daysLabel,
                onTap: _openCustomizeDays,
              ),
              AppListRow(
                title: l10n.previewPause,
                onTap: _openPreviewPause,
              ),
            ],
          ),

          if (_isEditing) ...[
            SizedBox(height: 20.h),
            AppButton(
              label: l10n.deleteProtection,
              variant: AppButtonVariant.destructiveOutline,
              onPressed: _confirmDelete,
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pickTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _blockStart : _blockEnd,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: AppColors.forestGreen,
                onPrimary: AppColors.white,
              ),
        ),
        child: child!,
      ),
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (isStart) {
        _blockStart = picked;
      } else {
        _blockEnd = picked;
      }
    });
  }

  Future<void> _openCustomizeMessage() async {
    final result = await context.pushNamed<String>(
      AppRoutes.customizeMessageScreen,
      extra: {'message': _customMessage ?? ''},
    );
    if (result != null && mounted) {
      setState(() => _customMessage = result);
    }
  }

  Future<void> _openCustomizeDays() async {
    final result = await context.pushNamed<List<String>>(
      AppRoutes.customizeDaysScreen,
      extra: {'days': _activeDays.toList()},
    );
    if (result != null && mounted) {
      setState(() => _activeDays = result.toSet());
    }
  }

  void _openPreviewPause() {
    context.pushNamed(
      AppRoutes.previewPauseScreen,
      extra: {
        'packageName': _packageName,
        'appName': _appName,
        'message': _customMessage ?? '',
        'seconds': _delaySeconds,
      },
    );
  }

  Future<void> _confirmDelete() async {
    final l10n = context.l10n;
    await showAppConfirmSheet(
      context,
      title: l10n.deleteProtectionQuestion,
      message: l10n.deleteProtectionMessage(_appName),
      confirmLabel: l10n.delete,
      cancelLabel: l10n.cancel,
      onConfirm: () async {
        await AppLimitStorageService.instance.deleteAppLimit(_packageName);
        if (mounted) context.pop();
      },
    );
  }

  Future<void> _save() async {
    if (_packageName.isEmpty) return;
    setState(() => _isSaving = true);

    try {
      final service = Get.find<AppLimitStorageService>();
      final limits = await service.getAppLimits();

      final updated = AppLimitModel(
        packageName: _packageName,
        appName: _appName,
        appIcon: _appIcon,
        maxDailyOpens: _type == ProtectionType.maxOpens ? _maxOpens : 0,
        delaySeconds:
            _type == ProtectionType.delayOpening ? _delaySeconds : 0,
        maxSessionDurationMinutes:
            _type == ProtectionType.dailyLimit ? _dailyLimitMinutes : 0,
        activeDays: _activeDays.toList(),
        scheduleStartTime: _type == ProtectionType.timeBlock
            ? RxString(_format(_blockStart))
            : null,
        scheduleEndTime: _type == ProtectionType.timeBlock
            ? RxString(_format(_blockEnd))
            : null,
        isActive: RxBool(true),
        protectionType: _type,
        customMessage: _customMessage,
        createdAt: _existing?.createdAt,
      );

      limits.removeWhere((l) => l.packageName == _packageName);
      limits.add(updated);

      final saved = await service.saveAppLimits(limits);
      if (!mounted) return;

      if (saved) {
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.errorSavingSettings)),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${context.l10n.errorSavingSettings}: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

class _TileLabel extends StatelessWidget {
  const _TileLabel({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final SvgGenImage icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppIcon(icon, size: 20.w, color: AppColors.fern),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: AppTextStyles.h4()),
              SizedBox(height: 2.h),
              Text(
                subtitle,
                style: AppTextStyles.small(color: AppColors.slateGreen),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StepperCard extends StatelessWidget {
  const _StepperCard({
    required this.label,
    required this.value,
    this.onDecrease,
    this.onIncrease,
  });

  final String label;
  final String value;
  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: AppTextStyles.label()),
                SizedBox(height: 4.h),
                Text(value, style: AppTextStyles.h2(color: AppColors.forestGreen)),
              ],
            ),
          ),
          _RoundIconButton(icon: Icons.remove_rounded, onTap: onDecrease),
          SizedBox(width: 10.w),
          _RoundIconButton(icon: Icons.add_rounded, onTap: onIncrease),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38.w,
        height: 38.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: enabled ? AppColors.mint : AppColors.fog,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 20.sp,
          color: enabled ? AppColors.fern : AppColors.mist,
        ),
      ),
    );
  }
}

class _TimeButton extends StatelessWidget {
  const _TimeButton({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.mint,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: AppTextStyles.caption(color: AppColors.fern)),
            SizedBox(height: 2.h),
            Text(value, style: AppTextStyles.h3(color: AppColors.forestGreen)),
          ],
        ),
      ),
    );
  }
}
