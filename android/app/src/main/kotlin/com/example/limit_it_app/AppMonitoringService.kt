package com.example.limit_it_app

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.AccessibilityServiceInfo
import android.content.Intent
import android.util.Log
import android.view.accessibility.AccessibilityEvent
import android.content.Context
import android.content.SharedPreferences
import java.util.*

/**
 * AccessibilityService to monitor app launches and enforce app limits
 */
class AppMonitoringService : AccessibilityService() {

    private var lastPackageName: String? = null
    private var appLaunchTime: Long = 0
    private val TAG = "AppMonitoringService"

    private lateinit var sharedPreferences: SharedPreferences
    private lateinit var blockerPreferences: SharedPreferences
    private val appSessionStartTimes = mutableMapOf<String, Long>()
    private val appOpenCountsToday = mutableMapOf<String, Int>()
    private var blockedApps = mutableSetOf<String>()

    companion object {
        var isServiceRunning = false
        private const val PREFS_NAME = "flutter.app_limits"
        private const val KEY_APP_LIMITS = "app_limits"
        private const val KEY_LAST_RESET_DATE = "last_reset_date"
        private const val BLOCKER_PREFS_NAME = "app_blocker_prefs"
        private const val KEY_BLOCKED_APPS = "blocked_apps"
    }

    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "AppMonitoringService created")
        sharedPreferences = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        blockerPreferences = getSharedPreferences(BLOCKER_PREFS_NAME, Context.MODE_PRIVATE)
        isServiceRunning = true

        // Load blocked apps
        loadBlockedApps()

        // Check if we need to reset daily counters
        checkAndResetDailyCounters()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        // Handle intent actions
        when (intent?.action) {
            "UPDATE_BLOCKED_APPS" -> {
                val blockedAppsList = intent.getStringArrayListExtra("blocked_apps")
                if (blockedAppsList != null) {
                    blockedApps.clear()
                    blockedApps.addAll(blockedAppsList)
                    Log.d(TAG, "Updated blocked apps: $blockedApps")
                }
            }
        }
        return super.onStartCommand(intent, flags, startId)
    }

    private fun loadBlockedApps() {
        blockedApps = blockerPreferences.getStringSet(KEY_BLOCKED_APPS, emptySet())?.toMutableSet() ?: mutableSetOf()
        Log.d(TAG, "Loaded blocked apps: $blockedApps")
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        Log.d(TAG, "AppMonitoringService connected")

        val info = AccessibilityServiceInfo()
        info.eventTypes = AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED
        info.feedbackType = AccessibilityServiceInfo.FEEDBACK_GENERIC
        info.flags = AccessibilityServiceInfo.FLAG_INCLUDE_NOT_IMPORTANT_VIEWS
        info.notificationTimeout = 100

        serviceInfo = info
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null) return

        if (event.eventType == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
            event.packageName?.toString()?.let { packageName ->
                // Ignore our own app and system UI
                if (packageName == this.packageName ||
                    packageName == "com.android.systemui" ||
                    packageName == "android") {
                    return
                }

                handleAppSwitch(packageName)
            }
        }
    }

    private fun handleAppSwitch(packageName: String) {
        val currentTime = System.currentTimeMillis()

        // Track session time for previous app
        if (lastPackageName != null && lastPackageName != packageName) {
            val sessionDuration = (currentTime - appLaunchTime) / 1000 / 60 // minutes
            Log.d(TAG, "Previous app $lastPackageName session: $sessionDuration minutes")
        }

        // Check if this is a new app launch
        if (lastPackageName != packageName) {
            lastPackageName = packageName
            appLaunchTime = currentTime

            // Increment open count
            val currentCount = appOpenCountsToday.getOrDefault(packageName, 0)
            appOpenCountsToday[packageName] = currentCount + 1

            // Store session start time
            appSessionStartTimes[packageName] = currentTime

            Log.d(TAG, "App launched: $packageName (Opens today: ${appOpenCountsToday[packageName]})")

            // Check if app should be blocked
            checkAndBlockApp(packageName)
        } else {
            // Same app, check session duration
            val sessionDuration = (currentTime - appLaunchTime) / 1000 / 60 // minutes
            checkSessionDuration(packageName, sessionDuration.toInt())
        }
    }

    private fun checkAndBlockApp(packageName: String) {
        // First check if app is in instant block list
        if (blockedApps.contains(packageName)) {
            Log.d(TAG, "Blocking $packageName - app is in instant block list")
            showBlockingOverlay(packageName, "App Blocked",
                "This app has been blocked. You can unblock it from the app list.")
            returnToHome()
            return
        }

        // Then check app limits
        val appLimits = getAppLimitsFromPrefs()
        val limit = appLimits.find { it.packageName == packageName } ?: return

        // Check if today is an active day
        val today = getDayOfWeek()
        if (!limit.activeDays.contains(today)) {
            Log.d(TAG, "Today ($today) is not an active day for $packageName")
            return
        }

        // Check open count limit
        val opensToday = appOpenCountsToday.getOrDefault(packageName, 0)
        if (opensToday > limit.maxDailyOpens) {
            Log.d(TAG, "Blocking $packageName - exceeded open limit ($opensToday > ${limit.maxDailyOpens})")
            showBlockingOverlay(packageName, "Daily open limit reached",
                "You've opened ${limit.appName} $opensToday times today. Limit: ${limit.maxDailyOpens}")
            returnToHome()
            return
        }
    }

    private fun checkSessionDuration(packageName: String, durationMinutes: Int) {
        val appLimits = getAppLimitsFromPrefs()
        val limit = appLimits.find { it.packageName == packageName } ?: return

        if (durationMinutes >= limit.maxSessionDurationMinutes) {
            Log.d(TAG, "Blocking $packageName - exceeded session duration ($durationMinutes >= ${limit.maxSessionDurationMinutes})")
            showBlockingOverlay(packageName, "Session time limit reached",
                "You've used ${limit.appName} for $durationMinutes minutes. Limit: ${limit.maxSessionDurationMinutes} minutes")
            returnToHome()
        }
    }

    private fun showBlockingOverlay(packageName: String, title: String, message: String) {
        val intent = Intent(this, BlockingOverlayActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
            addFlags(Intent.FLAG_ACTIVITY_NO_HISTORY)
            putExtra("packageName", packageName)
            putExtra("title", title)
            putExtra("message", message)
        }
        startActivity(intent)
    }

    private fun returnToHome() {
        val homeIntent = Intent(Intent.ACTION_MAIN).apply {
            addCategory(Intent.CATEGORY_HOME)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
        }
        startActivity(homeIntent)
    }

    private fun getAppLimitsFromPrefs(): List<AppLimit> {
        val json = sharedPreferences.getString(KEY_APP_LIMITS, null) ?: return emptyList()

        return try {
            val jsonArray = org.json.JSONArray(json)
            val limits = mutableListOf<AppLimit>()

            for (i in 0 until jsonArray.length()) {
                val obj = jsonArray.getJSONObject(i)
                limits.add(AppLimit(
                    packageName = obj.getString("packageName"),
                    appName = obj.getString("appName"),
                    maxDailyOpens = obj.getInt("maxDailyOpens"),
                    maxSessionDurationMinutes = obj.getInt("maxSessionDurationMinutes"),
                    activeDays = obj.getJSONArray("activeDays").let { arr ->
                        List(arr.length()) { arr.getString(it) }
                    }
                ))
            }
            limits
        } catch (e: Exception) {
            Log.e(TAG, "Error parsing app limits", e)
            emptyList()
        }
    }

    private fun checkAndResetDailyCounters() {
        val today = getTodayDate()
        val lastReset = sharedPreferences.getString(KEY_LAST_RESET_DATE, null)

        if (lastReset != today) {
            Log.d(TAG, "Resetting daily counters (last reset: $lastReset, today: $today)")
            appOpenCountsToday.clear()
            sharedPreferences.edit().putString(KEY_LAST_RESET_DATE, today).apply()
        }
    }

    private fun getTodayDate(): String {
        val calendar = Calendar.getInstance()
        return "${calendar.get(Calendar.YEAR)}-${calendar.get(Calendar.MONTH)}-${calendar.get(Calendar.DAY_OF_MONTH)}"
    }

    private fun getDayOfWeek(): String {
        val calendar = Calendar.getInstance()
        return when (calendar.get(Calendar.DAY_OF_WEEK)) {
            Calendar.SUNDAY -> "SUN"
            Calendar.MONDAY -> "MON"
            Calendar.TUESDAY -> "TUE"
            Calendar.WEDNESDAY -> "WED"
            Calendar.THURSDAY -> "THU"
            Calendar.FRIDAY -> "FRI"
            Calendar.SATURDAY -> "SAT"
            else -> ""
        }
    }

    override fun onInterrupt() {
        Log.d(TAG, "AppMonitoringService interrupted")
    }

    override fun onDestroy() {
        super.onDestroy()
        isServiceRunning = false
        Log.d(TAG, "AppMonitoringService destroyed")
    }

    data class AppLimit(
        val packageName: String,
        val appName: String,
        val maxDailyOpens: Int,
        val maxSessionDurationMinutes: Int,
        val activeDays: List<String>
    )
}
