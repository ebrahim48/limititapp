import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:limit_it_app/core/helpers/localization_helper.dart';
import '../../widgets/ui/ui.dart';

/// Pick the days a protection is active — chips plus the four presets.
class CustomizeDaysScreen extends StatefulWidget {
  const CustomizeDaysScreen({super.key, this.initialDays});

  final List<String>? initialDays;

  @override
  State<CustomizeDaysScreen> createState() => _CustomizeDaysScreenState();
}

class _CustomizeDaysScreenState extends State<CustomizeDaysScreen> {
  /// Storage keys, Sunday-first to match the S M T W T F S chip row.
  static const List<String> _keys = [
    'SUN',
    'MON',
    'TUE',
    'WED',
    'THU',
    'FRI',
    'SAT',
  ];
  static const List<String> _labels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  static const Set<String> _weekdayKeys = {'MON', 'TUE', 'WED', 'THU', 'FRI'};
  static const Set<String> _weekendKeys = {'SAT', 'SUN'};

  late Set<String> _selected =
      (widget.initialDays?.isNotEmpty ?? false) ? widget.initialDays!.toSet() : _keys.toSet();

  _Preset get _activePreset {
    if (_selected.length == 7) return _Preset.everyDay;
    if (_selected.length == 5 && _selected.containsAll(_weekdayKeys)) {
      return _Preset.weekdays;
    }
    if (_selected.length == 2 && _selected.containsAll(_weekendKeys)) {
      return _Preset.weekends;
    }
    return _Preset.custom;
  }

  void _applyPreset(_Preset preset) {
    setState(() {
      switch (preset) {
        case _Preset.everyDay:
          _selected = _keys.toSet();
          break;
        case _Preset.weekdays:
          _selected = {..._weekdayKeys};
          break;
        case _Preset.weekends:
          _selected = {..._weekendKeys};
          break;
        case _Preset.custom:
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final preset = _activePreset;

    return AppScaffold(
      appBar: AppTopBar(title: l10n.customizeDays),
      bottomBar: AppButton(
        label: l10n.save,
        enabled: _selected.isNotEmpty,
        onPressed: () => context.pop(_selected.toList()),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(bottom: 110.h),
        children: [
          Text(
            l10n.selectDaysToApply,
            style: AppTextStyles.body(color: AppColors.slateGreen),
          ),
          SizedBox(height: 20.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < _keys.length; i++)
                AppDayChip(
                  label: _labels[i],
                  selected: _selected.contains(_keys[i]),
                  onTap: () => setState(() {
                    _selected.contains(_keys[i])
                        ? _selected.remove(_keys[i])
                        : _selected.add(_keys[i]);
                  }),
                ),
            ],
          ),

          SizedBox(height: 20.h),

          _PresetTile(
            label: l10n.everyDay,
            selected: preset == _Preset.everyDay,
            onTap: () => _applyPreset(_Preset.everyDay),
          ),
          SizedBox(height: 8.h),
          _PresetTile(
            label: l10n.weekdays,
            selected: preset == _Preset.weekdays,
            onTap: () => _applyPreset(_Preset.weekdays),
          ),
          SizedBox(height: 8.h),
          _PresetTile(
            label: l10n.weekends,
            selected: preset == _Preset.weekends,
            onTap: () => _applyPreset(_Preset.weekends),
          ),
          SizedBox(height: 8.h),
          _PresetTile(
            label: l10n.custom,
            selected: preset == _Preset.custom,
            onTap: () => _applyPreset(_Preset.custom),
          ),
        ],
      ),
    );
  }
}

enum _Preset { everyDay, weekdays, weekends, custom }

class _PresetTile extends StatelessWidget {
  const _PresetTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppSelectableTile(
      selected: selected,
      onTap: onTap,
      child: Text(
        label,
        style: AppTextStyles.bodyMedium(
          color: selected ? AppColors.fern : AppColors.ink,
        ).copyWith(fontWeight: selected ? AppFont.semiBold : AppFont.medium),
      ),
    );
  }
}
