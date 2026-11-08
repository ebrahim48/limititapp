import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:limit_it_app/controllers/premium_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Single owner of every AdMob placement in the app.
///
/// - Free users: small banners plus an occasional, frequency-capped
///   interstitial.
/// - Premium users: nothing is loaded or shown.
///
/// The native Android blocking screen (`BlockingOverlayActivity.kt`) has its
/// own banner and reads the same `premium_is_active` flag.
class AdService {
  AdService._();

  static final AdService instance = AdService._();

  // ── AdMob unit ids ────────────────────────────────────────────────────────
  // Debug/profile builds always use Google's public test units, so tapping
  // ads during development can never get the AdMob account suspended.
  // Release builds use the real LimitIt units below. A placement without a
  // real unit yet (null) simply shows nothing in release.
  //
  // The AdMob *app* ids live in AndroidManifest.xml / ios/Runner/Info.plist.

  /// Real Android banner unit: "android-adq-banner".
  static const String _androidBannerUnitId =
      'ca-app-pub-3550612244479973/2302483176';

  /// Real Android interstitial unit.
  static const String _androidInterstitialUnitId =
      'ca-app-pub-3550612244479973/8531840441';

  /// iOS has no AdMob units yet — iOS release builds stay ad-free.
  static const String? _iosBannerUnitId = null;
  static const String? _iosInterstitialUnitId = null;

  static const String _testBannerAndroid =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _testBannerIos = 'ca-app-pub-3940256099942544/2934735716';
  static const String _testInterstitialAndroid =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _testInterstitialIos =
      'ca-app-pub-3940256099942544/4411468910';

  static bool get _useTestAds => !kReleaseMode;

  static String? get bannerUnitId {
    if (_useTestAds) {
      return Platform.isIOS ? _testBannerIos : _testBannerAndroid;
    }
    return Platform.isIOS ? _iosBannerUnitId : _androidBannerUnitId;
  }

  static String? get interstitialUnitId {
    if (_useTestAds) {
      return Platform.isIOS ? _testInterstitialIos : _testInterstitialAndroid;
    }
    return Platform.isIOS ? _iosInterstitialUnitId : _androidInterstitialUnitId;
  }

  /// Interstitial frequency cap: at most one every [_minInterval], and no more
  /// than [_maxPerDay] a day.
  static const Duration _minInterval = Duration(minutes: 5);
  static const int _maxPerDay = 3;

  static const String _keyLastShownAt = 'ads_interstitial_last_shown_at';
  static const String _keyShownDate = 'ads_interstitial_shown_date';
  static const String _keyShownCount = 'ads_interstitial_shown_count';

  InterstitialAd? _interstitial;
  bool _initialized = false;

  bool get adsEnabled => !Get.find<PremiumController>().isPremium.value;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    await MobileAds.instance.initialize();
    _preloadInterstitial();
  }

  void _preloadInterstitial() {
    final unitId = interstitialUnitId;
    if (!adsEnabled || unitId == null || _interstitial != null) return;
    InterstitialAd.load(
      adUnitId: unitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitial = ad,
        onAdFailedToLoad: (error) {
          debugPrint('Interstitial failed to load: $error');
          _interstitial = null;
        },
      ),
    );
  }

  /// Shows an interstitial when the cap allows it and completes once the ad
  /// is closed (or right away when nothing is shown), so callers can simply
  /// `await` it before navigating.
  Future<void> maybeShowInterstitial() async {
    if (!adsEnabled) return;

    final ad = _interstitial;
    if (ad == null) {
      _preloadInterstitial();
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final today = '${now.year}-${now.month}-${now.day}';

    final lastShown = prefs.getInt(_keyLastShownAt) ?? 0;
    if (now.millisecondsSinceEpoch - lastShown < _minInterval.inMilliseconds) {
      return;
    }

    final shownToday = prefs.getString(_keyShownDate) == today
        ? prefs.getInt(_keyShownCount) ?? 0
        : 0;
    if (shownToday >= _maxPerDay) return;

    _interstitial = null;
    await prefs.setInt(_keyLastShownAt, now.millisecondsSinceEpoch);
    await prefs.setString(_keyShownDate, today);
    await prefs.setInt(_keyShownCount, shownToday + 1);

    final closed = Completer<void>();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _preloadInterstitial();
        if (!closed.isCompleted) closed.complete();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _preloadInterstitial();
        if (!closed.isCompleted) closed.complete();
      },
    );
    await ad.show();
    return closed.future;
  }
}

/// Small banner for Free users. Renders nothing for Premium users or while
/// no ad is available, so it never leaves an empty gap.
class AppBannerAd extends StatefulWidget {
  const AppBannerAd({super.key, this.padding = EdgeInsets.zero});

  final EdgeInsets padding;

  @override
  State<AppBannerAd> createState() => _AppBannerAdState();
}

class _AppBannerAdState extends State<AppBannerAd> {
  final PremiumController _premium = Get.find<PremiumController>();
  BannerAd? _banner;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    final unitId = AdService.bannerUnitId;
    if (AdService.instance.adsEnabled && unitId != null) _load(unitId);
  }

  void _load(String unitId) {
    _banner = BannerAd(
      adUnitId: unitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _banner = null;
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _banner?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final banner = _banner;
      if (_premium.isPremium.value || !_loaded || banner == null) {
        return const SizedBox.shrink();
      }
      return Padding(
        padding: widget.padding,
        child: Center(
          child: SizedBox(
            width: banner.size.width.toDouble(),
            height: banner.size.height.toDouble(),
            child: AdWidget(ad: banner),
          ),
        ),
      );
    });
  }
}
