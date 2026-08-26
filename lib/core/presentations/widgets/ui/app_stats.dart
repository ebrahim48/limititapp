import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_spacing.dart';
import '../../../constants/app_text_styles.dart';

/// Hero KPI tile — big value, label, sub-label, on a tinted surface.
/// Each tile is direct-labeled, so the tint is decoration, not an encoding.
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.value,
    required this.label,
    this.sublabel,
    this.background,
    this.valueColor,
    this.onTap,
    this.padding,
  });

  final String value;
  final String label;
  final String? sublabel;
  final Color? background;
  final Color? valueColor;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  factory StatTile.green({
    required String value,
    required String label,
    String? sublabel,
    VoidCallback? onTap,
  }) =>
      StatTile(
        value: value,
        label: label,
        sublabel: sublabel,
        onTap: onTap,
        background: AppColors.mint,
        valueColor: AppColors.forestGreen,
      );

  factory StatTile.blue({
    required String value,
    required String label,
    String? sublabel,
    VoidCallback? onTap,
  }) =>
      StatTile(
        value: value,
        label: label,
        sublabel: sublabel,
        onTap: onTap,
        background: AppColors.infoBlueSoft,
        valueColor: AppColors.infoBlue,
      );

  factory StatTile.amber({
    required String value,
    required String label,
    String? sublabel,
    VoidCallback? onTap,
  }) =>
      StatTile(
        value: value,
        label: label,
        sublabel: sublabel,
        onTap: onTap,
        background: AppColors.warmSoft,
        valueColor: AppColors.warmText,
      );

  factory StatTile.red({
    required String value,
    required String label,
    String? sublabel,
    VoidCallback? onTap,
  }) =>
      StatTile(
        value: value,
        label: label,
        sublabel: sublabel,
        onTap: onTap,
        background: AppColors.alertRedSoft,
        valueColor: AppColors.alertRed,
      );

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background ?? AppColors.mint,
      borderRadius: AppRadius.cardRadius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: padding ?? EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.h2(
                  color: valueColor ?? AppColors.forestGreen,
                ),
              ),
              SizedBox(height: 6.h),
              Text(label, style: AppTextStyles.label(color: AppColors.ink)),
              if (sublabel != null) ...[
                SizedBox(height: 2.h),
                Text(
                  sublabel!,
                  style: AppTextStyles.caption(color: AppColors.mist),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Linear meter with a mint track and rounded data-end.
class AppProgressBar extends StatelessWidget {
  const AppProgressBar({
    super.key,
    required this.value,
    this.height,
    this.color,
    this.trackColor,
  });

  /// 0.0 – 1.0
  final double value;
  final double? height;
  final Color? color;
  final Color? trackColor;

  @override
  Widget build(BuildContext context) {
    final h = height ?? 8.h;
    return ClipRRect(
      borderRadius: BorderRadius.circular(h),
      child: LinearProgressIndicator(
        value: value.clamp(0.0, 1.0),
        minHeight: h,
        backgroundColor: trackColor ?? AppColors.mint,
        valueColor: AlwaysStoppedAnimation(color ?? AppColors.leafGreen),
      ),
    );
  }
}

/// Circular meter — "70%", "21h 45m time saved", the pause countdown ring.
class AppRingMeter extends StatelessWidget {
  const AppRingMeter({
    super.key,
    required this.value,
    required this.child,
    this.size,
    this.stroke,
    this.color,
    this.trackColor,
  });

  /// 0.0 – 1.0
  final double value;
  final Widget child;
  final double? size;
  final double? stroke;
  final Color? color;
  final Color? trackColor;

  @override
  Widget build(BuildContext context) {
    final s = size ?? 120.w;
    return SizedBox(
      width: s,
      height: s,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: value.clamp(0.0, 1.0),
              strokeWidth: stroke ?? 8.w,
              strokeCap: StrokeCap.round,
              backgroundColor: trackColor ?? AppColors.mint,
              valueColor: AlwaysStoppedAnimation(color ?? AppColors.leafGreen),
            ),
          ),
          Padding(
            padding: EdgeInsets.all((stroke ?? 8.w) + 8.w),
            child: child,
          ),
        ],
      ),
    );
  }
}

/// One row of the "Saved by app" / "Most used" lists: identity comes from the
/// app icon + name, so the single green bar only carries magnitude.
class AppUsageRow extends StatelessWidget {
  const AppUsageRow({
    super.key,
    required this.icon,
    required this.name,
    required this.value,
    required this.fraction,
    this.onTap,
  });

  final Widget icon;
  final String name;
  final String value;

  /// 0.0 – 1.0, relative to the largest row.
  final double fraction;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(width: 32.w, height: 32.w, child: icon),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.h4(),
                        ),
                      ),
                      Text(
                        value,
                        style: AppTextStyles.label(color: AppColors.ink)
                            .copyWith(fontWeight: AppFont.semiBold),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  AppProgressBar(value: fraction, height: 6.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Single-series column chart — "Weekly usage". One bar can be highlighted;
/// the rest use the same hue at a lighter step, so no legend is required.
class AppBarChart extends StatelessWidget {
  const AppBarChart({
    super.key,
    required this.values,
    required this.labels,
    this.highlightedIndex,
    this.height,
    this.onBarTap,
  });

  final List<double> values;
  final List<String> labels;
  final int? highlightedIndex;
  final double? height;
  final ValueChanged<int>? onBarTap;

  @override
  Widget build(BuildContext context) {
    final maxValue = values.isEmpty
        ? 1.0
        : values.reduce((a, b) => a > b ? a : b).clamp(0.0001, double.infinity);
    final chartHeight = height ?? 96.h;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: chartHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(values.length, (i) {
              final active = i == highlightedIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: onBarTap == null ? null : () => onBarTap!(i),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    // 2px surface gap between adjacent bars
                    padding: EdgeInsets.symmetric(horizontal: 3.w),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: (values[i] / maxValue) * chartHeight,
                        decoration: BoxDecoration(
                          color:
                              active ? AppColors.leafGreen : AppColors.mint,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(4.r),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: List.generate(
            labels.length,
            (i) => Expanded(
              child: Text(
                labels[i],
                textAlign: TextAlign.center,
                style: AppTextStyles.micro(
                  color: i == highlightedIndex
                      ? AppColors.forestGreen
                      : AppColors.mist,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Single-series line + soft area fill — "App reduction", "Screen time",
/// "Today you've avoided". Optional dots at each data point.
class AppLineChart extends StatelessWidget {
  const AppLineChart({
    super.key,
    required this.values,
    this.labels,
    this.height,
    this.showDots = true,
    this.color,
  });

  final List<double> values;
  final List<String>? labels;
  final double? height;
  final bool showDots;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: height ?? 90.h,
          child: CustomPaint(
            painter: _LinePainter(
              values: values,
              color: color ?? AppColors.leafGreen,
              showDots: showDots,
            ),
            size: Size.infinite,
          ),
        ),
        if (labels != null) ...[
          SizedBox(height: 8.h),
          Row(
            children: [
              for (var i = 0; i < labels!.length; i++)
                Expanded(
                  child: Text(
                    labels![i],
                    textAlign: i == 0
                        ? TextAlign.left
                        : (i == labels!.length - 1
                            ? TextAlign.right
                            : TextAlign.center),
                    style: AppTextStyles.micro(),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _LinePainter extends CustomPainter {
  _LinePainter({
    required this.values,
    required this.color,
    required this.showDots,
  });

  final List<double> values;
  final Color color;
  final bool showDots;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;

    final minV = values.reduce(math.min);
    final maxV = values.reduce(math.max);
    final span = (maxV - minV).abs() < 0.0001 ? 1.0 : (maxV - minV);

    // Keep the line inside the box so stroke and dots are never clipped.
    const inset = 8.0;
    final usableHeight = size.height - inset * 2;

    final points = <Offset>[
      for (var i = 0; i < values.length; i++)
        Offset(
          size.width * (i / (values.length - 1)),
          inset + usableHeight * (1 - (values[i] - minV) / span),
        ),
    ];

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      linePath.lineTo(p.dx, p.dy);
    }

    final areaPath = Path.from(linePath)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      areaPath,
      Paint()..color = color.withValues(alpha: 0.14),
    );

    canvas.drawPath(
      linePath,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    if (showDots) {
      for (final p in points) {
        // 2px surface ring keeps the marker readable over the fill.
        canvas.drawCircle(p, 4.5, Paint()..color = AppColors.white);
        canvas.drawCircle(
          p,
          4.5,
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LinePainter old) =>
      old.values != values || old.color != color || old.showDots != showDots;
}
