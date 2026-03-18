# App Blocking Implementation Guide

## Overview
This document describes the complete app blocking mechanism implemented in LimitIt. The system uses a hybrid approach combining **AccessibilityService** and **UsageStatsManager** to monitor app usage in real-time and enforce limits.

## Architecture

### Components

#### 1. **Android Native Layer (Kotlin)**

**AppMonitoringService.kt** - AccessibilityService
- Monitors app switches in real-time
- Tracks app open counts and session durations
- Enforces app limits based on configured rules
- Shows blocking overlay when limits are exceeded

**BlockingOverlayActivity.kt** - Full-screen blocking UI
- Displays when an app limit is reached
- Prevents user from returning to blocked app
- Shows informative message about why app is blocked

**AppMonitoringForegroundService.kt** - Background service
- Keeps monitoring active even when app is closed
- Displays persistent notification
- Ensures continuous enforcement of limits

**MainActivity.kt** - Method Channel handler
- Bridges Flutter and native Android code
- Handles permission requests
- Manages service lifecycle

#### 2. **Flutter Layer**

**AppBlockerService** (`lib/core/services/app_blocker_service.dart`)
- Dart interface to native functionality
- Manages permission checks and requests
- Controls monitoring service lifecycle

**AppLimitStorageService** (`lib/core/services/app_limit_storage_service.dart`)
- Stores app limits in SharedPreferences
- Manages daily usage counters
- Handles data persistence

**PermissionsSetupScreen** (`lib/core/presentations/screens/permissions/permissions_setup_screen.dart`)
- Guides user through permission setup
- Checks permission status
- Starts monitoring service

## Data Flow

```
1. User selects apps and sets limits
   ↓
2. Data saved to SharedPreferences
   ↓
3. User grants permissions (Overlay + Accessibility)
   ↓
4. Foreground service starts
   ↓
5. AccessibilityService monitors app switches
   ↓
6. When limit exceeded:
   - BlockingOverlayActivity shows
   - User returned to home screen
```

## How It Works

### 1. App Limit Configuration
```dart
AppLimitModel(
  packageName: 'com.facebook.katana',
  appName: 'Facebook',
  maxDailyOpens: 5,              // Max opens per day
  maxSessionDurationMinutes: 30,  // Max continuous use time
  activeDays: ['MON', 'TUE', 'WED'], // Days when limit is active
)
```

### 2. Real-time Monitoring
The AccessibilityService listens for `TYPE_WINDOW_STATE_CHANGED` events:
- Detects when user opens a new app
- Increments open counter
- Tracks session start time
- Compares against configured limits

### 3. Blocking Mechanism
When limit is exceeded:
1. **BlockingOverlayActivity** launches immediately
2. User sees blocking message
3. App is forced to background
4. User redirected to home screen

### 4. Daily Reset
- Counters reset at midnight automatically
- Uses `last_reset_date` to track last reset
- Ensures accurate daily tracking

## Permissions Required

### 1. SYSTEM_ALERT_WINDOW (Overlay Permission)
```xml
<uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW"/>
```
**Purpose**: Display blocking overlay on top of other apps

**How to Request**:
```dart
await AppBlockerService.requestOverlayPermission();
```

### 2. BIND_ACCESSIBILITY_SERVICE (Accessibility Permission)
```xml
<uses-permission android:name="android.permission.BIND_ACCESSIBILITY_SERVICE"/>
```
**Purpose**: Monitor app switches and detect which apps are opened

**How to Request**:
```dart
await AppBlockerService.requestAccessibilityPermission();
```

### 3. FOREGROUND_SERVICE
```xml
<uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
```
**Purpose**: Keep monitoring active in background

### 4. POST_NOTIFICATIONS (Android 13+)
```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```
**Purpose**: Show foreground service notification

## Usage Flow

### Setting Up App Limits

```dart
// 1. User selects apps
List<SelectedAppInfo> selectedApps = [...];

// 2. User sets limits
Map<String, String> appOpens = {
  'com.facebook.katana': '5 Times',
};
Map<String, String> appDurations = {
  'com.facebook.katana': '30 Mins',
};

// 3. Save to storage
List<AppLimitModel> limits = [...];
await AppLimitStorageService.saveAppLimits(limits);

// 4. Request permissions
Navigator.push(context, PermissionsSetupScreen());

// 5. Start monitoring
await AppBlockerService.startMonitoring();
```

### Checking Status

```dart
// Check if monitoring is active
bool isActive = await AppBlockerService.isMonitoringActive();

// Check permissions
bool hasOverlay = await AppBlockerService.hasOverlayPermission();
bool hasAccessibility = await AppBlockerService.hasAccessibilityPermission();

// Get configured limits
List<AppLimitModel> limits = await AppLimitStorageService.getAppLimits();
```

### Stopping Monitoring

```dart
await AppBlockerService.stopMonitoring();
```

## Edge Cases Handled

### 1. **Service Killed by System**
- Service uses `START_STICKY` flag
- Automatically restarts if killed
- Foreground service reduces kill likelihood

### 2. **Daily Counter Reset**
- Checks date on service start
- Resets counters if new day
- Prevents incorrect blocking

### 3. **Permission Revoked**
- App detects when permissions are revoked
- Shows warning to user
- Stops monitoring gracefully

### 4. **Multiple App Switches**
- Tracks last package name
- Only counts unique opens
- Prevents duplicate counting

### 5. **System Apps**
- Ignores Android system UI
- Doesn't block launcher
- Filters our own app

### 6. **Session Duration Tracking**
- Uses timestamp difference
- Checks duration periodically
- Blocks mid-session if limit exceeded

### 7. **Inactive Days**
- Checks current day of week
- Only enforces on active days
- Allows weekend exceptions

## Testing Checklist

### Functional Tests
- [ ] App opens are counted correctly
- [ ] Session duration is tracked accurately
- [ ] Blocking overlay appears when limit exceeded
- [ ] User cannot bypass blocking screen
- [ ] Daily counters reset at midnight
- [ ] Permissions can be granted successfully
- [ ] Foreground service stays active
- [ ] Accessibility service detects app switches

### Edge Case Tests
- [ ] Service survives device reboot
- [ ] Handles rapid app switching
- [ ] Works with split-screen mode
- [ ] Handles permission revocation
- [ ] Manages multiple blocked apps
- [ ] Respects inactive days
- [ ] Functions in battery saver mode

### UX Tests
- [ ] Blocking message is clear
- [ ] Permission flow is intuitive
- [ ] Setup process is smooth
- [ ] Error messages are helpful
- [ ] Notifications are not intrusive

## Debugging

### Enable Logs
```kotlin
// In Kotlin files
Log.d("AppMonitoringService", "Debug message")
```

```dart
// In Flutter
debugPrint('Debug message');
```

### Check Service Status
```bash
# Check if accessibility service is running
adb shell settings get secure enabled_accessibility_services

# Check foreground services
adb shell dumpsys activity services AppMonitoringForegroundService
```

### View SharedPreferences
```bash
# Pull shared preferences file
adb shell run-as com.limitit.digitalbalance  cat \
  /data/data/com.limitit.digitalbalance /shared_prefs/flutter.app_limits.xml
```

## Known Limitations

1. **Android Only**: iOS doesn't provide APIs for app monitoring
2. **Battery Impact**: Continuous monitoring uses some battery
3. **User Can Disable**: Technical users can disable accessibility service
4. **Not 100% Foolproof**: Determined users can find workarounds
5. **Requires Manual Setup**: User must grant permissions manually

## Best Practices

1. **Educate Users**: Explain why permissions are needed
2. **Test Thoroughly**: Test on multiple Android versions
3. **Monitor Battery**: Watch for excessive battery drain
4. **Handle Errors**: Gracefully handle service failures
5. **Respect Privacy**: Only monitor what's necessary
6. **Clear Communication**: Show clear blocking messages

## Future Enhancements

1. **Weekly/Monthly Limits**: Add longer time period limits
2. **Break Reminders**: Suggest breaks before blocking
3. **Productivity Mode**: Block distracting apps during work hours
4. **Usage Analytics**: Show detailed usage reports
5. **Parental Controls**: Add PIN protection for settings
6. **Smart Scheduling**: AI-based optimal usage times

## Support

For issues or questions:
- Check logs for error messages
- Verify all permissions are granted
- Test on physical device (not emulator)
- Review Android version compatibility

## License & Credits

This implementation uses:
- Flutter Method Channels for native communication
- Android AccessibilityService API
- Android UsageStatsManager API
- SharedPreferences for data persistence
