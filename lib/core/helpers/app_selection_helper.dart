import 'package:limit_it_app/core/models/app_model_pin.dart';

/// Helper class for managing app selection state
/// Used in PIN Lock, Detox Mode, and other app selection screens
class AppSelectionHelper {
  /// Toggle selection state of a single app
  ///
  /// [selectedApps] - Current set of selected app keys
  /// [appKey] - Unique key for the app (format: 'appName_index')
  ///
  /// Returns updated set with toggled selection state
  static Set<String> toggleApp(Set<String> selectedApps, String appKey) {
    final updated = Set<String>.from(selectedApps);
    if (updated.contains(appKey)) {
      updated.remove(appKey);
    } else {
      updated.add(appKey);
    }
    return updated;
  }

  /// Toggle selection state of all apps (Select All / Deselect All)
  ///
  /// [selectedApps] - Current set of selected app keys
  /// [apps] - List of all available apps
  ///
  /// Returns empty set if all apps are selected (deselect all),
  /// otherwise returns set with all app keys (select all)
  static Set<String> toggleSelectAll(Set<String> selectedApps, List<AppModel> apps) {
    final allKeys = {for (int i = 0; i < apps.length; i++) '${apps[i].name}_$i'};
    return selectedApps.length == apps.length ? <String>{} : allKeys;
  }

  /// Toggle selection state of all apps using custom key generator
  ///
  /// [selectedApps] - Current set of selected app keys
  /// [appCount] - Total number of apps
  /// [getKey] - Function to generate app key from index
  ///
  /// This is a more flexible version of [toggleSelectAll] that allows
  /// custom key generation logic
  ///
  /// Returns empty set if all apps are selected (deselect all),
  /// otherwise returns set with all app keys (select all)
  static Set<String> toggleSelectAllSet(
    Set<String> selectedApps,
    int appCount,
    String Function(int index) getKey,
  ) {
    final allKeys = <String>{};
    for (int i = 0; i < appCount; i++) {
      allKeys.add(getKey(i));
    }

    return selectedApps.length == appCount ? <String>{} : allKeys;
  }

  /// Check if all apps are selected
  ///
  /// [selectedApps] - Current set of selected app keys
  /// [appCount] - Total number of apps
  ///
  /// Returns true if all apps are selected, false otherwise
  static bool isAllSelected(Set<String> selectedApps, int appCount) {
    return selectedApps.length == appCount;
  }

  /// Get selected apps count
  ///
  /// [selectedApps] - Current set of selected app keys
  ///
  /// Returns number of selected apps
  static int getSelectedCount(Set<String> selectedApps) {
    return selectedApps.length;
  }

  /// Clear all selected apps
  ///
  /// [selectedApps] - Current set of selected app keys
  ///
  /// Returns empty set
  static Set<String> clearSelection(Set<String> selectedApps) {
    return {};
  }

  /// Select apps by pattern
  ///
  /// [selectedApps] - Current set of selected app keys
  /// [appKeys] - List of app keys to select
  ///
  /// Returns updated set with additional selected apps
  static Set<String> selectApps(Set<String> selectedApps, List<String> appKeys) {
    final updated = Set<String>.from(selectedApps);
    updated.addAll(appKeys);
    return updated;
  }

  /// Deselect apps by pattern
  ///
  /// [selectedApps] - Current set of selected app keys
  /// [appKeys] - List of app keys to deselect
  ///
  /// Returns updated set with removed selected apps
  static Set<String> deselectApps(Set<String> selectedApps, List<String> appKeys) {
    final updated = Set<String>.from(selectedApps);
    updated.removeAll(appKeys);
    return updated;
  }
}
