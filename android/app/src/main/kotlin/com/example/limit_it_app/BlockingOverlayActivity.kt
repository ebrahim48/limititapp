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
        // Main container
        val mainLayout = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setBackgroundColor(Color.parseColor("#F6F6F6"))
            gravity = Gravity.CENTER
            setPadding(40, 40, 40, 40)
            layoutParams = ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT
            )
        }

        // Icon
        val iconView = ImageView(this).apply {
            setImageResource(android.R.drawable.ic_dialog_info)
            layoutParams = LinearLayout.LayoutParams(
                200,
                200
            ).apply {
                gravity = Gravity.CENTER_HORIZONTAL
                setMargins(0, 0, 0, 40)
            }
        }

        // Title
        val titleView = TextView(this).apply {
            text = title
            textSize = 24f
            setTextColor(Color.parseColor("#2C2C2C"))
            gravity = Gravity.CENTER
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            ).apply {
                setMargins(0, 0, 0, 20)
            }
        }

        // Message
        val messageView = TextView(this).apply {
            text = message
            textSize = 16f
            setTextColor(Color.parseColor("#5D5D5D"))
            gravity = Gravity.CENTER
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            ).apply {
                setMargins(0, 0, 0, 60)
            }
        }

        // Close button
        val closeButton = Button(this).apply {
            text = "Go Back to Home"
            textSize = 16f
            setTextColor(Color.WHITE)
            setBackgroundColor(Color.parseColor("#214432"))
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                150
            ).apply {
                setMargins(20, 20, 20, 20)
            }
            setOnClickListener {
                finish()
            }
        }

        // Add views to layout
        mainLayout.addView(iconView)
        mainLayout.addView(titleView)
        mainLayout.addView(messageView)
        mainLayout.addView(closeButton)

        setContentView(mainLayout)
    }

    override fun onBackPressed() {
        // Prevent user from going back to the blocked app
        moveTaskToBack(true)
    }

    override fun onPause() {
        super.onPause()
        // When user leaves this activity, finish it
        finish()
    }
}
