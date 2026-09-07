import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:limit_it_app/core/constants/app_colors.dart';
import 'package:limit_it_app/core/services/app_icon_service.dart';

/// Reusable widget that displays an app icon.
///
/// Shows [preloadedIcon] directly if provided, otherwise asks
/// [AppIconService] for the real one — the device's own icon on Android, the
/// App Store artwork on iOS. [appName] only helps the store lookup when the
/// package is not in the catalogue.
class AppIconWidget extends StatefulWidget {
  final String packageName;
  final String? appName;
  final Uint8List? preloadedIcon;
  final double size;
  final double borderRadius;
  final double padding;

  const AppIconWidget({
    super.key,
    required this.packageName,
    this.appName,
    this.preloadedIcon,
    this.size = 48,
    this.borderRadius = 12,
    this.padding = 4,
  });

  @override
  State<AppIconWidget> createState() => _AppIconWidgetState();
}

class _AppIconWidgetState extends State<AppIconWidget> {
  Future<ResolvedAppIcon?>? _iconFuture;

  @override
  void initState() {
    super.initState();
    if (widget.preloadedIcon == null && widget.packageName.isNotEmpty) {
      _iconFuture = AppIconService.instance
          .resolve(widget.packageName, appName: widget.appName);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.preloadedIcon != null) {
      return _wrap(_memImage(widget.preloadedIcon!));
    }

    if (_iconFuture != null) {
      return FutureBuilder<ResolvedAppIcon?>(
        future: _iconFuture,
        builder: (context, snapshot) {
          final icon = snapshot.data;
          final bytes = icon?.bytes;
          if (bytes != null && bytes.isNotEmpty) return _wrap(_memImage(bytes));

          final url = icon?.url;
          if (url != null) {
            return _wrap(CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              placeholder: (_, __) => const SizedBox.shrink(),
              errorWidget: (_, __, ___) => _defaultIconChild(),
            ));
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
