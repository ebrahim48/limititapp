import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:installed_apps/installed_apps.dart';
import '../../../../global/custom_assets/assets.gen.dart';
import '../../../constants/app_colors.dart';

/// Tinted design-system icon. All `assets/icons/ui/*.svg` are monochrome, so
/// they take whatever colour the caller asks for.
class AppIcon extends StatelessWidget {
  const AppIcon(this.asset, {super.key, this.size, this.color});

  final SvgGenImage asset;
  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final s = size ?? 22.w;
    return asset.svg(
      width: s,
      height: s,
      colorFilter: color == null
          ? null
          : ColorFilter.mode(color!, BlendMode.srcIn),
    );
  }
}

/// Brand logos that ship with the app, keyed by Android package name.
/// Used only as a fallback — the real installed-app icon always wins.
class BrandLogos {
  BrandLogos._();

  static final Map<String, SvgGenImage> _byPackage = {
    'com.instagram.android': Assets.icons.apps.instagram,
    'com.zhiliaoapp.musically': Assets.icons.apps.tiktok,
    'com.ss.android.ugc.trill': Assets.icons.apps.tiktok,
    'com.google.android.youtube': Assets.icons.apps.youtube,
    'com.whatsapp': Assets.icons.apps.whatsapp,
    'com.whatsapp.w4b': Assets.icons.apps.whatsapp,
    'com.twitter.android': Assets.icons.apps.x,
    'com.facebook.katana': Assets.icons.apps.facebook,
    'com.facebook.lite': Assets.icons.apps.facebook,
    'com.snapchat.android': Assets.icons.apps.snapchat,
  };

  static final Map<String, SvgGenImage> _byName = {
    'instagram': Assets.icons.apps.instagram,
    'tiktok': Assets.icons.apps.tiktok,
    'youtube': Assets.icons.apps.youtube,
    'whatsapp': Assets.icons.apps.whatsapp,
    'x': Assets.icons.apps.x,
    'x (twitter)': Assets.icons.apps.x,
    'twitter': Assets.icons.apps.x,
    'facebook': Assets.icons.apps.facebook,
    'snapchat': Assets.icons.apps.snapchat,
  };

  static SvgGenImage? resolve({String? packageName, String? appName}) {
    if (packageName != null && _byPackage.containsKey(packageName)) {
      return _byPackage[packageName];
    }
    if (appName != null) {
      return _byName[appName.trim().toLowerCase()];
    }
    return null;
  }
}

/// Square app-logo tile used in every app list.
///
/// Resolution order — the real icon installed on the device first (dynamic,
/// loaded through `installed_apps`), then the bundled brand logo, then a
/// neutral placeholder.
class AppLogoTile extends StatefulWidget {
  const AppLogoTile({
    super.key,
    this.packageName,
    this.appName,
    this.preloadedIcon,
    this.size,
    this.radius,
  });

  final String? packageName;
  final String? appName;
  final Uint8List? preloadedIcon;
  final double? size;
  final double? radius;

  @override
  State<AppLogoTile> createState() => _AppLogoTileState();
}

class _AppLogoTileState extends State<AppLogoTile> {
  Future<Uint8List?>? _iconFuture;

  @override
  void initState() {
    super.initState();
    final pkg = widget.packageName;
    if (widget.preloadedIcon == null && pkg != null && pkg.isNotEmpty) {
      _iconFuture = InstalledApps.getAppInfo(pkg)
          .then((info) => info?.icon)
          .catchError((_) => null);
    }
  }

  double get _size => widget.size ?? 40.w;
  double get _radius => widget.radius ?? 9.r;

  @override
  Widget build(BuildContext context) {
    if (widget.preloadedIcon != null) {
      return _frame(Image.memory(widget.preloadedIcon!, fit: BoxFit.cover));
    }

    if (_iconFuture != null) {
      return FutureBuilder<Uint8List?>(
        future: _iconFuture,
        builder: (context, snapshot) {
          final bytes = snapshot.data;
          if (bytes != null && bytes.isNotEmpty) {
            return _frame(Image.memory(bytes, fit: BoxFit.cover));
          }
          return _fallback();
        },
      );
    }

    return _fallback();
  }

  Widget _fallback() {
    final brand = BrandLogos.resolve(
      packageName: widget.packageName,
      appName: widget.appName,
    );

    if (brand != null) {
      return SizedBox(
        width: _size,
        height: _size,
        child: brand.svg(fit: BoxFit.contain),
      );
    }

    return Container(
      width: _size,
      height: _size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.mint,
        borderRadius: BorderRadius.circular(_radius),
      ),
      child: Text(
        (widget.appName?.trim().isNotEmpty ?? false)
            ? widget.appName!.trim()[0].toUpperCase()
            : '?',
        style: TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w700,
          fontSize: _size * 0.42,
          color: AppColors.fern,
        ),
      ),
    );
  }

  Widget _frame(Widget child) => ClipRRect(
        borderRadius: BorderRadius.circular(_radius),
        child: SizedBox(width: _size, height: _size, child: child),
      );
}
