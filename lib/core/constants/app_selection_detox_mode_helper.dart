
import 'package:limit_it_app/core/models/app_model_pin.dart';

class AppSelectionDetoxModeHelper {
  static Set<String> toggleApp(Set<String> selectedApps, String appKey) {
    final updated = Set<String>.from(selectedApps);
    if (updated.contains(appKey)) {
      updated.remove(appKey);
    } else {
      updated.add(appKey);
    }
    return updated;
  }

  static Set<String> toggleSelectAll(Set<String> selectedApps, List<AppModel> apps) {
    final allKeys = {for (int i = 0; i < apps.length; i++) '${apps[i].name}_$i'};
    return selectedApps.length == apps.length ? <String>{} : allKeys;
  }

  static Set<String> toggleSelectAllSet(
    Set<String> selectedApps,
    int appCount,
    String Function(int index) getKey,
  ) {
    // Generate all keys
    final allKeys = <String>{};
    for (int i = 0; i < appCount; i++) {
      allKeys.add(getKey(i));
    }
    
    // If all are selected, return empty set (deselect all)
    // Otherwise, return all keys (select all)
    return selectedApps.length == appCount ? <String>{} : allKeys;
  }
}
