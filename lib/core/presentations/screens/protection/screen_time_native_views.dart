import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:limit_it_app/core/services/screen_time_service.dart';

/// Flutter windows onto the two things only iOS itself can draw.
///
/// Apple hands the app opaque tokens, never app names, icons or usage numbers.
/// SwiftUI can resolve a token into a label, and a DeviceActivityReport
/// extension can render usage — both inside views this process may display but
/// never read. So these rows are native views embedded in the Flutter tree
/// rather than data crossing the method channel.

/// Height of one native row, kept in step with `ScreenTimeMetrics.rowHeight`
/// in `ios/Runner/ScreenTimePlatformViews.swift`. Points, not `.h` — the
/// native side does not scale with ScreenUtil.
const double kScreenTimeRowHeight = 44;

/// The picked apps, with their real icons and names.
class ScreenTimeSelectionList extends StatelessWidget {
  const ScreenTimeSelectionList({
    super.key,
    required this.rowCount,
    this.draft = false,
    this.ruleId,
  });

  /// Applications + categories in the selection. Drives the reserved height,
  /// because a platform view has no intrinsic size to hand back to Flutter.
  final int rowCount;

  /// Show the wizard's pending pick instead of the Block-now selection.
  final bool draft;

  /// Show the apps of this saved protection instead.
  final String? ruleId;

  @override
  Widget build(BuildContext context) {
    if (!Platform.isIOS || rowCount <= 0) return const SizedBox.shrink();

    return SizedBox(
      height: rowCount * kScreenTimeRowHeight,
      child: UiKitView(
        viewType: 'com.limitit.digitalbalance/screen_time_selection',
        creationParams: <String, dynamic>{
          'draft': draft,
          if (ruleId != null) 'ruleId': ruleId,
        },
        creationParamsCodec: const StandardMessageCodec(),
      ),
    );
  }
}

/// Per-app screen time for the last [days] days, rendered by the report
/// extension. Shows nothing useful unless that extension ships with the build.
class ScreenTimeUsageReport extends StatelessWidget {
  const ScreenTimeUsageReport({
    super.key,
    this.days = 1,
    this.height = 320,
  });

  final int days;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (!Platform.isIOS) return const SizedBox.shrink();

    return SizedBox(
      height: height,
      child: UiKitView(
        viewType: 'com.limitit.digitalbalance/screen_time_usage',
        creationParams: <String, dynamic>{'days': days},
        creationParamsCodec: const StandardMessageCodec(),
        // The report scrolls internally; without this the Flutter scroll view
        // above it swallows every drag.
        gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
          Factory<OneSequenceGestureRecognizer>(
            () => EagerGestureRecognizer(),
          ),
        },
      ),
    );
  }
}

/// `true` for an iOS protection, whose "package name" is a Screen Time rule id
/// and whose stored name is only a count like "1 app · 0 categories".
bool isScreenTimeRule(String? packageName) =>
    Platform.isIOS &&
    packageName != null &&
    packageName.startsWith(ScreenTimeService.rulePrefix);

/// The real icon or name of an iOS protection's first app, drawn natively from
/// its token. Before Activate saves the rule, the wizard's pending pick is
/// shown instead.
class ScreenTimeAppLabel extends StatelessWidget {
  /// The app's real icon, filling a [size] square.
  const ScreenTimeAppLabel.icon({
    super.key,
    required this.ruleId,
    required double size,
  })  : _mode = 'icon',
        _size = size,
        style = null,
        centered = true;

  /// The app's real name ("Instagram", or "Instagram +2" for a bigger pick),
  /// one line in [style].
  const ScreenTimeAppLabel.title({
    super.key,
    required this.ruleId,
    required TextStyle this.style,
    this.centered = false,
  })  : _mode = 'title',
        _size = null;

  final String ruleId;
  final TextStyle? style;
  final bool centered;
  final String _mode;
  final double? _size;

  @override
  Widget build(BuildContext context) {
    if (!Platform.isIOS) return const SizedBox.shrink();

    final textStyle = style;
    final fontSize = textStyle?.fontSize ?? 15;
    final view = UiKitView(
      // Keyed by rule and look, so a recycled list row never shows the
      // previous protection's app.
      key: ValueKey('$ruleId/$_mode/$fontSize'),
      viewType: 'com.limitit.digitalbalance/screen_time_app_label',
      creationParams: <String, dynamic>{
        'ruleId': ruleId,
        'mode': _mode,
        'centered': centered,
        if (textStyle != null) ...{
          'fontSize': fontSize,
          'weight': (textStyle.fontWeight ?? FontWeight.w500).value,
          'color': (textStyle.color ?? const Color(0xFF1A1A1A)).toARGB32(),
        },
      },
      creationParamsCodec: const StandardMessageCodec(),
    );

    if (_mode == 'icon') {
      return SizedBox.square(dimension: _size, child: view);
    }
    // A platform view has no intrinsic size: reserve one line of the style.
    return SizedBox(
      width: double.infinity,
      height: fontSize * (textStyle?.height ?? 1.35),
      child: view,
    );
  }
}
