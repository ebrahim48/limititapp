// dart format width=80

/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use,directives_ordering,implicit_dynamic_list_literal,unnecessary_import

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart' as _svg;
import 'package:lottie/lottie.dart' as _lottie;
import 'package:vector_graphics/vector_graphics.dart' as _vg;

class $AssetsIconsGen {
  const $AssetsIconsGen();

  /// File path: assets/icons/Home.svg
  SvgGenImage get home => const SvgGenImage('assets/icons/Home.svg');

  /// File path: assets/icons/detoxmode.svg
  SvgGenImage get detoxmode => const SvgGenImage('assets/icons/detoxmode.svg');

  /// File path: assets/icons/email.svg
  SvgGenImage get email => const SvgGenImage('assets/icons/email.svg');

  /// File path: assets/icons/facbook.svg
  SvgGenImage get facbook => const SvgGenImage('assets/icons/facbook.svg');

  /// File path: assets/icons/facebook.svg
  SvgGenImage get facebook => const SvgGenImage('assets/icons/facebook.svg');

  /// File path: assets/icons/instagram.svg
  SvgGenImage get instagram => const SvgGenImage('assets/icons/instagram.svg');

  /// File path: assets/icons/limit.svg
  SvgGenImage get limit => const SvgGenImage('assets/icons/limit.svg');

  /// File path: assets/icons/nameProfile.svg
  SvgGenImage get nameProfile =>
      const SvgGenImage('assets/icons/nameProfile.svg');

  /// File path: assets/icons/netflix.svg
  SvgGenImage get netflix => const SvgGenImage('assets/icons/netflix.svg');

  /// File path: assets/icons/notifications.svg
  SvgGenImage get notifications =>
      const SvgGenImage('assets/icons/notifications.svg');

  /// File path: assets/icons/pass.svg
  SvgGenImage get pass => const SvgGenImage('assets/icons/pass.svg');

  /// File path: assets/icons/pinlock.svg
  SvgGenImage get pinlock => const SvgGenImage('assets/icons/pinlock.svg');

  /// File path: assets/icons/reports.svg
  SvgGenImage get reports => const SvgGenImage('assets/icons/reports.svg');

  /// File path: assets/icons/schedules.svg
  SvgGenImage get schedules => const SvgGenImage('assets/icons/schedules.svg');

  /// File path: assets/icons/screentime.svg
  SvgGenImage get screentime =>
      const SvgGenImage('assets/icons/screentime.svg');

  /// File path: assets/icons/settings.svg
  SvgGenImage get settings => const SvgGenImage('assets/icons/settings.svg');

  /// File path: assets/icons/snapshot.svg
  SvgGenImage get snapshot => const SvgGenImage('assets/icons/snapshot.svg');

  /// File path: assets/icons/tiktalk.svg
  SvgGenImage get tiktalk => const SvgGenImage('assets/icons/tiktalk.svg');

  /// File path: assets/icons/twitter.svg
  SvgGenImage get twitter => const SvgGenImage('assets/icons/twitter.svg');

  /// File path: assets/icons/youtube.svg
  SvgGenImage get youtube => const SvgGenImage('assets/icons/youtube.svg');

  /// List of all assets
  List<SvgGenImage> get values => [
    home,
    detoxmode,
    email,
    facbook,
    facebook,
    instagram,
    limit,
    nameProfile,
    netflix,
    notifications,
    pass,
    pinlock,
    reports,
    schedules,
    screentime,
    settings,
    snapshot,
    tiktalk,
    twitter,
    youtube,
  ];
}

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// File path: assets/images/banner.png
  AssetGenImage get banner => const AssetGenImage('assets/images/banner.png');

  /// File path: assets/images/instagram.png
  AssetGenImage get instagram =>
      const AssetGenImage('assets/images/instagram.png');

  /// File path: assets/images/limit.png
  AssetGenImage get limit => const AssetGenImage('assets/images/limit.png');

  /// File path: assets/images/onboarding.png
  AssetGenImage get onboarding =>
      const AssetGenImage('assets/images/onboarding.png');

  /// File path: assets/images/privacy.png
  AssetGenImage get privacy => const AssetGenImage('assets/images/privacy.png');

  /// File path: assets/images/progress.png
  AssetGenImage get progress =>
      const AssetGenImage('assets/images/progress.png');

  /// File path: assets/images/resets.png
  AssetGenImage get resets => const AssetGenImage('assets/images/resets.png');

  /// File path: assets/images/screentime.png
  AssetGenImage get screentime =>
      const AssetGenImage('assets/images/screentime.png');

  /// File path: assets/images/splash.png
  AssetGenImage get splash => const AssetGenImage('assets/images/splash.png');

  /// File path: assets/images/success.png
  AssetGenImage get success => const AssetGenImage('assets/images/success.png');

  /// List of all assets
  List<AssetGenImage> get values => [
    banner,
    instagram,
    limit,
    onboarding,
    privacy,
    progress,
    resets,
    screentime,
    splash,
    success,
  ];
}

class $AssetsLottieGen {
  const $AssetsLottieGen();

  /// File path: assets/lottie/buttonLoading.json
  LottieGenImage get buttonLoading =>
      const LottieGenImage('assets/lottie/buttonLoading.json');

  /// File path: assets/lottie/no_data.json
  LottieGenImage get noData =>
      const LottieGenImage('assets/lottie/no_data.json');

  /// File path: assets/lottie/no_internet.json
  LottieGenImage get noInternet =>
      const LottieGenImage('assets/lottie/no_internet.json');

  /// File path: assets/lottie/paymentfail.json
  LottieGenImage get paymentfail =>
      const LottieGenImage('assets/lottie/paymentfail.json');

  /// File path: assets/lottie/paymentsuccess.json
  LottieGenImage get paymentsuccess =>
      const LottieGenImage('assets/lottie/paymentsuccess.json');

  /// List of all assets
  List<LottieGenImage> get values => [
    buttonLoading,
    noData,
    noInternet,
    paymentfail,
    paymentsuccess,
  ];
}

class Assets {
  const Assets._();

  static const $AssetsIconsGen icons = $AssetsIconsGen();
  static const $AssetsImagesGen images = $AssetsImagesGen();
  static const $AssetsLottieGen lottie = $AssetsLottieGen();
}

class AssetGenImage {
  const AssetGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
    this.animation,
  });

  final String _assetName;

  final Size? size;
  final Set<String> flavors;
  final AssetGenImageAnimation? animation;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.medium,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({AssetBundle? bundle, String? package}) {
    return AssetImage(_assetName, bundle: bundle, package: package);
  }

  String get path => _assetName;

  String get keyName => _assetName;
}

class AssetGenImageAnimation {
  const AssetGenImageAnimation({
    required this.isAnimation,
    required this.duration,
    required this.frames,
  });

  final bool isAnimation;
  final Duration duration;
  final int frames;
}

class SvgGenImage {
  const SvgGenImage(this._assetName, {this.size, this.flavors = const {}})
    : _isVecFormat = false;

  const SvgGenImage.vec(this._assetName, {this.size, this.flavors = const {}})
    : _isVecFormat = true;

  final String _assetName;
  final Size? size;
  final Set<String> flavors;
  final bool _isVecFormat;

  _svg.SvgPicture svg({
    Key? key,
    bool matchTextDirection = false,
    AssetBundle? bundle,
    String? package,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    AlignmentGeometry alignment = Alignment.center,
    bool allowDrawingOutsideViewBox = false,
    WidgetBuilder? placeholderBuilder,
    String? semanticsLabel,
    bool excludeFromSemantics = false,
    _svg.SvgTheme? theme,
    _svg.ColorMapper? colorMapper,
    ColorFilter? colorFilter,
    Clip clipBehavior = Clip.hardEdge,
    @deprecated Color? color,
    @deprecated BlendMode colorBlendMode = BlendMode.srcIn,
    @deprecated bool cacheColorFilter = false,
  }) {
    final _svg.BytesLoader loader;
    if (_isVecFormat) {
      loader = _vg.AssetBytesLoader(
        _assetName,
        assetBundle: bundle,
        packageName: package,
      );
    } else {
      loader = _svg.SvgAssetLoader(
        _assetName,
        assetBundle: bundle,
        packageName: package,
        theme: theme,
        colorMapper: colorMapper,
      );
    }
    return _svg.SvgPicture(
      loader,
      key: key,
      matchTextDirection: matchTextDirection,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      allowDrawingOutsideViewBox: allowDrawingOutsideViewBox,
      placeholderBuilder: placeholderBuilder,
      semanticsLabel: semanticsLabel,
      excludeFromSemantics: excludeFromSemantics,
      colorFilter:
          colorFilter ??
          (color == null ? null : ColorFilter.mode(color, colorBlendMode)),
      clipBehavior: clipBehavior,
      cacheColorFilter: cacheColorFilter,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}

class LottieGenImage {
  const LottieGenImage(this._assetName, {this.flavors = const {}});

  final String _assetName;
  final Set<String> flavors;

  _lottie.LottieBuilder lottie({
    Animation<double>? controller,
    bool? animate,
    _lottie.FrameRate? frameRate,
    bool? repeat,
    bool? reverse,
    _lottie.LottieDelegates? delegates,
    _lottie.LottieOptions? options,
    void Function(_lottie.LottieComposition)? onLoaded,
    _lottie.LottieImageProviderFactory? imageProviderFactory,
    Key? key,
    AssetBundle? bundle,
    Widget Function(BuildContext, Widget, _lottie.LottieComposition?)?
    frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    double? width,
    double? height,
    BoxFit? fit,
    AlignmentGeometry? alignment,
    String? package,
    bool? addRepaintBoundary,
    FilterQuality? filterQuality,
    void Function(String)? onWarning,
    _lottie.LottieDecoder? decoder,
    _lottie.RenderCache? renderCache,
    bool? backgroundLoading,
  }) {
    return _lottie.Lottie.asset(
      _assetName,
      controller: controller,
      animate: animate,
      frameRate: frameRate,
      repeat: repeat,
      reverse: reverse,
      delegates: delegates,
      options: options,
      onLoaded: onLoaded,
      imageProviderFactory: imageProviderFactory,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      package: package,
      addRepaintBoundary: addRepaintBoundary,
      filterQuality: filterQuality,
      onWarning: onWarning,
      decoder: decoder,
      renderCache: renderCache,
      backgroundLoading: backgroundLoading,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}
