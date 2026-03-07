package com.example.limit_it_app

import android.app.Activity
import android.os.Bundle
import android.view.WindowManager
import android.widget.Button
import android.widget.TextView
import android.view.Gravity
import android.graphics.Color
import android.widget.LinearLayout
import android.widget.ImageView
import android.view.ViewGroup
import android.graphics.drawable.GradientDrawable
import android.graphics.Typeface
import android.widget.Space

/**
 * Full-screen overlay activity that blocks access to limited apps
 */
class BlockingOverlayActivity : Activity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Make this activity appear on top of everything
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        window.addFlags(WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD)
        window.addFlags(WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED)
        window.addFlags(WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON)

        // Get data from intent
        val packageName = intent.getStringExtra("packageName") ?: ""
        val title = intent.getStringExtra("title") ?: "App Limit Reached"
        val message = intent.getStringExtra("message") ?: "You have reached your usage limit for this app."

        // Create UI programmatically
        createBlockingUI(title, message)
    }

    private fun createBlockingUI(title: String, message: String) {
        // Main container with gradient background
        val mainLayout = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setBackgroundColor(Color.parseColor("#F6F6F6"))
            gravity = Gravity.CENTER
            setPadding(32, 48, 32, 48)
            layoutParams = ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT
            )
        }

        // LimitIt Logo - Using actual SVG logo from resources
        val logoView = ImageView(this).apply {
            // Load the LimitIt logo from drawable resources
            setImageResource(R.drawable.limitit_logo)
            layoutParams = LinearLayout.LayoutParams(
                200,
                200
            ).apply {
                gravity = Gravity.CENTER_HORIZONTAL
                setMargins(0, 0, 0, 32)
            }
            scaleType = ImageView.ScaleType.CENTER_CROP
        }

        // Title (Dynamic - from intent)
        val titleView = TextView(this).apply {
            text = title
            textSize = 22f
            setTypeface(null, Typeface.BOLD)
            setTextColor(Color.parseColor("#2C2C2C"))
            gravity = Gravity.CENTER
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            ).apply {
                setMargins(0, 0, 0, 16)
            }
        }

        // Message (Dynamic - from intent)
        val messageView = TextView(this).apply {
            text = message
            textSize = 16f
            setTypeface(null, Typeface.NORMAL)
            setTextColor(Color.parseColor("#5D5D5D"))
            gravity = Gravity.CENTER
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            ).apply {
                setMargins(32, 0, 32, 48)
            }
            setLineSpacing(0f, 1.3f)
        }

        // Close button with gradient
        val closeButton = Button(this).apply {
            text = "Go Back to Home"
            textSize = 16f
            setTypeface(null, Typeface.BOLD)
            setTextColor(Color.WHITE)
            setBackgroundDrawable(createButtonBackground())
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                160
            ).apply {
                setMargins(24, 16, 24, 16)
            }
            elevation = 8f
            setOnClickListener {
                finish()
            }
        }

        // Add views to layout
        mainLayout.addView(logoView)
        mainLayout.addView(titleView)
        mainLayout.addView(messageView)
        mainLayout.addView(closeButton)

        setContentView(mainLayout)
    }

    private fun createButtonBackground(): GradientDrawable {
        return GradientDrawable().apply {
            shape = GradientDrawable.RECTANGLE
            cornerRadius = 16f
            // Gradient from primary to darker shade
            colors = intArrayOf(
                Color.parseColor("#214432"),
                Color.parseColor("#2E4F3E")
            )
            gradientType = GradientDrawable.LINEAR_GRADIENT
        }
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

    override fun onNewIntent(intent: android.content.Intent?) {
        super.onNewIntent(intent)
        setIntent(intent)
    }
}
