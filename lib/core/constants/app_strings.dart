import 'package:flutter/material.dart';
import 'package:limit_it_app/l10n/app_localizations.dart';

/// Helper class to access localized strings
///
/// Usage in widgets:
/// - With context: AppString.of(context).welcomeLimitIt
/// - Or use the extension: context.l10n.welcomeLimitIt
class AppString {
  /// Get AppLocalizations from context
  static AppLocalizations of(BuildContext context) {
    return AppLocalizations.of(context)!;
  }

  // Legacy constants kept for backward compatibility (not localized)
  static const String limitIt = 'LimitIt';
  static const String limit = 'limitIt';
}
