# App Usage Tracking Implementation

## Overview
The "Your Apps" section on the home screen now displays actual app usage data from the device (Android only).

## Features Implemented

### 1. Real App Usage Data
- Shows actual apps used today
- Displays real usage time (hours, minutes, seconds)
- Shows usage percentage relative to total screen time
- Displays actual app icons from the device
- Top 10 most used apps

### 2. Permission Handling
- Automatic permission request on first load
- "Grant Permission" button for easy access
- Clear messaging when permission is denied
- Handles permission states gracefully

### 3. Edge Cases Handled
- ✅ No permission granted
- ✅ Permission denied
- ✅ iOS devices (falls back to dummy data)
- ✅ No usage data available
- ✅ Loading states with shimmer effect
- ✅ Missing app icons (shows default icon)
- ✅ Error handling with user-friendly messages

## Files Modified/Created

### New Files
- `lib/core/services/app_usage_service.dart` - Service for fetching app usage data

### Modified Files
- `pubspec.yaml` - Added dependencies
- `lib/core/presentations/screens/Home/home_screen.dart` - Converted to StatefulWidget, added data loading
- `lib/core/presentations/widgets/your_appcard_widget.dart` - Enhanced to support both dummy and real data
- `android/app/src/main/AndroidManifest.xml` - Added required permissions

## Dependencies Added
```yaml
usage_stats: ^1.3.1           # For app usage statistics
permission_handler: ^11.3.1    # For permission handling
installed_apps: ^1.3.1         # For app icons and info
```

## Android Permissions Required
```xml
<uses-permission android:name="android.permission.PACKAGE_USAGE_STATS" />
<uses-permission android:name="android.permission.QUERY_ALL_PACKAGES"/>
```

## How It Works

### On Android:
1. App loads and requests usage access permission
2. User is taken to Android settings to grant permission
3. After granting, app fetches today's usage data
4. Displays top 10 apps with real icons, usage time, and percentages

### On iOS:
- Falls back to dummy data (iOS doesn't allow third-party apps to access usage stats)
- Shows the original hardcoded app list

## Usage

The implementation is fully automatic. When users open the home screen:

1. **First Time (No Permission)**
   - Shows loading state
   - Requests permission
   - Opens Settings for user to grant access
   - Displays "Grant Permission" button if denied

2. **With Permission**
   - Automatically loads today's app usage
   - Shows real data with app icons
   - Updates percentage based on actual usage

3. **Error States**
   - Displays clear error messages
   - Provides retry options
   - Falls back gracefully

## API Reference

### AppUsageService

#### Methods

**`requestPermission()`**
```dart
static Future<bool> requestPermission()
```
Requests usage stats permission. Returns true if granted.

**`hasPermission()`**
```dart
static Future<bool> hasPermission()
```
Checks if permission is already granted.

**`getTodayAppUsage()`**
```dart
static Future<List<AppUsageData>> getTodayAppUsage()
```
Gets app usage data for today. Returns list of AppUsageData.

**`formatUsageTime(int milliseconds)`**
```dart
static String formatUsageTime(int milliseconds)
```
Formats milliseconds to readable time (e.g., "45 mins", "2 hrs 15 mins").

### AppUsageData Model

```dart
class AppUsageData {
  final String name;              // App name
  final String packageName;       // Package name
  final Uint8List? icon;          // App icon bytes
  final int usageTimeMs;          // Usage time in milliseconds
  final double percentage;        // Usage percentage
  final int openCount;            // Number of times opened

  String get usageString;         // Formatted usage time
  String get percentageString;    // Formatted percentage (e.g., "45%")
}
```

## Testing

### To Test on Android Device:
1. Run `flutter pub get`
2. Run `flutter run` on Android device
3. Grant usage access permission when prompted
4. Return to app to see real usage data

### Expected Behavior:
- Loading shimmer appears while fetching data
- Permission dialog opens
- After granting permission, real app data displays
- Shows app icons, names, usage time, and percentages
- Top 10 most used apps for today

## Troubleshooting

### Permission Not Working
- Ensure you're testing on Android (iOS not supported)
- Check that PACKAGE_USAGE_STATS permission is in AndroidManifest.xml
- Try manually enabling permission in Settings > Apps > Your App > Usage Access

### No Data Showing
- Ensure device has been used today
- Permission must be granted
- Some apps may be filtered if usage time is 0

### Icons Not Showing
- Falls back to default icon if app icon unavailable
- Some system apps may not have accessible icons

## Platform Support

| Platform | Supported | Notes |
|----------|-----------|-------|
| Android  | ✅ Yes    | Full support with real-time data |
| iOS      | ⚠️ Limited | Falls back to dummy data (iOS limitation) |

## Future Enhancements

Potential improvements:
- Weekly/monthly usage views
- App blocking based on usage
- Usage goals and notifications
- Detailed usage analytics
- Category-based grouping
- Usage trends and charts

---

**Note**: iOS doesn't provide API access to app usage statistics for third-party apps due to privacy restrictions. Only Android devices will show real usage data.
