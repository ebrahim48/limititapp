import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  const ScreenTimeSelectionList({super.key, required this.rowCount});

  /// Applications + categories in the selection. Drives the reserved height,
  /// because a platform view has no intrinsic size to hand back to Flutter.
  final int rowCount;

  @override
  Widget build(BuildContext context) {
    if (!Platform.isIOS || rowCount <= 0) return const SizedBox.shrink();

    return SizedBox(
      height: rowCount * kScreenTimeRowHeight,
      child: const UiKitView(
        viewType: 'com.limitit.digitalbalance/screen_time_selection',
        creationParams: <String, dynamic>{},
        creationParamsCodec: StandardMessageCodec(),
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
