package com.limitit.digitalbalance

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.AccessibilityServiceInfo
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.util.Log
import android.view.accessibility.AccessibilityEvent
import org.json.JSONArray
import org.json.JSONObject
import java.util.Calendar

/**
 * AccessibilityService that watches app launches and enforces the protections
 * the user configured in Flutter.
 *
 * The protection list is written by Dart through `shared_preferences`, which on
 * Android always lands in the `FlutterSharedPreferences` XML with every key
 * prefixed `flutter.` — see [FLUTTER_PREFS] / [KEY_APP_LIMITS]. Reading any
 * other file/key combination silently yields an empty list and nothing ever
 * gets blocked.
 */
class AppMonitoringService : AccessibilityService() {

    private var lastPackageName: String? = null
    private var appLaunchTime: Long = 0
    private val TAG = "AppMonitoringService"

    private lateinit var flutterPreferences: SharedPreferences
    private lateinit var blockerPreferences: SharedPreferences
    private val openCountsToday = mutableMapOf<String, Int>()
    private var blockedApps = mutableSetOf<String>()
    private lateinit var usageStatsManager: UsageStatsManager

    // Debouncing mechanism
    private var lastBlockedPackage: String? = null
    private var lastBlockTime: Long = 0
    private val blockCooldownMs = 2000L
    private val currentlyBlockedApps = mutableSetOf<String>()

    /** When each app was last shown the mindful pause, so it fires once per visit. */
    private val lastPauseAt = mutableMapOf<String, Long>()
    private val pauseCooldownMs = 60_000L

    /** Throttle for the in-app re-check; window events fire on every dialog. */
    private val lastTimeCheckAt = mutableMapOf<String, Long>()
    private val timeCheckIntervalMs = 15_000L

    companion object {
        var isServiceRunning = false

        /** The XML file the shared_preferences plugin writes to. */
        private const val FLUTTER_PREFS = "FlutterSharedPreferences"

        /** `AppLimitStorageService._keyAppLimits`, with the plugin's prefix. */
        private const val KEY_APP_LIMITS = "flutter.app_limits"

        private const val BLOCKER_PREFS_NAME = "app_blocker_prefs"
        private const val KEY_BLOCKED_APPS = "blocked_apps"
        private const val KEY_OPEN_COUNTS = "open_counts_today"
        private const val KEY_COUNTS_DATE = "open_counts_date"
    }

    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "AppMonitoringService created")
        flutterPreferences = getSharedPreferences(FLUTTER_PREFS, Context.MODE_PRIVATE)
        blockerPreferences = getSharedPreferences(BLOCKER_PREFS_NAME, Context.MODE_PRIVATE)
        usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        isServiceRunning = true

        loadBlockedApps()
        loadOpenCounts()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
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
        blockedApps = blockerPreferences.getStringSet(KEY_BLOCKED_APPS, emptySet())
            ?.toMutableSet() ?: mutableSetOf()
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
                // Our own screens (including the pause overlay) and system chrome
                // must never count as an app launch.
                if (packageName == this.packageName ||
                    packageName == "com.android.systemui" ||
                    packageName == "android"
                ) {
                    return
                }

                handleAppSwitch(packageName)
            }
        }
    }

    private fun handleAppSwitch(packageName: String) {
        val currentTime = System.currentTimeMillis()

        if (lastPackageName != packageName) {
            lastPackageName = packageName
            appLaunchTime = currentTime

            rollOverCountsIfNewDay()
            val count = openCountsToday.getOrDefault(packageName, 0) + 1
            openCountsToday[packageName] = count
            saveOpenCounts()

            Log.d(TAG, "App launched: $packageName (opens today: $count)")

            checkAndBlockApp(packageName)
        } else {
            // Still in the same app — re-check the time-based rules so a limit
            // reached mid-session takes effect without a relaunch.
            checkTimeBasedLimits(packageName)
        }
    }

    private fun checkAndBlockApp(packageName: String) {
        val now = System.currentTimeMillis()

        if (lastBlockedPackage == packageName && now - lastBlockTime < blockCooldownMs) {
            Log.d(TAG, "Ignoring rapid block attempt for: $packageName")
            return
        }
        if (currentlyBlockedApps.contains(packageName)) {
            Log.d(TAG, "App $packageName is already being blocked")
            return
        }

        // Detox / instant block list wins over every configured limit.
        if (blockedApps.contains(packageName)) {
            Log.d(TAG, "Blocking $packageName - in instant block list")
            blockApp(packageName) {
                putExtra(BlockingOverlayActivity.EXTRA_BLOCK_TYPE, BlockingOverlayActivity.TYPE_INSTANT)
            }
            return
        }

        val limit = findLimit(packageName) ?: return
        if (!isActiveToday(limit)) {
            Log.d(TAG, "${limit.packageName}: protection not active today")
            return
        }

        when (limit.protectionType) {
            "maxOpens" -> {
                val opens = openCountsToday.getOrDefault(packageName, 0)
                if (limit.maxDailyOpens > 0 && opens > limit.maxDailyOpens) {
                    Log.d(TAG, "Blocking $packageName - opens $opens > ${limit.maxDailyOpens}")
                    blockApp(packageName, limit) {
                        putExtra(BlockingOverlayActivity.EXTRA_BLOCK_TYPE, BlockingOverlayActivity.TYPE_OPENS)
                        putExtra(BlockingOverlayActivity.EXTRA_MAX_OPENS, limit.maxDailyOpens)
                    }
                }
            }

            "timeBlock" -> {
                if (isWithinSchedule(limit.scheduleStartTime, limit.scheduleEndTime)) {
                    Log.d(TAG, "Blocking $packageName - inside blocked schedule")
                    blockApp(packageName, limit) {
                        putExtra(BlockingOverlayActivity.EXTRA_BLOCK_TYPE, BlockingOverlayActivity.TYPE_SCHEDULE)
                        putExtra(BlockingOverlayActivity.EXTRA_SCHEDULE_START, limit.scheduleStartTime)
                        putExtra(BlockingOverlayActivity.EXTRA_SCHEDULE_END, limit.scheduleEndTime)
                    }
                }
            }

            "delayOpening" -> {
                if (limit.delaySeconds > 0) {
                    val lastPause = lastPauseAt[packageName] ?: 0L
                    if (now - lastPause > pauseCooldownMs) {
                        lastPauseAt[packageName] = now
                        showPause(packageName, limit)
                    }
                }
            }

            else -> checkTimeBasedLimits(packageName, force = true)
        }
    }

    /**
     * Daily-limit enforcement. Uses the real foreground total from
     * UsageStats rather than an in-memory session timer, so time spent before
     * the service started still counts.
     */
    private fun checkTimeBasedLimits(packageName: String, force: Boolean = false) {
        val now = System.currentTimeMillis()
        if (currentlyBlockedApps.contains(packageName)) return
        if (lastBlockedPackage == packageName && now - lastBlockTime < blockCooldownMs) return

        // A fresh launch always checks; the throttle only exists to keep the
        // repeated in-app window events cheap.
        if (!force) {
            val lastCheck = lastTimeCheckAt[packageName] ?: 0L
            if (now - lastCheck < timeCheckIntervalMs) return
        }
        lastTimeCheckAt[packageName] = now

        val limit = findLimit(packageName) ?: return
        if (!isActiveToday(limit)) return
        if (limit.protectionType != "dailyLimit") return
        if (limit.maxSessionDurationMinutes <= 0) return

        val usedMinutes = todayForegroundMinutes(packageName)
        if (usedMinutes >= limit.maxSessionDurationMinutes) {
            Log.d(
                TAG,
                "Blocking $packageName - used $usedMinutes >= ${limit.maxSessionDurationMinutes} min"
            )
            blockApp(packageName, limit) {
                putExtra(BlockingOverlayActivity.EXTRA_BLOCK_TYPE, BlockingOverlayActivity.TYPE_TIME)
                putExtra(BlockingOverlayActivity.EXTRA_USED_MINUTES, usedMinutes)
                putExtra(BlockingOverlayActivity.EXTRA_LIMIT_MINUTES, limit.maxSessionDurationMinutes)
            }
        }
    }

    /**
     * Hard block: push the user home, then show the blocking screen. [extras]
     * adds the block type and the numbers that screen displays.
     */
    private fun blockApp(
        packageName: String,
        limit: AppLimit? = null,
        extras: Intent.() -> Unit
    ) {
        try {
            val currentTime = System.currentTimeMillis()

            currentlyBlockedApps.add(packageName)
            lastBlockedPackage = packageName
            lastBlockTime = currentTime

            Log.d(TAG, "Blocking app: $packageName")

            val homeIntent = Intent(Intent.ACTION_MAIN).apply {
                addCategory(Intent.CATEGORY_HOME)
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            startActivity(homeIntent)

            android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
                try {
                    val intent = Intent(this@AppMonitoringService, BlockingOverlayActivity::class.java).apply {
                        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        addFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK)
                        addFlags(Intent.FLAG_ACTIVITY_EXCLUDE_FROM_RECENTS)
                        addFlags(Intent.FLAG_ACTIVITY_NO_HISTORY)
                        addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
                        putExtra(BlockingOverlayActivity.EXTRA_PACKAGE, packageName)
                        putLimitExtras(limit)
                        extras()
                    }
                    startActivity(intent)
                    Log.d(TAG, "Successfully blocked app: $packageName")

                    android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
                        currentlyBlockedApps.remove(packageName)
                    }, 1000)
                } catch (e: Exception) {
                    Log.e(TAG, "Error starting BlockingOverlayActivity", e)
                    currentlyBlockedApps.remove(packageName)
                }
            }, 200)
        } catch (e: Exception) {
            Log.e(TAG, "Error blocking app: $packageName", e)
            currentlyBlockedApps.remove(packageName)
        }
    }

    /**
     * Mindful pause: overlay the app with a countdown and let the user through
     * when it runs out. No home intent here — the app stays behind the overlay
     * so dismissing it returns the user straight to it.
     */
    private fun showPause(packageName: String, limit: AppLimit) {
        try {
            Log.d(TAG, "Pausing $packageName for ${limit.delaySeconds}s")
            val intent = Intent(this, BlockingOverlayActivity::class.java).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                addFlags(Intent.FLAG_ACTIVITY_EXCLUDE_FROM_RECENTS)
                addFlags(Intent.FLAG_ACTIVITY_NO_HISTORY)
                addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
                putExtra(BlockingOverlayActivity.EXTRA_PACKAGE, packageName)
                putExtra(BlockingOverlayActivity.EXTRA_BLOCK_TYPE, BlockingOverlayActivity.TYPE_DELAY)
                putExtra(BlockingOverlayActivity.EXTRA_DELAY_SECONDS, limit.delaySeconds)
                putLimitExtras(limit)
            }
            startActivity(intent)
        } catch (e: Exception) {
            Log.e(TAG, "Error showing pause for $packageName", e)
        }
    }

    // ---------------------------------------------------------------- limits

    private fun findLimit(packageName: String): AppLimit? =
        getAppLimitsFromPrefs().find { it.packageName == packageName }

    /** An empty `activeDays` means "every day", not "never". */
    private fun isActiveToday(limit: AppLimit): Boolean =
        limit.activeDays.isEmpty() || limit.activeDays.contains(getDayOfWeek())

    private fun getAppLimitsFromPrefs(): List<AppLimit> {
        val json = flutterPreferences.getString(KEY_APP_LIMITS, null)
        if (json.isNullOrEmpty()) {
            Log.d(TAG, "No app limits stored yet")
            return emptyList()
        }

        return try {
            val jsonArray = JSONArray(json)
            val limits = mutableListOf<AppLimit>()

            for (i in 0 until jsonArray.length()) {
                val obj = jsonArray.getJSONObject(i)
                limits.add(
                    AppLimit(
                        packageName = obj.optString("packageName"),
                        appName = obj.optString("appName"),
                        maxDailyOpens = obj.optInt("maxDailyOpens", 0),
                        delaySeconds = obj.optInt("delaySeconds", 0),
                        maxSessionDurationMinutes = obj.optInt("maxSessionDurationMinutes", 0),
                        activeDays = obj.optJSONArray("activeDays").toStringList(),
                        scheduleStartTime = obj.optStringOrNull("scheduleStartTime"),
                        scheduleEndTime = obj.optStringOrNull("scheduleEndTime"),
                        protectionType = obj.optString("protectionType", "dailyLimit"),
                        customMessage = obj.optStringOrNull("customMessage")
                    )
                )
            }
            limits
        } catch (e: Exception) {
            Log.e(TAG, "Error parsing app limits", e)
            emptyList()
        }
    }

    private fun JSONArray?.toStringList(): List<String> {
        if (this == null) return emptyList()
        return List(length()) { optString(it) }.filter { it.isNotEmpty() }
    }

    private fun JSONObject.optStringOrNull(key: String): String? {
        if (isNull(key)) return null
        val value = optString(key)
        return if (value.isEmpty()) null else value
    }

    // ----------------------------------------------------------- open counts

    private fun loadOpenCounts() {
        openCountsToday.clear()
        if (blockerPreferences.getString(KEY_COUNTS_DATE, null) != getTodayDate()) {
            // Stored counts belong to a previous day.
            saveOpenCounts()
            return
        }

        val raw = blockerPreferences.getString(KEY_OPEN_COUNTS, null) ?: return
        try {
            val obj = JSONObject(raw)
            for (key in obj.keys()) {
                openCountsToday[key] = obj.optInt(key, 0)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error reading open counts", e)
        }
    }

    private fun saveOpenCounts() {
        try {
            val obj = JSONObject()
            openCountsToday.forEach { (key, value) -> obj.put(key, value) }
            blockerPreferences.edit()
                .putString(KEY_OPEN_COUNTS, obj.toString())
                .putString(KEY_COUNTS_DATE, getTodayDate())
                .apply()
        } catch (e: Exception) {
            Log.e(TAG, "Error writing open counts", e)
        }
    }

    private fun rollOverCountsIfNewDay() {
        if (blockerPreferences.getString(KEY_COUNTS_DATE, null) != getTodayDate()) {
            Log.d(TAG, "New day — resetting open counts")
            openCountsToday.clear()
            lastPauseAt.clear()
            lastTimeCheckAt.clear()
            saveOpenCounts()
        }
    }

    // ---------------------------------------------------------------- clocks

    /** Total foreground minutes for [packageName] since midnight. */
    private fun todayForegroundMinutes(packageName: String): Int {
        return try {
            val start = Calendar.getInstance().apply {
                set(Calendar.HOUR_OF_DAY, 0)
                set(Calendar.MINUTE, 0)
                set(Calendar.SECOND, 0)
                set(Calendar.MILLISECOND, 0)
            }.timeInMillis

            val stats = usageStatsManager.queryUsageStats(
                UsageStatsManager.INTERVAL_DAILY,
                start,
                System.currentTimeMillis()
            ) ?: return 0

            var total = 0L
            for (stat in stats) {
                if (stat.packageName == packageName) total += stat.totalTimeInForeground
            }
            (total / 1000 / 60).toInt()
        } catch (e: Exception) {
            Log.e(TAG, "Error reading usage for $packageName", e)
            0
        }
    }

    /** `true` while now sits inside the blocked window; handles overnight spans. */
    private fun isWithinSchedule(start: String?, end: String?): Boolean {
        val from = parseMinutes(start) ?: return false
        val to = parseMinutes(end) ?: return false

        val calendar = Calendar.getInstance()
        val now = calendar.get(Calendar.HOUR_OF_DAY) * 60 + calendar.get(Calendar.MINUTE)

        // 22:00 → 06:00 wraps past midnight.
        return if (from <= to) now in from until to else now >= from || now < to
    }

    /** "22:30" → 1350. */
    private fun parseMinutes(time: String?): Int? {
        if (time.isNullOrEmpty()) return null
        val parts = time.split(":")
        if (parts.size < 2) return null
        val hour = parts[0].trim().toIntOrNull() ?: return null
        val minute = parts[1].trim().toIntOrNull() ?: return null
        return hour * 60 + minute
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
        currentlyBlockedApps.clear()
        Log.d(TAG, "AppMonitoringService destroyed")
    }

    private fun Intent.putLimitExtras(limit: AppLimit?) {
        if (limit == null) return
        putExtra(BlockingOverlayActivity.EXTRA_APP_NAME, limit.appName)
        putExtra(BlockingOverlayActivity.EXTRA_CUSTOM_MESSAGE, limit.customMessage)
    }

    data class AppLimit(
        val packageName: String,
        val appName: String,
        val maxDailyOpens: Int,
        val delaySeconds: Int,
        val maxSessionDurationMinutes: Int,
        val activeDays: List<String>,
        val scheduleStartTime: String?,
        val scheduleEndTime: String?,
        val protectionType: String,
        val customMessage: String?
    )
}
