import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:limit_it_app/controllers/auth_controller.dart';
import 'package:limit_it_app/controllers/notifications_controller.dart';
import 'package:limit_it_app/controllers/pin_lock_controller.dart';
import 'package:limit_it_app/controllers/profile_controller.dart';
import 'package:limit_it_app/controllers/schedules_limits_controller.dart';
import 'package:limit_it_app/controllers/premium_controller.dart';
import 'package:limit_it_app/controllers/reminders_controller.dart';
import 'package:limit_it_app/controllers/stats_controller.dart';
import 'package:limit_it_app/controllers/upgrade_premium_controller.dart';
import 'package:limit_it_app/core/presentations/controller/theme_controller.dart';
import 'package:limit_it_app/core/presentations/controller/locale_controller.dart';
import 'package:limit_it_app/core/services/app_blocker_service.dart';
import 'package:limit_it_app/core/services/app_limit_storage_service.dart';
import 'package:limit_it_app/core/services/app_usage_service.dart';
import 'package:limit_it_app/core/services/blocked_apps_service.dart';
import 'package:limit_it_app/core/services/pin_lock_storage_service.dart';
import 'package:limit_it_app/core/services/timer_settings_service.dart';

class DependencyInjection implements Bindings {
  DependencyInjection();

  @override
  void dependencies() {
    // Register all services as singletons (lazy load)
    Get.lazyPut<AppUsageService>(() => AppUsageService.instance, fenix: true);
    Get.lazyPut<AppBlockerService>(() => AppBlockerService.instance, fenix: true);
    Get.lazyPut<BlockedAppsService>(() => BlockedAppsService.instance, fenix: true);
    Get.lazyPut<AppLimitStorageService>(() => AppLimitStorageService.instance, fenix: true);
    Get.lazyPut<TimerSettingsService>(() => TimerSettingsService.instance, fenix: true);
    Get.lazyPut<PinLockStorageService>(() => PinLockStorageService.instance, fenix: true);

    Get.lazyPut<ThemeController>(() => ThemeController(), fenix: true);
    Get.lazyPut<LocaleController>(() => LocaleController(), fenix: true);
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
    Get.lazyPut<NotificationsController>(() => NotificationsController(), fenix: true);
    Get.lazyPut<PinLockController>(() => PinLockController(), fenix: true);
    Get.lazyPut<ProfileController>(() => ProfileController(), fenix: true);
    Get.lazyPut<SchedulesLimitsController>(() => SchedulesLimitsController(), fenix: true);
    Get.lazyPut<UpgradePremiumController>(() => UpgradePremiumController(), fenix: true);
    Get.put<PremiumController>(PremiumController(), permanent: true);
    Get.lazyPut<StatsController>(() => StatsController(), fenix: true);
    Get.lazyPut<RemindersController>(() => RemindersController(), fenix: true);
  }

  void lockDevicePortrait() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
}
