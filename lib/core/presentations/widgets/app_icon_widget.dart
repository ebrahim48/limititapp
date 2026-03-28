import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:limit_it_app/core/constants/app_colors.dart';

/// Reusable widget that displays an app icon.
/// Shows [preloadedIcon] directly if provided, otherwise lazy-loads
/// the icon by [packageName] from the device.
class AppIconWidget extends StatefulWidget {
  final String packageName;
  final Uint8List? preloadedIcon;
  final double size;
  final double borderRadius;
  final double padding;

  const AppIconWidget({
    super.key,
    required this.packageName,
    this.preloadedIcon,
    this.size = 48,
    this.borderRadius = 12,
    this.padding = 4,
  });

  @override
  State<AppIconWidget> createState() => _AppIconWidgetState();
}

class _AppIconWidgetState extends State<AppIconWidget> {
  Future<Uint8List?>? _iconFuture;

  @override
  void initState() {
    super.initState();
    if (widget.preloadedIcon == null && widget.packageName.isNotEmpty) {
      _iconFuture = InstalledApps.getAppInfo(widget.packageName)
          .then((info) => info?.icon)
          .catchError((_) => null);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.preloadedIcon != null) {
      return _wrap(_memImage(widget.preloadedIcon!));
    }

    if (_iconFuture != null) {
      return FutureBuilder<Uint8List?>(
        future: _iconFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return _wrap(_memImage(snapshot.data!));
          }
          return _defaultIcon();
        },
      );
    }

    return _defaultIcon();
  }

  Widget _wrap(Widget child) => Container(
        width: widget.size.w,
        height: widget.size.h,
        padding: EdgeInsets.all(widget.padding.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius.r),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular((widget.borderRadius - 2).r),
          child: child,
        ),
      );

  Widget _memImage(Uint8List bytes) => Image.memory(
        bytes,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _defaultIconChild(),
      );

  Widget _defaultIcon() => Container(
        width: widget.size.w,
        height: widget.size.h,
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(widget.borderRadius.r),
          border: Border.all(color: Colors.grey.shade300),
        ),
        alignment: Alignment.center,
        child: _defaultIconChild(),
      );

  Widget _defaultIconChild() => Icon(
        Icons.apps_rounded,
        color: AppColors.primaryColor,
        size: (widget.size * 0.5).r,
      );
}
