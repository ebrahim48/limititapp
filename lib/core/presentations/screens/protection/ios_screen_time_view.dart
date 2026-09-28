import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../helpers/localization_helper.dart';
import '../../../helpers/toast_message_helper.dart';
import '../../../services/screen_time_service.dart';
import '../../widgets/ui/ui.dart';
import 'screen_time_native_views.dart';

/// The iOS half of "pick apps to protect".
///
/// Apple gives no way to list installed apps or read their usage, so this
/// screen cannot show the per-app rows Android does. Instead it drives Apple's
/// own Screen Time flow:
///   1. ask for Screen Time authorization,
///   2. open `FamilyActivityPicker`, where the user sees their real apps,
///   3. shield the picked tokens — that is what actually blocks them.
///
/// The selection comes back as opaque tokens, so Dart only ever learns how
/// many apps there are. The names, icons and per-app usage are drawn by iOS in
/// native views we embed but cannot read — see [ScreenTimeSelectionList] and
/// [ScreenTimeUsageReport].
class IosScreenTimeView extends StatefulWidget {
  const IosScreenTimeView({super.key});

  @override
  State<IosScreenTimeView> createState() => _IosScreenTimeViewState();
}

class _IosScreenTimeViewState extends State<IosScreenTimeView> {
  final ScreenTimeService _screenTime = ScreenTimeService.instance;

  ScreenTimeSelection _selection = ScreenTimeSelection.empty;
  bool _supported = true;
  bool _authorized = false;
  bool _loading = true;
  bool _busy = false;
  bool _hasUsageReport = false;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final supported = await _screenTime.isSupported();
    final authorized = supported && await _screenTime.isAuthorized();
    final selection =
        authorized ? await _screenTime.summary() : ScreenTimeSelection.empty;
    final hasUsageReport = supported && await _screenTime.hasUsageReport();

    if (!mounted) return;
    setState(() {
      _supported = supported;
      _authorized = authorized;
      _selection = selection;
      _hasUsageReport = hasUsageReport;
      _loading = false;
    });
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } on ScreenTimeException catch (e) {
      if (mounted) {
        ToastMessageHelper.showToastMessage(
          e.message,
          title: context.l10n.failed,
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _authorize() => _run(() async {
        await _screenTime.requestAuthorization();
        await _refresh();
      });

  Future<void> _pick() => _run(() async {
        if (!_authorized) await _screenTime.requestAuthorization();
        final picked = await _screenTime.pickApps();
        if (picked != null && mounted) {
          setState(() => _selection = picked);
        }
        await _refresh();
      });

  Future<void> _block() => _run(() async {
        final result = await _screenTime.applyShield();
        if (mounted) setState(() => _selection = result);
      });

  Future<void> _unblock() => _run(() async {
        final result = await _screenTime.clearShield();
        if (mounted) setState(() => _selection = result);
      });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_supported) {
      return Padding(
        padding: EdgeInsets.only(top: 40.h),
        child: AppMessageView(
          title: l10n.screenTimeUnavailableTitle,
          description: l10n.screenTimeUnavailableBody,
        ),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(bottom: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSoftCard(
            padding: EdgeInsets.all(14.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  size: 18.sp,
                  color: AppColors.fern,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    l10n.screenTimeExplainer,
                    style: AppTextStyles.small(color: AppColors.fern),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20.h),

          if (!_authorized) ...[
            Text(l10n.screenTimeNeedsAccess, style: AppTextStyles.h4()),
            SizedBox(height: 8.h),
            Text(
              l10n.screenTimeNeedsAccessBody,
              style: AppTextStyles.body(color: AppColors.slateGreen),
            ),
            SizedBox(height: 20.h),
            AppButton(
              label: l10n.screenTimeAllow,
              loading: _busy,
              onPressed: _authorize,
            ),
          ] else ...[
            SectionLabel(l10n.screenTimeSelected),
            SizedBox(height: 8.h),

            AppCard(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selection.isEmpty
                        ? l10n.screenTimeNothingPicked
                        : l10n.screenTimeCounts(
                            _selection.applications,
                            _selection.categories,
                          ),
                    style: AppTextStyles.h4(),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    // With nothing picked there is no Block button on screen
                    // yet, so pointing at one would be a dead end.
                    _selection.isEmpty
                        ? l10n.screenTimePickFirst
                        : (_selection.shielded
                            ? l10n.screenTimeBlockedNow
                            : l10n.screenTimeNotBlocked),
                    style: AppTextStyles.small(
                      color: _selection.shielded
                          ? AppColors.fern
                          : AppColors.slateGreen,
                    ),
                  ),
                ],
              ),
            ),

            // The picked apps themselves, icons and names included. Drawn by
            // iOS from the tokens — the rebuild key forces a fresh native view
            // whenever the selection changes, since it cannot be updated in
            // place.
            if (!_selection.isEmpty) ...[
              SizedBox(height: 12.h),
              AppCard(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: ScreenTimeSelectionList(
                  key: ValueKey(
                    '${_selection.applications}-${_selection.categories}',
                  ),
                  rowCount: _selection.applications + _selection.categories,
                ),
              ),
            ],

            SizedBox(height: 20.h),

            AppButton(
              label: _selection.isEmpty
                  ? l10n.screenTimeChooseApps
                  : l10n.screenTimeChangeApps,
              loading: _busy,
              onPressed: _pick,
            ),

            if (!_selection.isEmpty) ...[
              SizedBox(height: 12.h),
              AppButton(
                label: _selection.shielded
                    ? l10n.screenTimeUnblock
                    : l10n.screenTimeBlockNow,
                variant: _selection.shielded
                    ? AppButtonVariant.outline
                    : AppButtonVariant.brand,
                loading: _busy,
                onPressed: _selection.shielded ? _unblock : _block,
              ),
            ],

            SizedBox(height: 28.h),

            SectionLabel(l10n.screenTimeUsageTitle),
            SizedBox(height: 8.h),

            // Only the report extension can produce these numbers. Without it
            // the native view is an empty rectangle, so say so instead.
            if (_hasUsageReport)
              AppCard(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: const ScreenTimeUsageReport(),
              )
            else
              AppCard(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                child: Text(
                  l10n.screenTimeUsageMissing,
                  style: AppTextStyles.small(color: AppColors.slateGreen),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
