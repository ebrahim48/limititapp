package com.limitit.digitalbalance

import android.animation.ValueAnimator
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.res.ColorStateList
import android.content.res.Configuration
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.RectF
import android.graphics.Typeface
import android.graphics.drawable.Drawable
import android.graphics.drawable.GradientDrawable
import android.os.Build
import android.os.Bundle
import android.os.CountDownTimer
import android.util.Log
import android.util.TypedValue
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.view.WindowManager
import android.view.animation.LinearInterpolator
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.ProgressBar
import android.widget.ScrollView
import android.widget.TextView
import com.google.android.gms.ads.AdListener
import com.google.android.gms.ads.AdRequest
import com.google.android.gms.ads.AdSize
import com.google.android.gms.ads.AdView
import com.google.android.gms.ads.LoadAdError
import com.google.android.gms.ads.MobileAds
import java.util.Calendar
import java.util.Locale

/**
 * Full-screen screen shown on top of a protected app. One of five states,
 * picked by [EXTRA_BLOCK_TYPE]:
 *
 *  - [TYPE_DELAY] (mindful pause) — the app is still alive behind this
 *    activity. A countdown runs and then finishes the overlay, letting the
 *    user through; the button instead takes them home.
 *  - [TYPE_OPENS], [TYPE_TIME], [TYPE_SCHEDULE], [TYPE_INSTANT] (hard block) —
 *    the caller already pushed the user home, so the button just dismisses
 *    this screen.
 *
 * Every number comes from the intent ([AppMonitoringService] fills it from the
 * live limits/usage); text is localized from the language picked in Flutter.
 * Free users get a small banner ad; Premium users never see one.
 */
class BlockingOverlayActivity : Activity() {

    companion object {
        private const val TAG = "BlockingOverlay"

        const val EXTRA_PACKAGE = "packageName"
        const val EXTRA_APP_NAME = "appName"
        const val EXTRA_CUSTOM_MESSAGE = "customMessage"
        const val EXTRA_BLOCK_TYPE = "blockType"
        const val EXTRA_DELAY_SECONDS = "delaySeconds"
        const val EXTRA_MAX_OPENS = "maxOpens"
        const val EXTRA_USED_MINUTES = "usedMinutes"
        const val EXTRA_LIMIT_MINUTES = "limitMinutes"
        const val EXTRA_SCHEDULE_START = "scheduleStart"
        const val EXTRA_SCHEDULE_END = "scheduleEnd"

        const val TYPE_DELAY = "delay"
        const val TYPE_OPENS = "opens"
        const val TYPE_TIME = "time"
        const val TYPE_SCHEDULE = "schedule"
        const val TYPE_INSTANT = "instant"

        /** Same file/keys Flutter's shared_preferences writes. */
        private const val FLUTTER_PREFS = "FlutterSharedPreferences"
        private const val KEY_LANGUAGE = "flutter.language_code"
        private const val KEY_IS_PREMIUM = "flutter.premium_is_active"

        // TODO(release): replace with the real AdMob banner unit ID. This is
        // Google's public test unit.
        private const val BANNER_AD_UNIT_ID = "ca-app-pub-3940256099942544/6300978111"

        // LimitIt palette (lib/core/constants/app_colors.dart).
        private val INK = Color.parseColor("#1A1A1A")
        private val SLATE_GREEN = Color.parseColor("#5A6B55")
        private val LEAF_GREEN = Color.parseColor("#5FA330")
        private val FOREST_GREEN = Color.parseColor("#2C5E1A")
        private val FOG = Color.parseColor("#F7F8F6")
        private val HAZE = Color.parseColor("#E6E9E4")
        private val ALERT_RED = Color.parseColor("#E8443A")
    }

    private var countDownTimer: CountDownTimer? = null
    private var ringAnimator: ValueAnimator? = null
    private var adView: AdView? = null
    private val fonts = mutableMapOf<String, Typeface>()

    /** Render the blocking text in the language chosen inside the app. */
    override fun attachBaseContext(newBase: Context) {
        val code = newBase.getSharedPreferences(FLUTTER_PREFS, Context.MODE_PRIVATE)
            .getString(KEY_LANGUAGE, null) ?: "it"
        val config = Configuration(newBase.resources.configuration)
        config.setLocale(Locale(code))
        super.attachBaseContext(newBase.createConfigurationContext(config))
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Make this activity appear on top of everything
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        window.addFlags(WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD)
        window.addFlags(WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED)
        window.addFlags(WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON)
        window.statusBarColor = Color.WHITE
        window.navigationBarColor = Color.WHITE
        @Suppress("DEPRECATION")
        window.decorView.systemUiVisibility =
            View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR or
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    View.SYSTEM_UI_FLAG_LIGHT_NAVIGATION_BAR
                } else {
                    0
                }

        render()
    }

    override fun onNewIntent(intent: Intent?) {
        super.onNewIntent(intent)
        setIntent(intent)
        render()
    }

    // ------------------------------------------------------------------ UI

    private fun render() {
        stopTimers()
        adView?.destroy()
        adView = null

        val packageName = intent.getStringExtra(EXTRA_PACKAGE) ?: ""
        val type = intent.getStringExtra(EXTRA_BLOCK_TYPE) ?: TYPE_INSTANT
        val appName = intent.getStringExtra(EXTRA_APP_NAME)
            ?.takeIf { it.isNotBlank() }
            ?: appLabel(packageName)
        val delaySeconds = intent.getIntExtra(EXTRA_DELAY_SECONDS, 0)
        val isPause = type == TYPE_DELAY && delaySeconds > 0

        val root = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setBackgroundColor(Color.WHITE)
            setPadding(dp(20), dp(16), dp(20), dp(20))
        }

        // --- Scrollable content -------------------------------------------
        val content = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER_HORIZONTAL
        }

        content.addView(brandHeader(), matchWrap())
        content.addView(appHeader(packageName, appName), matchWrap(top = 20))

        val title: String
        val subtitle: String
        val defaultQuote: Int
        var detail: View? = null

        when (type) {
            TYPE_DELAY -> {
                title = getString(R.string.block_title_delay)
                subtitle = getString(R.string.block_subtitle_delay, appName)
                defaultQuote = R.string.block_q_delay
            }

            TYPE_OPENS -> {
                val max = intent.getIntExtra(EXTRA_MAX_OPENS, 0)
                title = getString(R.string.block_title_opens)
                subtitle = resources.getQuantityString(R.plurals.block_subtitle_opens, max, appName, max)
                defaultQuote = R.string.block_q_opens
                detail = usageCard(
                    icon = R.drawable.ic_block_bar_chart,
                    label = getString(R.string.block_opens_label),
                    value = resources.getQuantityString(R.plurals.block_openings, max, max),
                    used = "$max/$max",
                    progress = 1f
                )
            }

            TYPE_TIME -> {
                val used = intent.getIntExtra(EXTRA_USED_MINUTES, 0)
                val limit = intent.getIntExtra(EXTRA_LIMIT_MINUTES, 0)
                title = getString(R.string.block_title_time)
                subtitle = getString(R.string.block_subtitle_time, durationLabel(used))
                defaultQuote = R.string.block_q_time
                detail = usageCard(
                    icon = R.drawable.ic_block_clock,
                    label = getString(R.string.block_time_label),
                    value = durationLabel(limit),
                    used = compactDuration(used),
                    progress = if (limit > 0) (used.toFloat() / limit).coerceAtMost(1f) else 1f
                )
            }

            TYPE_SCHEDULE -> {
                val start = intent.getStringExtra(EXTRA_SCHEDULE_START)
                val end = intent.getStringExtra(EXTRA_SCHEDULE_END)
                title = getString(R.string.block_title_schedule)
                subtitle = getString(R.string.block_subtitle_schedule, appName)
                defaultQuote = R.string.block_q_schedule
                val endLabel = clockLabel(end)
                val startLabel = clockLabel(start)
                if (endLabel != null && startLabel != null) {
                    detail = scheduleCard(endLabel, "$startLabel – $endLabel")
                }
            }

            else -> {
                title = getString(R.string.block_title_schedule)
                subtitle = getString(R.string.block_subtitle_instant, appName)
                defaultQuote = R.string.block_q_schedule
            }
        }

        content.addView(text(title, 26f, INK, "Bold").apply {
            gravity = Gravity.CENTER
            setLineSpacing(0f, 1.1f)
        }, matchWrap(top = 20))
        content.addView(text(subtitle, 15f, SLATE_GREEN, "Regular").apply {
            gravity = Gravity.CENTER
            setLineSpacing(0f, 1.25f)
        }, matchWrap(top = 8))

        var countdownNumber: TextView? = null
        var ring: RingView? = null
        if (isPause) {
            val (ringView, number) = countdownRing(delaySeconds)
            ring = ringView
            countdownNumber = number
            content.addView(
                ringView.parent as View,
                LinearLayout.LayoutParams(dp(180), dp(180)).apply { topMargin = dp(20) }
            )
        }

        detail?.let { content.addView(it, matchWrap(top = 20)) }

        val customMessage = intent.getStringExtra(EXTRA_CUSTOM_MESSAGE)?.trim()
        val quote = if (!customMessage.isNullOrEmpty()) customMessage else getString(defaultQuote)
        content.addView(quoteCard(quote), matchWrap(top = 16))

        val scroll = ScrollView(this).apply {
            isFillViewport = true
            isVerticalScrollBarEnabled = false
            addView(content, ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            ))
        }
        root.addView(scroll, LinearLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT, 0, 1f
        ))

        // --- Pinned bottom: ad (Free only) + action button ------------------
        if (!isPremium()) root.addView(bannerAd(), matchWrap(top = 12))

        val button = if (isPause) {
            actionButton(getString(R.string.block_cancel), filled = false)
        } else {
            actionButton(getString(R.string.block_got_it), filled = true)
        }
        button.setOnClickListener {
            // In pause mode the protected app is still behind us, so
            // finishing alone would hand it right back.
            if (isPause) goHome()
            finish()
        }
        root.addView(button, LinearLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT, dp(54)
        ).apply { topMargin = dp(12) })

        setContentView(root)

        if (isPause) startCountdown(delaySeconds, ring!!, countdownNumber!!)
    }

    /** "LimitIt" + leaf, as in the app's brand bar. */
    private fun brandHeader(): View = LinearLayout(this).apply {
        orientation = LinearLayout.HORIZONTAL
        gravity = Gravity.CENTER_VERTICAL
        addView(text("LimitIt", 20f, FOREST_GREEN, "Bold"))
        addView(ImageView(context).apply {
            setImageResource(R.drawable.ic_block_leaf)
            imageTintList = ColorStateList.valueOf(LEAF_GREEN)
            rotation = 30f
        }, LinearLayout.LayoutParams(dp(18), dp(18)).apply { marginStart = dp(4) })
    }

    private fun appHeader(packageName: String, appName: String): View =
        LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER_HORIZONTAL
            appIcon(packageName)?.let { icon ->
                addView(ImageView(context).apply { setImageDrawable(icon) },
                    LinearLayout.LayoutParams(dp(64), dp(64)))
            }
            addView(text(appName, 16f, INK, "SemiBold").apply {
                gravity = Gravity.CENTER
            }, matchWrap(top = 8))
        }

    /** Countdown ring; returns the ring and the number inside it. */
    private fun countdownRing(seconds: Int): Pair<RingView, TextView> {
        val frame = FrameLayout(this)
        val ring = RingView(this, dp(10).toFloat(), HAZE, LEAF_GREEN)
        frame.addView(ring, FrameLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT
        ))

        val number = text("$seconds", 52f, INK, "Bold").apply {
            gravity = Gravity.CENTER
            includeFontPadding = false
        }
        val center = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            addView(number)
            addView(text(getString(R.string.block_seconds), 15f, SLATE_GREEN, "Regular"))
        }
        frame.addView(center, FrameLayout.LayoutParams(
            ViewGroup.LayoutParams.WRAP_CONTENT,
            ViewGroup.LayoutParams.WRAP_CONTENT,
            Gravity.CENTER
        ))
        return ring to number
    }

    /** Daily-limit / daily-time card: icon, limit, red "Used" and a full bar. */
    private fun usageCard(icon: Int, label: String, value: String, used: String, progress: Float): View =
        card().apply {
            val row = LinearLayout(context).apply {
                orientation = LinearLayout.HORIZONTAL
                gravity = Gravity.CENTER_VERTICAL
            }
            row.addView(tintedIcon(icon, LEAF_GREEN), LinearLayout.LayoutParams(dp(26), dp(26)))

            val labels = LinearLayout(context).apply {
                orientation = LinearLayout.VERTICAL
                addView(text(label, 13f, SLATE_GREEN, "Regular"))
                addView(text(value, 16f, INK, "SemiBold"))
            }
            row.addView(labels, LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f)
                .apply { marginStart = dp(14) })

            val usedCol = LinearLayout(context).apply {
                orientation = LinearLayout.VERTICAL
                gravity = Gravity.END
                addView(text(getString(R.string.block_used), 13f, SLATE_GREEN, "Regular"))
                addView(text(used, 17f, ALERT_RED, "SemiBold"))
            }
            row.addView(usedCol)
            addView(row)

            val bar = ProgressBar(context, null, android.R.attr.progressBarStyleHorizontal).apply {
                max = 1000
                this.progress = (progress * 1000).toInt()
                progressDrawable = progressDrawable()
            }
            addView(bar, LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, dp(8)
            ).apply { topMargin = dp(16) })
        }

    /** Time-block card: "Blocked until 5:00 PM" and the active window. */
    private fun scheduleCard(until: String, window: String): View = card().apply {
        val row = LinearLayout(context).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.TOP
        }
        row.addView(tintedIcon(R.drawable.ic_block_calendar, ALERT_RED),
            LinearLayout.LayoutParams(dp(30), dp(30)).apply { topMargin = dp(2) })

        val col = LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            addView(text(getString(R.string.block_blocked_until), 13f, SLATE_GREEN, "Regular"))
            addView(text(until, 17f, INK, "SemiBold"))
            addView(text(getString(R.string.block_active_block), 13f, SLATE_GREEN, "Regular"),
                matchWrap(top = 10))
            addView(text(window, 14f, SLATE_GREEN, "Regular"))
        }
        row.addView(col, LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f)
            .apply { marginStart = dp(16) })
        addView(row)
    }

    private fun quoteCard(quote: String): View = card().apply {
        val row = LinearLayout(context).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.TOP
        }
        row.addView(tintedIcon(R.drawable.ic_block_quote, HAZE),
            LinearLayout.LayoutParams(dp(22), dp(22)))
        row.addView(text(quote, 14f, SLATE_GREEN, "Regular").apply {
            setLineSpacing(0f, 1.25f)
        }, LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f)
            .apply { marginStart = dp(12) })
        addView(row)
    }

    /**
     * Small AdMob banner for Free users. Stays collapsed until an ad actually
     * loads so a failed request never leaves an empty box.
     */
    private fun bannerAd(): View {
        val container = FrameLayout(this).apply {
            visibility = View.GONE
            background = rounded(Color.WHITE, 12, HAZE)
            clipToOutline = true
            setPadding(dp(1), dp(1), dp(1), dp(1))
        }
        try {
            MobileAds.initialize(this)
            val ad = AdView(this).apply {
                setAdSize(AdSize.BANNER)
                adUnitId = BANNER_AD_UNIT_ID
                adListener = object : AdListener() {
                    override fun onAdLoaded() {
                        container.visibility = View.VISIBLE
                    }

                    override fun onAdFailedToLoad(error: LoadAdError) {
                        Log.d(TAG, "Banner failed to load: ${error.message}")
                        container.visibility = View.GONE
                    }
                }
            }
            container.addView(ad, FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT,
                ViewGroup.LayoutParams.WRAP_CONTENT,
                Gravity.CENTER
            ))
            ad.loadAd(AdRequest.Builder().build())
            adView = ad
        } catch (e: Exception) {
            Log.e(TAG, "Banner setup failed", e)
        }
        return container
    }

    private fun actionButton(label: String, filled: Boolean): TextView =
        text(label, 16f, if (filled) Color.WHITE else INK, "SemiBold").apply {
            gravity = Gravity.CENTER
            background = if (filled) rounded(LEAF_GREEN, 28) else rounded(Color.WHITE, 28, HAZE)
            isClickable = true
            isFocusable = true
        }

    // --------------------------------------------------------- countdown

    private fun startCountdown(seconds: Int, ring: RingView, number: TextView) {
        ringAnimator = ValueAnimator.ofFloat(1f, 0f).apply {
            duration = seconds * 1000L
            interpolator = LinearInterpolator()
            addUpdateListener { ring.progress = it.animatedValue as Float }
            start()
        }
        countDownTimer = object : CountDownTimer(seconds * 1000L, 1000L) {
            override fun onTick(millisUntilFinished: Long) {
                number.text = "${(millisUntilFinished / 1000) + 1}"
            }

            override fun onFinish() {
                // Pause served — drop the overlay and let the app through.
                finish()
            }
        }.start()
    }

    private fun stopTimers() {
        countDownTimer?.cancel()
        countDownTimer = null
        ringAnimator?.cancel()
        ringAnimator = null
    }

    // ----------------------------------------------------------- helpers

    private fun isPremium(): Boolean =
        getSharedPreferences(FLUTTER_PREFS, Context.MODE_PRIVATE)
            .getBoolean(KEY_IS_PREMIUM, false)

    private fun appLabel(packageName: String): String = try {
        val info = packageManager.getApplicationInfo(packageName, 0)
        packageManager.getApplicationLabel(info).toString()
    } catch (e: Exception) {
        packageName
    }

    private fun appIcon(packageName: String): Drawable? = try {
        packageManager.getApplicationIcon(packageName)
    } catch (e: Exception) {
        null
    }

    /** 60 → "1 hour", 90 → "1h 30m", 45 → "45 min". */
    private fun durationLabel(minutes: Int): String {
        val h = minutes / 60
        val m = minutes % 60
        return when {
            h == 0 -> getString(R.string.block_minutes, m)
            m == 0 -> resources.getQuantityString(R.plurals.block_hours, h, h)
            else -> "${h}h ${m}m"
        }
    }

    /** 60 → "1h 0m", 45 → "45m". */
    private fun compactDuration(minutes: Int): String =
        if (minutes >= 60) "${minutes / 60}h ${minutes % 60}m" else "${minutes}m"

    /** "17:00" → "5:00 PM" or "17:00", following the device's clock setting. */
    private fun clockLabel(time: String?): String? {
        val parts = time?.split(":") ?: return null
        if (parts.size < 2) return null
        val hour = parts[0].trim().toIntOrNull() ?: return null
        val minute = parts[1].trim().toIntOrNull() ?: return null
        val calendar = Calendar.getInstance().apply {
            set(Calendar.HOUR_OF_DAY, hour)
            set(Calendar.MINUTE, minute)
        }
        return android.text.format.DateFormat.getTimeFormat(this).format(calendar.time)
    }

    private fun card(): LinearLayout = LinearLayout(this).apply {
        orientation = LinearLayout.VERTICAL
        background = rounded(FOG, 16, HAZE)
        setPadding(dp(18), dp(16), dp(18), dp(16))
    }

    private fun tintedIcon(res: Int, color: Int): ImageView = ImageView(this).apply {
        setImageResource(res)
        imageTintList = ColorStateList.valueOf(color)
    }

    private fun progressDrawable(): Drawable {
        val track = rounded(HAZE, 4)
        val fill = android.graphics.drawable.ClipDrawable(
            rounded(ALERT_RED, 4), Gravity.START, android.graphics.drawable.ClipDrawable.HORIZONTAL
        )
        return android.graphics.drawable.LayerDrawable(arrayOf(track, fill)).apply {
            setId(0, android.R.id.background)
            setId(1, android.R.id.progress)
        }
    }

    private fun rounded(color: Int, radiusDp: Int, strokeColor: Int? = null) =
        GradientDrawable().apply {
            shape = GradientDrawable.RECTANGLE
            cornerRadius = dp(radiusDp).toFloat()
            setColor(color)
            strokeColor?.let { setStroke(dp(1), it) }
        }

    private fun text(value: String, sizeSp: Float, color: Int, weight: String) =
        TextView(this).apply {
            text = value
            setTextSize(TypedValue.COMPLEX_UNIT_SP, sizeSp)
            setTextColor(color)
            typeface = font(weight)
        }

    /** Inter, straight from the Flutter bundle, so this matches the app. */
    private fun font(weight: String): Typeface = fonts.getOrPut(weight) {
        try {
            Typeface.createFromAsset(assets, "flutter_assets/assets/fonts/Inter-$weight.ttf")
        } catch (e: Exception) {
            if (weight == "Bold" || weight == "SemiBold") Typeface.DEFAULT_BOLD else Typeface.DEFAULT
        }
    }

    private fun matchWrap(top: Int = 0) = LinearLayout.LayoutParams(
        ViewGroup.LayoutParams.MATCH_PARENT,
        ViewGroup.LayoutParams.WRAP_CONTENT
    ).apply { topMargin = dp(top) }

    private fun dp(value: Int): Int =
        (value * resources.displayMetrics.density + 0.5f).toInt()

    private fun goHome() {
        val homeIntent = Intent(Intent.ACTION_MAIN).apply {
            addCategory(Intent.CATEGORY_HOME)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        startActivity(homeIntent)
    }

    @Deprecated("Deprecated in Java")
    @Suppress("DEPRECATION")
    override fun onBackPressed() {
        // Prevent user from going back to the blocked app - do nothing
    }

    override fun onPause() {
        super.onPause()
        // When user leaves this activity, finish it
        finish()
    }

    override fun onDestroy() {
        stopTimers()
        adView?.destroy()
        adView = null
        super.onDestroy()
    }

    /** Grey track with a green arc that shrinks as the countdown runs. */
    private class RingView(
        context: Context,
        private val stroke: Float,
        trackColor: Int,
        progressColor: Int
    ) : View(context) {

        var progress = 1f
            set(value) {
                field = value
                invalidate()
            }

        private val track = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            style = Paint.Style.STROKE
            strokeWidth = stroke
            color = trackColor
        }
        private val arc = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            style = Paint.Style.STROKE
            strokeWidth = stroke
            strokeCap = Paint.Cap.ROUND
            color = progressColor
        }
        private val bounds = RectF()

        override fun onDraw(canvas: Canvas) {
            super.onDraw(canvas)
            val inset = stroke / 2
            bounds.set(inset, inset, width - inset, height - inset)
            canvas.drawOval(bounds, track)
            canvas.drawArc(bounds, -90f, 360f * progress, false, arc)
        }
    }
}
