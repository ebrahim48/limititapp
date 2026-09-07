import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:limit_it_app/core/helpers/prefs_helper.dart';
import 'package:limit_it_app/core/services/device_apps_service.dart';

/// An icon that was actually found for an app: either the bytes the device
/// handed over, or a URL to fetch it from.
class ResolvedAppIcon {
  const ResolvedAppIcon.bytes(Uint8List this.bytes) : url = null;
  const ResolvedAppIcon.url(String this.url) : bytes = null;

  final Uint8List? bytes;
  final String? url;
}

/// Resolves every app icon in the app, always off real data.
///
/// Android hands over the installed app's own icon. iOS exposes no icon for
/// another app at all, so we ask the public iTunes lookup for the App Store
/// artwork; the resolved URL is remembered in prefs and the image itself is
/// disk-cached by `CachedNetworkImage`, so each app costs one request ever.
class AppIconService {
  AppIconService._();

  static final AppIconService instance = AppIconService._();

  static const String _prefsPrefix = 'app_artwork_url_';
  static const Duration _timeout = Duration(seconds: 8);

  /// Session memo, so a list that shows the same app twice asks once.
  final Map<String, Future<ResolvedAppIcon?>> _resolved = {};

  /// Store lookups run one at a time. A list of 40 apps opening at once would
  /// otherwise fire 40 simultaneous requests and get rate-limited; queued, the
  /// rows just fill in as each answer lands, and only ever on first run.
  Future<void> _lookupQueue = Future<void>.value();

  Future<ResolvedAppIcon?> resolve(String packageName, {String? appName}) {
    final key = packageName.trim();
    if (key.isEmpty) return Future.value(null);
    return _resolved[key] ??= _resolve(key, appName);
  }

  Future<ResolvedAppIcon?> _resolve(String packageName, String? appName) async {
    final bytes = await _deviceIcon(packageName);
    if (bytes != null && bytes.isNotEmpty) return ResolvedAppIcon.bytes(bytes);

    final url = await _artworkUrl(packageName, appName);
    return url != null ? ResolvedAppIcon.url(url) : null;
  }

  /// The icon as installed on this device — Android only, `installed_apps`
  /// has nothing to answer with elsewhere.
  Future<Uint8List?> _deviceIcon(String packageName) async {
    if (!Platform.isAndroid) return null;
    try {
      final info = await InstalledApps.getAppInfo(packageName);
      return info?.icon;
    } catch (_) {
      return null;
    }
  }

  /// App Store artwork for [packageName]. Looked up by bundle id when the
  /// catalogue knows one, by name otherwise — so a bundle id that is wrong or
  /// missing still resolves. Only hits are cached: a lookup that failed
  /// because the device was offline must be free to succeed later.
  Future<String?> _artworkUrl(String packageName, String? appName) async {
    final prefsKey = '$_prefsPrefix$packageName';
    final cached = await PrefsHelper.getStringNullable(prefsKey);
    if (cached != null && cached.isNotEmpty) return cached;

    final known = _catalogEntry(packageName);
    final bundleId = known?.iosBundleId;
    final term = appName?.trim().isNotEmpty == true ? appName!.trim() : known?.name;

    String? url;
    if (bundleId != null) {
      url = await _queued(() => _artworkFrom(
            'https://itunes.apple.com/lookup'
            '?bundleId=${Uri.encodeQueryComponent(bundleId)}',
          ));
    }
    if (url == null && term != null && term.isNotEmpty) {
      url = await _queued(() => _artworkFrom(
            'https://itunes.apple.com/search'
            '?term=${Uri.encodeQueryComponent(term)}&entity=software&limit=1',
          ));
    }

    if (url != null) await PrefsHelper.setString(prefsKey, url);
    return url;
  }

  /// Runs [task] after every lookup already queued.
  Future<T> _queued<T>(Future<T> Function() task) {
    final completer = Completer<T>();
    _lookupQueue = _lookupQueue.then((_) async {
      try {
        completer.complete(await task());
      } catch (e, stack) {
        completer.completeError(e, stack);
      }
    });
    return completer.future;
  }

  KnownApp? _catalogEntry(String packageName) {
    for (final app in DeviceAppsService.catalog) {
      if (app.packageName == packageName) return app;
    }
    return null;
  }

  Future<String?> _artworkFrom(String endpoint) async {
    final client = HttpClient()..connectionTimeout = _timeout;
    try {
      final request = await client.getUrl(Uri.parse(endpoint));
      final response = await request.close().timeout(_timeout);
      if (response.statusCode != 200) return null;

      final body = await response.transform(utf8.decoder).join().timeout(_timeout);
      final results = (jsonDecode(body) as Map<String, dynamic>)['results'];
      if (results is! List || results.isEmpty) return null;

      final first = results.first as Map<String, dynamic>;
      final artwork = first['artworkUrl512'] ??
          first['artworkUrl100'] ??
          first['artworkUrl60'];
      return artwork is String && artwork.isNotEmpty ? artwork : null;
    } catch (e) {
      debugPrint('App artwork lookup failed for $endpoint: $e');
      return null;
    } finally {
      client.close(force: true);
    }
  }
}
