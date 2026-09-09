import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:limit_it_app/core/presentations/controller/locale_controller.dart';
import 'package:limit_it_app/l10n/app_localizations.dart';

/// Extension to make accessing localization easier
extension LocalizationExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

/// Localizations for places without a [BuildContext] (controllers, services).
/// Resolves against the locale currently selected in [LocaleController].
AppLocalizations get appL10n {
  final locale = Get.isRegistered<LocaleController>()
      ? Get.find<LocaleController>().locale.value
      : const Locale('it', '');
  return lookupAppLocalizations(Locale(locale.languageCode));
}
