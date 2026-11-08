package com.limitit.digitalbalance

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.AccessibilityServiceInfo
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.Handler
import android.os.Looper
import android.os.PowerManager
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
    private val TAG = "AppMonitoringService"

    private lateinit var flutterPreferences: SharedPreferences
    private lateinit var blockerPreferences: SharedPreferences
    private val openCountsToday = mutableMapOf<String, Int>()
    private var blockedApps = mutableSetOf<String>()
    private lateinit var usageStatsManager: UsageStatsManager
    private lateinit var powerManager: PowerManager

    /** Apps whose block screen is being put up right now (home → overlay). */
    private val currentlyBlockedApps = mutableSetOf<String>()

    /**
     * When each app was last shown the mindful pause. Every fresh open gets a
     * pause; this only absorbs the duplicate window events one launch can
     * fire. Coming back from the pause itself is not a fresh open (our
     * overlay never changes [lastPackageName]), so it is not paused again.
     */
    private val lastPauseAt = mutableMapOf<String, Long>()
    private val pauseDedupMs = 3_000L

    /** Today's foreground time is costly to rebuild, so it is reused briefly. */
    private val usageCache = mutableMapOf<String, Pair<Long, Int>>()
    private val usageCacheMs = 10_000L

    /**
     * Periodic re-check of whatever app is in front. Window events alone are
     * not enough: a daily limit or a time block can be reached while the user
     * stays on one screen, and a blocked app can come back to the front (e.g.
     * a second tap on its icon closes the block screen) without any event
     * that looks like a new launch.
     */
    private val handler = Handler(Looper.getMainLooper())
    private val watchdogIntervalMs = 3_000L
    private val watchdog = object : Runnable {
        override fun run() {
            try {
                if (powerManager.isInteractive) {
                    foregroundPackage()?.let { pkg ->
                        if (isMonitorable(pkg)) enforceHardLimits(pkg)
                    }
                }
            } catch (e: Exception) {
                Log.e(TAG, "Watchdog check failed", e)
            }
            handler.postDelayed(this, watchdogIntervalMs)
        }
    }

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

        /** How far back to look for the app currently in front. */
        private const val FOREGROUND_LOOKBACK_MS = 10 * 60_000L

        /** Lets the activity switch settle before reading the foreground app. */
        private const val OVERLAY_RECHECK_DELAY_MS = 400L

        /** Grace period for usage stats to record a launch we just saw. */
        private const val BACKGROUND_EVENT_RECHECK_MS = 700L
    }

    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "AppMonitoringService created")
        flutterPreferences = getSharedPreferences(FLUTTER_PREFS, Context.MODE_PRIVATE)
        blockerPreferences = getSharedPreferences(BLOCKER_PREFS_NAME, Context.MODE_PRIVATE)
        usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
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

        handler.removeCallbacks(watchdog)
        handler.postDelayed(watchdog, watchdogIntervalMs)

        BlockingOverlayActivity.onHidden = { pkg ->
            handler.postDelayed({ recheckAfterOverlay(pkg) }, OVERLAY_RECHECK_DELAY_MS)
        }
    }

    /**
     * The block screen for [packageName] just went away. If that is because
     * the app is back in front (rather than the user going home), block again
     * now instead of waiting for the next watchdog tick.
     */
    private fun recheckAfterOverlay(packageName: String) {
        try {
            currentlyBlockedApps.remove(packageName)
            if (foregroundPackage() == packageName) enforceHardLimits(packageName)
        } catch (e: Exception) {
            Log.e(TAG, "Re-check after overlay failed", e)
        }
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null) return

        if (event.eventType == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
            event.packageName?.toString()?.let { packageName ->
                // Our own screens (including the pause overlay) and system chrome
                // must never count as an app launch.
                if (!isMonitorable(packageName)) return

                // Apps also fire window events from the background (a cold
                // start finishing its splash after we sent the user home is a
                // common one). Act only once the app is really in front.
                val front = foregroundPackage()
                if (front == null || front == packageName) {
                    handleAppSwitch(packageName)
                } else {
                    handler.postDelayed({
                        if (foregroundPackage() == packageName) handleAppSwitch(packageName)
                        else Log.d(TAG, "Ignoring background window event from $packageName")
                    }, BACKGROUND_EVENT_RECHECK_MS)
                }
            }
        }
    }

    private fun isMonitorable(packageName: String): Boolean =
        packageName != this.packageName &&
            packageName != "com.android.systemui" &&
            packageName != "android"

    private fun handleAppSwitch(packageName: String) {
        if (lastPackageName != packageName) {
            lastPackageName = packageName

            // Window events from an app that is being blocked right now are
            // not the user opening it again.
            if (isBlockInFlight(packageName)) return

            rollOverCountsIfNewDay()
            val count = openCountsToday.getOrDefault(packageName, 0) + 1
            openCountsToday[packageName] = count
            saveOpenCounts()

            Log.d(TAG, "App launched: $packageName (opens today: $count)")

            checkAndBlockApp(packageName)
        } else {
            // Still the same app (or it came back from behind our block
            // screen): re-apply the hard rules without counting an open.
            enforceHardLimits(packageName)
        }
    }

    /** A fresh launch: hard rules first, then the mindful pause. */
    private fun checkAndBlockApp(packageName: String) {
        if (isBlockInFlight(packageName)) return
        if (enforceHardLimits(packageName)) return

        val limit = findLimit(packageName) ?: return
        if (limit.protectionType != "delayOpening" || limit.delaySeconds <= 0) return
        if (!isActiveToday(limit)) {
            Log.d(TAG, "${limit.packageName}: protection not active today")
            return
        }

        val now = System.currentTimeMillis()
        val lastPause = lastPauseAt[packageName] ?: 0L
        if (now - lastPause > pauseDedupMs) {
            lastPauseAt[packageName] = now
            showPause(packageName, limit)
        }
    }

    /**
     * Blocks [packageName] if a hard rule (detox list, opening limit, time
     * block, daily limit) says it must not be used right now. Safe to call
     * repeatedly: it does nothing while a block screen for the app is already
     * up. Returns `true` when the app is (being) blocked.
     */
    private fun enforceHardLimits(packageName: String): Boolean {
        if (isBlockInFlight(packageName)) return true

        // Detox / instant block list wins over every configured limit.
        if (blockedApps.contains(packageName)) {
            Log.d(TAG, "Blocking $packageName - in instant block list")
            blockApp(packageName) {
                putExtra(BlockingOverlayActivity.EXTRA_BLOCK_TYPE, BlockingOverlayActivity.TYPE_INSTANT)
            }
            return true
        }

        val limit = findLimit(packageName) ?: return false
        if (!isActiveToday(limit)) return false

        when (limit.protectionType) {
            "maxOpens" -> {
                rollOverCountsIfNewDay()
                val opens = openCountsToday.getOrDefault(packageName, 0)
                if (limit.maxDailyOpens > 0 && opens > limit.maxDailyOpens) {
                    Log.d(TAG, "Blocking $packageName - opens $opens > ${limit.maxDailyOpens}")
                    blockApp(packageName, limit) {
                        putExtra(BlockingOverlayActivity.EXTRA_BLOCK_TYPE, BlockingOverlayActivity.TYPE_OPENS)
                        putExtra(BlockingOverlayActivity.EXTRA_MAX_OPENS, limit.maxDailyOpens)
                    }
                    return true
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
                    return true
                }
            }

            "delayOpening" -> Unit

            else -> {
                if (limit.maxSessionDurationMinutes <= 0) return false
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
                    return true
                }
            }
        }
        return false
    }

    /**
     * `true` while the block screen for [packageName] is being started or is
     * actually on screen. Once it is gone (closed, or pushed away by the app
     * coming back) the app is blocked again on the next check.
     */
    private fun isBlockInFlight(packageName: String): Boolean =
        currentlyBlockedApps.contains(packageName) ||
            BlockingOverlayActivity.visiblePackage == packageName

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
            currentlyBlockedApps.add(packageName)
            Log.d(TAG, "Blocking app: $packageName")

            val homeIntent = Intent(Intent.ACTION_MAIN).apply {
                addCategory(Intent.CATEGORY_HOME)
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            startActivity(homeIntent)

            handler.postDelayed({
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

                    // By now the overlay reports itself through visiblePackage.
                    handler.postDelayed({
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
                // A protection switched off in the app must not block. Older
                // entries have no flag (or null) and count as on.
                if (!obj.optBoolean("isActive", true)) continue
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
            usageCache.clear()
            saveOpenCounts()
        }
    }

    // ---------------------------------------------------------------- clocks

    /**
     * Total foreground minutes for [packageName] since midnight, including
     * the session that is still running. Built from raw usage events: the
     * aggregated UsageStats totals only grow once a session ends, so a user
     * who stays in the app would never reach the limit.
     */
    private fun todayForegroundMinutes(packageName: String): Int {
        val now = System.currentTimeMillis()
        usageCache[packageName]?.let { (at, minutes) ->
            if (now - at < usageCacheMs) return minutes
        }

        return try {
            val start = Calendar.getInstance().apply {
                set(Calendar.HOUR_OF_DAY, 0)
                set(Calendar.MINUTE, 0)
                set(Calendar.SECOND, 0)
                set(Calendar.MILLISECOND, 0)
            }.timeInMillis

            val events = usageStatsManager.queryEvents(start, now)
            val event = UsageEvents.Event()
            // Activities of the app that are currently resumed; the app is in
            // front while this is non-empty.
            val resumed = mutableSetOf<String>()
            var since = -1L
            var total = 0L
            var sawAny = false

            while (events.hasNextEvent()) {
                events.getNextEvent(event)
                if (event.packageName != packageName) continue
                val cls = event.className ?: ""
                when (event.eventType) {
                    UsageEvents.Event.ACTIVITY_RESUMED -> {
                        if (resumed.isEmpty()) since = event.timeStamp
                        resumed.add(cls)
                        sawAny = true
                    }
                    UsageEvents.Event.ACTIVITY_PAUSED,
                    UsageEvents.Event.ACTIVITY_STOPPED -> {
                        if (!sawAny) {
                            // Already in front at midnight.
                            total += event.timeStamp - start
                            sawAny = true
                        } else if (resumed.remove(cls) && resumed.isEmpty() && since >= 0) {
                            total += event.timeStamp - since
                            since = -1L
                        }
                    }
                }
            }
            if (resumed.isNotEmpty() && since >= 0) total += now - since

            val minutes = (total / 60_000L).toInt()
            usageCache[packageName] = now to minutes
            minutes
        } catch (e: Exception) {
            Log.e(TAG, "Error reading usage for $packageName", e)
            0
        }
    }

    /**
     * The app currently in front, from the last few minutes of usage events;
     * `null` when nothing is in front (screen locked, app closed). Falls back
     * to the last window event when the app has been open longer than the
     * look-back window.
     */
    private fun foregroundPackage(): String? {
        return try {
            val now = System.currentTimeMillis()
            val events = usageStatsManager.queryEvents(now - FOREGROUND_LOOKBACK_MS, now)
            val event = UsageEvents.Event()
            var top: String? = null
            var topClass: String? = null
            var sawAny = false
            while (events.hasNextEvent()) {
                events.getNextEvent(event)
                when (event.eventType) {
                    UsageEvents.Event.ACTIVITY_RESUMED -> {
                        top = event.packageName
                        topClass = event.className
                        sawAny = true
                    }
                    UsageEvents.Event.ACTIVITY_PAUSED,
                    UsageEvents.Event.ACTIVITY_STOPPED -> {
                        // Only the activity that was on top leaving clears it;
                        // the previous app stopping late must not.
                        if (event.packageName == top && event.className == topClass) top = null
                        sawAny = true
                    }
                }
            }
            if (sawAny) top else lastPackageName
        } catch (e: Exception) {
            Log.e(TAG, "Error reading foreground app", e)
            lastPackageName
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
        handler.removeCallbacksAndMessages(null)
        BlockingOverlayActivity.onHidden = null
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
