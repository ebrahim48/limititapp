import 'package:flutter/material.dart';
import 'package:limit_it_app/l10n/app_localizations.dart';

/// Extension to make accessing localization easier
extension LocalizationExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
