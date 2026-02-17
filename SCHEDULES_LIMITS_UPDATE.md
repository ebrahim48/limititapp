# Schedules Limits Screen - Dynamic Update

## Overview
The SchedulesLimitsScreen has been updated to dynamically display blocked apps with their schedules, showing:
- **Number of blocked apps** in a badge next to the header
- **Start time and end time** for each app's schedule
- **Real-time usage data** from SharedPreferences
- **Expand/collapse** functionality for multiple apps

## Changes Made

### 1. Updated Files

#### `lib/controllers/schedules_limits_controller.dart`
**New Features:**
- `blockedAppsCount` - Reactive count of blocked apps
- `isLoading` - Loading state indicator
- `loadBlockedApps()` - Dynamically loads blocked apps from SharedPreferences
- `saveSchedules()` - Saves schedule times for enabled apps
- `_formatTimeTo12Hour()` - Converts 24h format to 12h AM/PM
- `_convertTo24Hour()` - Converts 12h AM/PM to 24h format
- `_getAppIcon()` - Maps package names to app icons

**Logic:**
1. First loads from `BlockedAppsService` (instant block feature)
2. Falls back to `AppLimitStorageService` if no blocked apps exist
3. Displays usage statistics from today's app usage
4. Shows schedule times from app limits or defaults to 10:00 PM - 06:00 AM

#### `lib/core/models/app_bock_item.dart`
**Added:**
- `packageName` (optional) - To track which app the item represents

#### `lib/core/models/app_limit_model.dart`
**Added:**
- `scheduleStartTime` (RxString?) - Schedule start time in 24h format
- `scheduleEndTime` (RxString?) - Schedule end time in 24h format
- `isActive` (RxBool?) - Whether the schedule is currently active

**Updated:**
- `toJson()` - Now includes schedule fields
- `fromJson()` - Parses schedule fields from JSON
- `copyWith()` - Supports updating schedule fields

#### `lib/core/presentations/screens/limits/schedules_limits_screen.dart`
**New UI Features:**
- **App count badge** - Shows number of blocked apps (green pill badge)
- **Loading indicator** - Circular progress indicator while loading data
- **Empty state** - Helpful message when no blocked apps exist
- **Dynamic expand/collapse** - Only shows when multiple apps exist
- **Smart save button** - Disabled when no apps are enabled
- **Success toast** - Shows confirmation after saving schedules

**UI States:**
1. **Loading** - Shows circular progress indicator
2. **Empty** - Shows "No blocked apps" with icon and message
3. **Loaded** - Shows app cards with schedules
4. **No enabled apps** - Save button is disabled (opacity 0.5)

#### `lib/core/constants/app_colors.dart`
**Added:**
- `primaryGreen` - Color(0xff4C956C) for the app count badge

## How It Works

### Data Flow

```
User blocks app from Home Screen
    ↓
BlockedAppsService saves to SharedPreferences
    ↓
SchedulesLimitsScreen loads blocked apps
    ↓
Displays app count, name, icon, usage, schedule times
    ↓
User modifies schedule times
    ↓
User clicks Save
    ↓
saveSchedules() converts times to 24h format
    ↓
AppLimitStorageService saves to SharedPreferences
    ↓
Success message shown
```

### Time Format Conversion

**Display Format (UI):** `10:00 PM`, `06:00 AM` (12-hour with AM/PM)
**Storage Format (SharedPreferences):** `22:00`, `06:00` (24-hour)

**Conversion Methods:**
```dart
// 24h → 12h
_formatTimeTo12Hour("22:00") → "10:00 PM"
_formatTimeTo12Hour("06:00") → "6:00 AM"

// 12h → 24h
_convertTo24Hour("10:00 PM") → "22:00"
_convertTo24Hour("6:00 AM") → "06:00"
```

## Features

### 1. Dynamic App Count Badge
Shows total number of blocked apps:
- Green badge with white text
- Displays "1 App" or "X Apps" (plural handling)
- Only visible when count > 0

### 2. Real Usage Data
Displays actual app usage from today:
- Format: "45 mins • 12 Opens"
- Shows "No usage today" if app hasn't been used
- Loaded from SharedPreferences

### 3. Schedule Time Display
Each app shows:
- **Start Time** - When the schedule begins
- **End Time** - When the schedule ends
- Editable via time picker dialog
- Stored in 24h format, displayed in 12h format

### 4. Enable/Disable Toggle
- Switch to enable/disable schedule for each app
- Time pickers only visible when enabled
- Save button disabled if no apps are enabled

### 5. Expand/Collapse
- Shows first app by default
- Tap arrow to expand/collapse all apps
- Only appears if multiple apps exist

### 6. Empty States
**No blocked apps:**
```
[Icon: app_blocking_outlined]
No blocked apps
Apps you block will appear here
```

**No app limits configured:**
```
No blocked apps yet. Block apps from the home screen to set schedules.
```

## Usage

### View Schedules
1. Navigate to Schedules screen
2. Blocked apps automatically load
3. See count badge showing total blocked apps
4. Each app shows:
   - App icon and name
   - Today's usage (time • opens)
   - Enable/disable switch
   - Start time and end time (when enabled)

### Edit Schedule
1. Toggle app switch to enable
2. Tap "Start Time" field
3. Select time from time picker
4. Tap "End Time" field
5. Select time from time picker
6. Tap "Save App Block"
7. See success confirmation

### Programmatic Usage

```dart
// Load blocked apps
final controller = Get.find<SchedulesLimitsController>();
await controller.loadBlockedApps();

// Get blocked apps count
int count = controller.blockedAppsCount.value;

// Save schedules
await controller.saveSchedules();

// Refresh data
await controller.refresh();
```

## Testing Checklist

- [ ] Blocked apps count displays correctly
- [ ] App icons load properly
- [ ] Usage data shows real values
- [ ] Start/End times display in 12h format
- [ ] Time picker works correctly
- [ ] Save button enabled only when apps are enabled
- [ ] Success message appears after save
- [ ] Empty state shows when no blocked apps
- [ ] Loading indicator appears during load
- [ ] Expand/collapse works with multiple apps
- [ ] Schedule times persist after app restart

## Dependencies

Uses existing services:
- `BlockedAppsService` - Get blocked apps list
- `AppLimitStorageService` - Get/save app limits and schedules
- `SharedPreferences` - Data persistence

## Platform Support

| Platform | Support | Notes |
|----------|---------|-------|
| Android  | ✅ Full | All features work |
| iOS      | ⚠️ Limited | Falls back to app limits (no instant block) |

## Future Enhancements

Potential improvements:
- Add schedule presets (Morning, Night, Work hours)
- Recurring schedule patterns (weekdays, weekends)
- Schedule conflict detection
- Bulk enable/disable all
- Schedule notifications
- Integration with native AppMonitoringService

## Notes

- Times are stored in 24h format internally
- Display uses 12h format with AM/PM for better UX
- Schedule times default to 10:00 PM - 06:00 AM if not set
- App icon mapping supports common social media apps
- Falls back to Facebook icon if app icon not found

## Files Modified

1. `lib/controllers/schedules_limits_controller.dart` - Complete rewrite
2. `lib/core/models/app_bock_item.dart` - Added packageName field
3. `lib/core/models/app_limit_model.dart` - Added schedule fields
4. `lib/core/presentations/screens/limits/schedules_limits_screen.dart` - Enhanced UI
5. `lib/core/constants/app_colors.dart` - Added primaryGreen

## Backward Compatibility

- Existing app limits without schedule fields will use defaults
- Old JSON format still supported (fields are optional)
- No breaking changes to existing functionality
