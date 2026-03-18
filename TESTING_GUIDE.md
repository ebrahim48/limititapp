# Testing Guide for App Blocking Feature

## Prerequisites
- Physical Android device (API 24+, recommended API 30+)
- USB debugging enabled
- Device connected via ADB

## Build and Install

```bash
# Clean build
flutter clean
flutter pub get

# Build and install on device
flutter run --release

# Or build APK
flutter build apk --release
```

## Testing Steps

### Step 1: Setup App Limits

1. **Open the app** and navigate to the app limits setup flow
2. **Select Days**: Choose days when limits should be active (e.g., MON, TUE, WED)
3. **Select Apps**:
   - You should see your real installed apps
   - Select 1-2 apps for testing (e.g., Chrome, Instagram)
   - Click "Continue"
4. **Set Limits**:
   - For each app, set:
     - **Daily Opens**: 3 Times (for easy testing)
     - **Session Duration**: 1 Mins (for easy testing)
   - Click "Save & Continue"

### Step 2: Grant Permissions

The app will navigate to the Permissions Setup screen.

#### 2.1 Overlay Permission
1. Click "Grant" next to "Overlay Permission"
2. You'll be taken to Android Settings
3. Find "LimitIt" in the list
4. Toggle "Allow display over other apps" to ON
5. Press back to return to the app

**Verification**: Green checkmark should appear next to "Overlay Permission"

#### 2.2 Accessibility Permission
1. Click "Grant" next to "Accessibility Service"
2. You'll be taken to Android Settings → Accessibility
3. Find "LimitIt" or "App Monitoring" in the list
4. Tap it and toggle the switch to ON
5. Confirm the warning dialog
6. Press back to return to the app

**Verification**: Green checkmark should appear next to "Accessibility Service"

### Step 3: Start Monitoring

1. Once both permissions are granted, "Start Monitoring" button becomes enabled
2. Click "Start Monitoring"
3. You should see:
   - Success message: "App monitoring started successfully!"
   - Notification appears: "LimitIt is Active"

### Step 4: Test App Blocking

#### Test 1: Open Count Limit
1. **Open a limited app** (e.g., Chrome)
2. **Close it** (press home button)
3. **Repeat** 3 times (or whatever limit you set)
4. On the **4th open**, you should see:
   - Full-screen blocking overlay
   - Message: "Daily open limit reached"
   - "Go Back to Home" button
5. **Try to go back** - pressing back should return you to home screen

**Expected**: App is blocked, user cannot access it

#### Test 2: Session Duration Limit
1. **Open a limited app** (different from Test 1)
2. **Keep it open** for more than 1 minute (or your set limit)
3. After the time limit:
   - Blocking overlay should appear
   - Message: "Session time limit reached"
   - App is closed automatically

**Expected**: App is blocked after session time exceeds limit

#### Test 3: Daily Reset
1. **Change device date** to next day:
   ```bash
   # Via ADB
   adb shell date MMDDHHMMYYYY.SS
   ```
   OR manually in Settings → Date & Time
2. **Open previously blocked app**
3. **Should work normally** (counters reset)

**Expected**: App opens normally after date change

### Step 5: Check Service Status

#### Via Logcat
```bash
# Filter logs
adb logcat | grep -E "AppMonitoring|MonitoringFg"

# You should see logs like:
# D/AppMonitoringService: App launched: com.android.chrome (Opens today: 1)
# D/AppMonitoringService: Blocking com.android.chrome - exceeded open limit
```

#### Via Settings
1. **Settings → Apps → LimitIt**
2. Check "Battery" - should show "Background usage"
3. **Settings → Notifications**
4. Should see "LimitIt is Active" notification

#### Via Accessibility Settings
1. **Settings → Accessibility**
2. Find "LimitIt" or "App Monitoring"
3. Should show as "On"

## Troubleshooting

### Issue: "Permission denied" error
**Solution**: Re-grant permissions via Settings

### Issue: Blocking overlay doesn't appear
**Checks**:
- [ ] Accessibility service is enabled
- [ ] Overlay permission is granted
- [ ] App limits are saved (check SharedPreferences)
- [ ] Today is an active day

### Issue: Service stops after device sleep
**Solution**:
- Disable battery optimization for LimitIt
- Settings → Battery → Battery optimization → LimitIt → Don't optimize

### Issue: Foreground service notification is dismissed
**Solution**: This shouldn't happen as notification is persistent. If it does, restart monitoring.

### Issue: App bypasses blocking
**Checks**:
- [ ] Accessibility service is running
- [ ] Limits are correctly configured
- [ ] System apps are not being blocked (by design)

## Debug Commands

### Check if accessibility service is running
```bash
adb shell settings get secure enabled_accessibility_services
# Should include: com.limitit.digitalbalance 
```

### View SharedPreferences
```bash
adb shell run-as com.limitit.digitalbalance  cat \
  /data/data/com.limitit.digitalbalance /shared_prefs/flutter.app_limits.xml
```

### Force stop and restart
```bash
adb shell am force-stop com.limitit.digitalbalance 
adb shell am start -n com.limitit.digitalbalance /.MainActivity
```

### Clear app data (reset everything)
```bash
adb shell pm clear com.limitit.digitalbalance 
```

## Expected Behavior Summary

| Scenario | Expected Result |
|----------|----------------|
| Open app 3 times | Works fine |
| Open app 4th time | Blocked with overlay |
| Use app for 1 min | Works fine |
| Use app for >1 min | Blocked with overlay |
| Next day | Counters reset, works normally |
| Inactive day | App opens normally (not blocked) |
| System app | Never blocked |
| Revoke permission | Monitoring stops gracefully |
| Device reboot | Service auto-starts (if enabled) |

## Test Checklist

- [ ] App limits save correctly
- [ ] Both permissions can be granted
- [ ] Foreground service starts
- [ ] Notification appears
- [ ] Open count is tracked
- [ ] Open limit is enforced
- [ ] Session duration is tracked
- [ ] Duration limit is enforced
- [ ] Blocking overlay appears
- [ ] Cannot bypass blocking
- [ ] Daily reset works
- [ ] Inactive days work
- [ ] Service survives app closure
- [ ] Multiple apps can be limited
- [ ] Real app icons display correctly

## Performance Testing

### Battery Usage
1. Enable monitoring
2. Use device normally for 1 hour
3. Check battery stats:
   ```bash
   adb shell dumpsys batterystats --charged com.limitit.digitalbalance 
   ```

**Expected**: <5% battery usage per hour

### Memory Usage
```bash
adb shell dumpsys meminfo com.limitit.digitalbalance 
```

**Expected**: <50 MB

## Known Limitations

1. **Cannot block system apps** - Android security restriction
2. **User can disable service** - Intentional for user control
3. **Requires manual setup** - Cannot auto-grant permissions
4. **Android only** - iOS doesn't support this functionality
5. **Not 100% foolproof** - Technical users can find workarounds

## Success Criteria

✅ All test cases pass
✅ No crashes or errors
✅ Blocking works reliably
✅ Battery impact is acceptable
✅ User experience is smooth
✅ Permissions flow is clear

## Support

If you encounter issues:
1. Check logcat output
2. Verify permissions in Settings
3. Clear app data and retry
4. Test on different Android version
5. Check device-specific restrictions
