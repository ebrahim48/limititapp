import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:limit_it_app/core/helpers/localization_helper.dart';
import '../../widgets/ui/ui.dart';

/// The mindful pause the user sees before a protected app opens.
/// Counts down, then unlocks the "Open now" button.
class PreviewPauseScreen extends StatefulWidget {
  const PreviewPauseScreen({
    super.key,
    this.packageName,
    this.appName,
    this.message,
    this.seconds = 10,
  });

  final String? packageName;
  final String? appName;
  final String? message;
  final int seconds;

  @override
  State<PreviewPauseScreen> createState() => _PreviewPauseScreenState();
}

class _PreviewPauseScreenState extends State<PreviewPauseScreen> {
  late int _remaining = widget.seconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remaining <= 1) {
        timer.cancel();
        if (mounted) setState(() => _remaining = 0);
      } else if (mounted) {
        setState(() => _remaining -= 1);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  bool get _unlocked => _remaining == 0;

  String get _clock {
    final m = (_remaining ~/ 60).toString().padLeft(2, '0');
    final s = (_remaining % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final appName = widget.appName?.trim().isNotEmpty ?? false
        ? widget.appName!
        : l10n.app;
    final message = widget.message?.trim();

    return AppScaffold(
      appBar: const AppTopBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.pauseActive,
            textAlign: TextAlign.center,
            style: AppTextStyles.h3(),
          ),
          SizedBox(height: 24.h),

          Center(
            child: AppLogoTile(
              packageName: widget.packageName,
              appName: widget.appName,
              size: 56.w,
            ),
          ),
          SizedBox(height: 20.h),

          Text(
            l10n.appIsCurrentlyPaused(appName),
            textAlign: TextAlign.center,
            style: AppTextStyles.body(color: AppColors.slateGreen),
          ),

          if (message != null && message.isNotEmpty) ...[
            SizedBox(height: 10.h),
            Text(
              '“$message”',
              textAlign: TextAlign.center,
              style: AppTextStyles.body(color: AppColors.fern)
                  .copyWith(fontStyle: FontStyle.italic),
            ),
          ],

          SizedBox(height: 32.h),

          Center(
            child: AppRingMeter(
              value: widget.seconds == 0
                  ? 1
                  : (widget.seconds - _remaining) / widget.seconds,
              size: 132.w,
              stroke: 6.w,
              child: FittedBox(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l10n.remainingTime, style: AppTextStyles.caption()),
                    SizedBox(height: 2.h),
                    Text(
                      _clock,
                      style: AppTextStyles.h2(color: AppColors.forestGreen),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: 36.h),

          AppButton(
            label: l10n.openNow,
            enabled: _unlocked,
            onPressed: () => context.pop(),
          ),
        ],
      ),
    );
  }
}
