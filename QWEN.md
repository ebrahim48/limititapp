## Qwen Added Memories
- The limit_it_app is a Flutter application designed to help users manage and limit their app usage time. Key features include:

1. App usage tracking using Android's UsageStats API
2. App blocking functionality with real-time monitoring via AccessibilityService
3. Time-based limits for daily app usage and session duration
4. Multi-language support (English/Italian)
5. Dark/light theme support
6. Ad integration (banner and interstitial ads)
7. User authentication system
8. Onboarding flow with permissions setup
9. Home screen showing app usage statistics
10. Limits management screen for setting app restrictions
11. Reports screen for viewing usage analytics
12. Settings screen with various options

The app uses a hybrid approach combining Flutter for the UI layer with native Android code for app monitoring and blocking functionality. It requires special permissions (overlay and accessibility) to function properly. The architecture includes services for app usage tracking, app blocking, and data storage using SharedPreferences.
- The limit_it_app is a Flutter application designed to help users manage and limit their app usage time. Key features include: 1) App usage tracking using Android's UsageStats API, 2) App blocking functionality with real-time monitoring via AccessibilityService, 3) Time-based limits for daily app usage and session duration, 4) Multi-language support (English/Italian), 5) Dark/light theme support, 6) Ad integration (banner and interstitial ads), 7) User authentication system, 8) Onboarding flow with permissions setup, 9) Home screen showing app usage statistics, 10) Limits management screen for setting app restrictions, 11) Reports screen for viewing usage analytics, 12) Settings screen with various options. The app uses a hybrid approach combining Flutter for the UI layer with native Android code for app monitoring and blocking functionality. It requires special permissions (overlay and accessibility) to function properly. The architecture includes services for app usage tracking, app blocking, and data storage using SharedPreferences.
- LimitIt App - Complete Project Structure & Architecture:

**OVERVIEW**: Flutter app (v1.0.0+1, SDK ^3.7.0) for managing/limiting app usage time on Android. Uses hybrid approach: Flutter UI + native Android (Kotlin) for monitoring/blocking.

**CORE FEATURES**:
1. App usage tracking via Android UsageStats API
2. App blocking via AccessibilityService + ForegroundService
3. Time-based limits (daily opens, session duration)
4. Instant block feature (one-tap block/unblock)
5. Multi-language (English/Italian) - 145+ localized strings
6. Dark/light theme support
7. User authentication (email/password, OTP verification)
8. Onboarding flow with permissions setup
9. Ad integration (AdMob banner/interstitial)
10. Usage reports & analytics
11. Motivational phrases, detox mode, PIN lock
12. Real app icons display (top 10 most used apps)

**ARCHITECTURE**:
- **State Management**: GetX (controllers as singletons)
- **Routing**: go_router with custom slide transitions
- **Storage**: SharedPreferences (local data), API (auth)
- **Native Communication**: Method Channels (Flutter ↔ Kotlin)

**DIRECTORY STRUCTURE**:
```
lib/
├── controllers/ (auth, schedules_limits, upgrade_premium)
├── core/
│   ├── app_constants/
│   ├── config/ (app_routes, app_themes)
│   ├── constants/
│   ├── helpers/ (dependency_injection, localization, prefs, toast)
│   ├── models/ (app_limit, daily_usage, timer_settings, etc.)
│   ├── presentations/ (screens, widgets, controllers)
│   └── services/ (app_blocker, app_usage, blocked_apps, api_client)
├── global/ (custom_assets - generated)
├── l10n/ (app_en.arb, app_it.arb, generated localizations)
└── main.dart
```

**KEY SERVICES**:
- `AppBlockerService`: Method channel to native blocking
- `AppUsageService`: Fetches real app usage data (Android only)
- `BlockedAppsService`: SharedPreferences for instant block
- `AppLimitStorageService`: Stores app limits config
- `TimerSettingsService`: Pre-opening countdown settings
- `ThemeController`: Dark/light mode toggle
- `LocaleController`: Language switching (EN/IT)

**NATIVE ANDROID (Kotlin)**:
- `MainActivity.kt`: Method channel handler
- `AppMonitoringService.kt`: AccessibilityService for real-time app monitoring
- `AppMonitoringForegroundService.kt`: Background service for continuous monitoring
- `BlockingOverlayActivity.kt`: Full-screen blocking UI when limits exceeded

**PERMISSIONS REQUIRED**:
- SYSTEM_ALERT_WINDOW (overlay)
- BIND_ACCESSIBILITY_SERVICE (app monitoring)
- FOREGROUND_SERVICE + FOREGROUND_SERVICE_SPECIAL_USE
- POST_NOTIFICATIONS (Android 13+)
- PACKAGE_USAGE_STATS (usage tracking)
- QUERY_ALL_PACKAGES (app info)

**SCREENS (40+)**:
- Auth: Splash, Onboarding, Language, SignUp, SignIn, VerifyOTP, ForgotPassword, ResetPassword
- Home: HomeScreen, BottomNavBar, Profile (view/update)
- Limits: LimitsScreen, SetUsageLimit, TimerSettings, EditUsageLimit, EditTimerSettings, SchedulesLimits, PinLock, DetoxMode
- Reports: ReportsScreen
- Settings: SettingsScreen, MotivationPhrases, SaveMotivationPhrases, Subscription, UpgradePremium, ChangePassword, AboutUs, Terms, Privacy
- Permissions: PermissionsSetupScreen

**ROUTING**: 45+ named routes using go_router with slide transition animations

**DEPENDENCIES**:
- UI: flutter_screenutil, shimmer, lottie, smooth_page_indicator, pin_code_fields, flutter_rating_bar, flutter_staggered_animations, toastification, quickalert
- Navigation: go_router
- State: get (GetX)
- Storage: shared_preferences
- Native: usage_stats, permission_handler, installed_apps
- Media: video_player, image_picker, file_picker, share_plus, cached_network_image, flutter_svg
- Ads: google_mobile_ads
- Utils: mime, mime_type, flutter_spinkit, country_pickers, internet_connection_checker_plus, device_preview

**LOCALIZATION**:
- 145+ strings in English & Italian
- Files: app_en.arb, app_it.arb
- Usage: context.l10n.stringName
- Persistent language preference via SharedPreferences
- Default: Italian

**BLOCKING MECHANISM**:
1. User sets app limits (daily opens, session duration, active days)
2. Grants overlay + accessibility permissions
3. Foreground service starts monitoring
4. AccessibilityService detects app switches via TYPE_WINDOW_STATE_CHANGED
5. When limit exceeded → BlockingOverlayActivity shows → User returned to home
6. Daily reset at midnight
7. Instant block: One-tap block/unblock from home screen "Your Apps" section

**DATA FLOW**:
Flutter UI → Method Channel → Kotlin Services → SharedPreferences
Flutter UI → SharedPreferences (limits, blocked apps, settings)
Flutter UI → API Client → Backend (auth, user data)

**PLATFORM**: Android only (iOS falls back to dummy data for usage stats)

**BUILD**: Uses FVM (Flutter Version Management), flutter_gen for assets, device_preview for testing
- LimitIt App - Complete Project Structure & Architecture (Updated):

**OVERVIEW**: Flutter app (v1.0.0+1, SDK ^3.7.0) for managing/limiting app usage time on Android. Uses hybrid approach: Flutter UI + native Android (Kotlin) for monitoring/blocking.

**CORE FEATURES**:
1. App usage tracking via Android UsageStats API
2. App blocking via AccessibilityService + ForegroundService
3. Time-based limits (daily opens, session duration)
4. Instant block feature (one-tap block/unblock)
5. Multi-language (English/Italian) - 145+ localized strings
6. Dark/light theme support
7. User authentication (email/password, OTP verification)
8. Onboarding flow with permissions setup
9. Ad integration (AdMob banner/interstitial)
10. Usage reports & analytics
11. Motivational phrases, detox mode, PIN lock
12. Real app icons display (top 10 most used apps)

**ARCHITECTURE**:
- **State Management**: GetX (controllers as singletons)
- **Routing**: go_router with custom slide transitions (45+ routes)
- **Storage**: SharedPreferences (local data), API (auth)
- **Native Communication**: Method Channels (Flutter ↔ Kotlin)

**DIRECTORY STRUCTURE**:
```
lib/
├── controllers/ (auth_controller, schedules_limits_controller, upgrade_premium_controller)
├── core/
│   ├── app_constants/ (app_constants.dart)
│   ├── config/ (app_routes/app_routes.dart, app_themes/)
│   ├── constants/
│   ├── helpers/ (dependency_injection.dart, localization, prefs_helper.dart, toast_helper.dart)
│   ├── models/ (app_bock_item, app_limit_model, app_model_pin, appinfo_model, daily_usage, feature_premium_model, limit_option_model, timer_settings_model)
│   ├── presentations/ (controller/, screens/, widgets/)
│   └── services/ (api_client, api_constants, app_blocker_service, app_limit_storage_service, app_usage_service, blocked_apps_service, error_response, timer_settings_service)
├── global/ (custom_assets/ - generated by flutter_gen)
├── l10n/ (app_en.arb, app_it.arb, generated localizations)
└── main.dart
```

**KEY SERVICES**:
- `AppBlockerService`: Method channel to native Android blocking (overlay, accessibility permissions)
- `AppUsageService`: Fetches real app usage data via UsageStats API (Android only, iOS falls back to dummy data)
- `BlockedAppsService`: SharedPreferences for instant block (one-tap block/unblock)
- `AppLimitStorageService`: Stores app limits config (maxDailyOpens, maxSessionDurationMinutes, activeDays, schedule times)
- `TimerSettingsService`: Pre-opening countdown settings with motivational quotes
- `ThemeController`: Dark/light mode toggle
- `LocaleController`: Language switching (EN/IT, default Italian)
- `AuthController`: User authentication (signUp, login, verifyOTP, forgotPassword, resetPassword)
- `SchedulesLimitsController`: Manages blocked apps list with schedule times

**NATIVE ANDROID (Kotlin)** - `/android/app/src/main/kotlin/com/example/limit_it_app/`:
- `MainActivity.kt`: Method channel handler (app_blocker channel) - handles permissions, service lifecycle
- `AppMonitoringService.kt`: AccessibilityService for real-time app monitoring via TYPE_WINDOW_STATE_CHANGED events
- `AppMonitoringForegroundService.kt`: Background service for continuous monitoring with notification
- `BlockingOverlayActivity.kt`: Full-screen blocking UI when limits exceeded

**PERMISSIONS REQUIRED** (AndroidManifest.xml):
- SYSTEM_ALERT_WINDOW (overlay)
- BIND_ACCESSIBILITY_SERVICE (app monitoring)
- FOREGROUND_SERVICE + FOREGROUND_SERVICE_SPECIAL_USE
- POST_NOTIFICATIONS (Android 13+)
- PACKAGE_USAGE_STATS (usage tracking)
- QUERY_ALL_PACKAGES (app info)

**SCREENS (40+)** - `/lib/core/presentations/screens/`:
- Auth: Splash, Onboarding, Language, SignUp, SignIn, VerifyOTP, ForgotPassword, ResetPassword
- Home: HomeScreen (with real app usage data), BottomNavBar, Profile (view/update)
- Limits: LimitsScreen, SetUsageLimit, TimerSettings, EditUsageLimit, EditTimerSettings, SchedulesLimits, PinLock, DetoxMode
- Reports: ReportsScreen
- Settings: SettingsScreen, MotivationPhrases, SaveMotivationPhrases, Subscription, UpgradePremium, ChangePassword, AboutUs, Terms, Privacy
- Permissions: PermissionsSetupScreen

**ROUTING**: 45+ named routes using go_router with slide transition animations (custom _customTransitionPage)

**DEPENDENCIES**:
- UI: flutter_screenutil, shimmer, lottie, smooth_page_indicator, pin_code_fields, flutter_rating_bar, flutter_staggered_animations, toastification, quickalert
- Navigation: go_router
- State: get (GetX)
- Storage: shared_preferences
- Native: usage_stats, permission_handler, installed_apps
- Media: video_player, image_picker, file_picker, share_plus, cached_network_image, flutter_svg
- Ads: google_mobile_ads
- Utils: mime, mime_type, flutter_spinkit, country_pickers, internet_connection_checker_plus, device_preview

**LOCALIZATION**:
- 145+ strings in English & Italian
- Files: app_en.arb, app_it.arb
- Usage: context.l10n.stringName
- Persistent language preference via SharedPreferences
- Default: Italian

**BLOCKING MECHANISM**:
1. User sets app limits (daily opens, session duration, active days, schedule times)
2. Grants overlay + accessibility permissions
3. Foreground service starts monitoring
4. AccessibilityService detects app switches via TYPE_WINDOW_STATE_CHANGED
5. When limit exceeded → BlockingOverlayActivity shows → User returned to home
6. Daily reset at midnight (tracked via last_reset_date)
7. Instant block: One-tap block/unblock from home screen "Your Apps" section

**DATA FLOW**:
- Flutter UI → Method Channel → Kotlin Services → SharedPreferences
- Flutter UI → SharedPreferences (limits, blocked apps, settings)
- Flutter UI → API Client → Backend (auth, user data)

**PLATFORM**: Android only (iOS falls back to dummy data for usage stats)

**BUILD**: Uses FVM (Flutter Version Management), flutter_gen for assets, device_preview for testing

**KEY IMPLEMENTATION DETAILS**:
- AppUsageService.getAllInstalledApps() returns ALL installed apps sorted by usage time
- AppUsageService.getTodayAppUsage() returns top apps with usage data
- Blocking uses debouncing (2s cooldown) to prevent rapid block attempts
- SharedPreferences keys: 'app_limits', 'blocked_apps', 'timer_settings', 'app_usage_today_[packageName]'
- Auth flow: SignUp → VerifyOTP → Login → LimitPrivacyProtection → SelectApps → SetUsageLimit → TimerSettings
- Controllers registered as singletons via DependencyInjection.dependencies()
