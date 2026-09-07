import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// One entry of the app catalogue iOS can be probed for.
///
/// [packageName] doubles as the stable id we store limits under and as the key
/// `BrandLogos` resolves the bundled logo from, so it stays the Android package
/// name on both platforms.
class KnownApp {
  const KnownApp({
    required this.name,
    required this.packageName,
    required this.iosSchemes,
    this.iosBundleId,
  });

  final String name;
  final String packageName;
  final List<String> iosSchemes;

  /// App Store bundle id, used to look the real icon up through the public
  /// iTunes API. A wrong or missing one is not fatal — [AppIconService] then
  /// searches the store by [name] instead.
  final String? iosBundleId;
}

/// Device app discovery for the platforms where `installed_apps` cannot help.
///
/// Android enumerates the launcher for real (see `AppUsageService`). iOS gives
/// no API to list installed apps at all — `canOpenURL` against a declared
/// scheme is the only detection Apple allows, so here we probe [catalog] and
/// keep the hits. Every scheme below must also sit in the
/// `LSApplicationQueriesSchemes` array of `ios/Runner/Info.plist`, otherwise
/// iOS answers `false` no matter what is installed.
class DeviceAppsService {
  static const MethodChannel _channel =
      MethodChannel('com.limitit.digitalbalance/device_apps');

  static const List<KnownApp> catalog = [
    KnownApp(
      name: 'Instagram',
      packageName: 'com.instagram.android',
      iosSchemes: ['instagram'],
      iosBundleId: 'com.burbn.instagram',
    ),
    KnownApp(
      name: 'TikTok',
      packageName: 'com.zhiliaoapp.musically',
      iosSchemes: ['tiktok', 'snssdk1128'],
      iosBundleId: 'com.zhiliaoapp.musically',
    ),
    KnownApp(
      name: 'YouTube',
      packageName: 'com.google.android.youtube',
      iosSchemes: ['youtube'],
      iosBundleId: 'com.google.ios.youtube',
    ),
    KnownApp(
      name: 'Facebook',
      packageName: 'com.facebook.katana',
      iosSchemes: ['fb'],
      iosBundleId: 'com.facebook.Facebook',
    ),
    KnownApp(
      name: 'Messenger',
      packageName: 'com.facebook.orca',
      iosSchemes: ['fb-messenger'],
      iosBundleId: 'com.facebook.Messenger',
    ),
    KnownApp(
      name: 'WhatsApp',
      packageName: 'com.whatsapp',
      iosSchemes: ['whatsapp'],
      iosBundleId: 'net.whatsapp.WhatsApp',
    ),
    KnownApp(
      name: 'X (Twitter)',
      packageName: 'com.twitter.android',
      iosSchemes: ['twitter'],
      iosBundleId: 'com.atebits.Tweetie2',
    ),
    KnownApp(
      name: 'Snapchat',
      packageName: 'com.snapchat.android',
      iosSchemes: ['snapchat'],
      iosBundleId: 'com.toyopagroup.picaboo',
    ),
    KnownApp(
      name: 'Threads',
      packageName: 'com.instagram.barcelona',
      iosSchemes: ['barcelona'],
      iosBundleId: 'com.burbn.barcelona',
    ),
    KnownApp(
      name: 'Reddit',
      packageName: 'com.reddit.frontpage',
      iosSchemes: ['reddit'],
      iosBundleId: 'com.reddit.Reddit',
    ),
    KnownApp(
      name: 'Pinterest',
      packageName: 'com.pinterest',
      iosSchemes: ['pinterest'],
      iosBundleId: 'pinterest',
    ),
    KnownApp(
      name: 'LinkedIn',
      packageName: 'com.linkedin.android',
      iosSchemes: ['linkedin'],
      iosBundleId: 'com.linkedin.LinkedIn',
    ),
    KnownApp(
      name: 'Telegram',
      packageName: 'org.telegram.messenger',
      iosSchemes: ['tg'],
      iosBundleId: 'ph.telegra.Telegraph',
    ),
    KnownApp(
      name: 'Discord',
      packageName: 'com.discord',
      iosSchemes: ['discord'],
      iosBundleId: 'com.hammerandchisel.discord',
    ),
    KnownApp(
      name: 'Signal',
      packageName: 'org.thoughtcrime.securesms',
      iosSchemes: ['sgnl'],
      iosBundleId: 'org.whispersystems.signal',
    ),
    KnownApp(
      name: 'Viber',
      packageName: 'com.viber.voip',
      iosSchemes: ['viber'],
      iosBundleId: 'com.viber',
    ),
    KnownApp(
      name: 'Netflix',
      packageName: 'com.netflix.mediaclient',
      iosSchemes: ['nflx'],
      iosBundleId: 'com.netflix.Netflix',
    ),
    KnownApp(
      name: 'Prime Video',
      packageName: 'com.amazon.avod.thirdpartyclient',
      iosSchemes: ['aiv'],
      iosBundleId: 'com.amazon.aiv.AIVApp',
    ),
    KnownApp(
      name: 'Disney+',
      packageName: 'com.disney.disneyplus',
      iosSchemes: ['disneyplus'],
      iosBundleId: 'com.disney.disneyplus',
    ),
    KnownApp(
      name: 'Twitch',
      packageName: 'tv.twitch.android.app',
      iosSchemes: ['twitch'],
      iosBundleId: 'tv.twitch',
    ),
    KnownApp(
      name: 'Spotify',
      packageName: 'com.spotify.music',
      iosSchemes: ['spotify'],
      iosBundleId: 'com.spotify.client',
    ),
    KnownApp(
      name: 'SoundCloud',
      packageName: 'com.soundcloud.android',
      iosSchemes: ['soundcloud'],
      iosBundleId: 'com.soundcloud.TouchApp',
    ),
    KnownApp(
      name: 'Shazam',
      packageName: 'com.shazam.android',
      iosSchemes: ['shazam'],
      iosBundleId: 'com.shazam.Shazam',
    ),
    KnownApp(
      name: 'BeReal',
      packageName: 'com.bereal.ft',
      iosSchemes: ['bereal'],
      iosBundleId: 'AlexisBarreyat.BeReal',
    ),
    KnownApp(
      name: 'Tinder',
      packageName: 'com.tinder',
      iosSchemes: ['tinder'],
      iosBundleId: 'com.cardify.tinder',
    ),
    KnownApp(
      name: 'Duolingo',
      packageName: 'com.duolingo',
      iosSchemes: ['duolingo'],
      iosBundleId: 'com.duolingo.DuolingoMobile',
    ),
    KnownApp(
      name: 'Gmail',
      packageName: 'com.google.android.gm',
      iosSchemes: ['googlegmail'],
      iosBundleId: 'com.google.Gmail',
    ),
    KnownApp(
      name: 'Google Maps',
      packageName: 'com.google.android.apps.maps',
      iosSchemes: ['comgooglemaps'],
      iosBundleId: 'com.google.Maps',
    ),
    KnownApp(
      name: 'Chrome',
      packageName: 'com.android.chrome',
      iosSchemes: ['googlechrome'],
      iosBundleId: 'com.google.chrome.ios',
    ),
    KnownApp(
      name: 'Slack',
      packageName: 'com.Slack',
      iosSchemes: ['slack'],
      iosBundleId: 'com.tinyspeck.chatlyio',
    ),
    KnownApp(
      name: 'Zoom',
      packageName: 'us.zoom.videomeetings',
      iosSchemes: ['zoomus'],
      iosBundleId: 'us.zoom.videomeetings',
    ),
    KnownApp(
      name: 'Uber',
      packageName: 'com.ubercab',
      iosSchemes: ['uber'],
      iosBundleId: 'com.ubercab.UberClient',
    ),
    KnownApp(
      name: 'Airbnb',
      packageName: 'com.airbnb.android',
      iosSchemes: ['airbnb'],
      iosBundleId: 'com.airbnb.app',
    ),
    KnownApp(
      name: 'Waze',
      packageName: 'com.waze',
      iosSchemes: ['waze'],
      iosBundleId: 'com.waze.iphone',
    ),
    KnownApp(
      name: 'Amazon',
      packageName: 'com.amazon.mShop.android.shopping',
      iosSchemes: ['com.amazon.mobile.shopping'],
      iosBundleId: 'com.amazon.Amazon',
    ),
    KnownApp(
      name: 'eBay',
      packageName: 'com.ebay.mobile',
      iosSchemes: ['ebay'],
      iosBundleId: 'com.ebay.iphone',
    ),
    KnownApp(
      name: 'PayPal',
      packageName: 'com.paypal.android.p2pmobile',
      iosSchemes: ['paypal'],
      iosBundleId: 'com.yourcompany.PPClient',
    ),
    KnownApp(
      name: 'Deliveroo',
      packageName: 'com.deliveroo.orderapp',
      iosSchemes: ['deliveroo'],
      iosBundleId: 'com.deliveroo.orderapp',
    ),
    KnownApp(
      name: 'Glovo',
      packageName: 'com.glovo',
      iosSchemes: ['glovo'],
      iosBundleId: 'com.glovo.Glovo',
    ),
  ];

  /// The catalogue apps this iPhone actually has installed.
  ///
  /// Returns an empty list on every other platform, and also when the channel
  /// is unavailable — callers fall back to the full catalogue there.
  Future<List<KnownApp>> detectInstalled() async {
    if (!Platform.isIOS) return const [];

    final schemes = <String>[
      for (final app in catalog) ...app.iosSchemes,
    ];

    try {
      final found = await _channel.invokeListMethod<String>(
        'detectInstalled',
        {'schemes': schemes},
      );
      if (found == null || found.isEmpty) return const [];

      final installed = found.toSet();
      return catalog
          .where((app) => app.iosSchemes.any(installed.contains))
          .toList();
    } on MissingPluginException {
      return const [];
    } on PlatformException catch (e) {
      debugPrint('Device app detection failed: ${e.message}');
      return const [];
    }
  }
}
