package com.example.limit_it_app

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.limit_it_app/app_blocker"
    private val REQUEST_OVERLAY_PERMISSION = 1234
    private val REQUEST_ACCESSIBILITY_PERMISSION = 1235

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startMonitoring" -> {
                    startMonitoringService()
                    result.success(true)
                }
                "stopMonitoring" -> {
                    stopMonitoringService()
                    result.success(true)
                }
                "hasOverlayPermission" -> {
                    result.success(hasOverlayPermission())
                }
                "requestOverlayPermission" -> {
                    requestOverlayPermission()
                    result.success(true)
                }
                "hasAccessibilityPermission" -> {
                    result.success(isAccessibilityServiceEnabled())
                }
                "requestAccessibilityPermission" -> {
                    requestAccessibilityPermission()
                    result.success(true)
                }
                "isMonitoringActive" -> {
                    result.success(AppMonitoringService.isServiceRunning)
                }
                "updateBlockedApps" -> {
                    val blockedApps = call.argument<List<String>>("blockedApps")
                    if (blockedApps != null) {
                        updateBlockedApps(blockedApps)
                        result.success(true)
                    } else {
                        result.error("INVALID_ARGUMENT", "Blocked apps list is required", null)
                    }
                }
                "getBlockedApps" -> {
                    result.success(getBlockedApps())
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun updateBlockedApps(blockedPackageNames: List<String>) {
        // Store blocked apps in SharedPreferences
        val prefs = getSharedPreferences("app_blocker_prefs", MODE_PRIVATE)
        prefs.edit().putStringSet("blocked_apps", blockedPackageNames.toSet()).apply()

        // If monitoring service is running, update it
        if (AppMonitoringService.isServiceRunning) {
            val intent = Intent(this, AppMonitoringService::class.java)
            intent.action = "UPDATE_BLOCKED_APPS"
            intent.putStringArrayListExtra("blocked_apps", ArrayList(blockedPackageNames))
            startService(intent)
        }
    }

    private fun getBlockedApps(): List<String> {
        val prefs = getSharedPreferences("app_blocker_prefs", MODE_PRIVATE)
        return prefs.getStringSet("blocked_apps", emptySet())?.toList() ?: emptyList()
    }

    private fun startMonitoringService() {
        // Start foreground service
        AppMonitoringForegroundService.startService(this)
    }

    private fun stopMonitoringService() {
        AppMonitoringForegroundService.stopService(this)
    }

    private fun hasOverlayPermission(): Boolean {
        val hasPermission = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            Settings.canDrawOverlays(this)
        } else {
            true
        }
        android.util.Log.d("PermissionCheck", "Overlay permission: $hasPermission")
        return hasPermission
    }

    private fun requestOverlayPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val intent = Intent(
                Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                Uri.parse("package:$packageName")
            )
            startActivityForResult(intent, REQUEST_OVERLAY_PERMISSION)
        }
    }

    private fun isAccessibilityServiceEnabled(): Boolean {
        val accessibilityEnabled = try {
            Settings.Secure.getInt(
                contentResolver,
                Settings.Secure.ACCESSIBILITY_ENABLED
            )
        } catch (e: Settings.SettingNotFoundException) {
            0
        }

        var isEnabled = false
        if (accessibilityEnabled == 1) {
            val services = Settings.Secure.getString(
                contentResolver,
                Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
            )
            isEnabled = services?.contains(packageName) == true
        }
        
        android.util.Log.d("PermissionCheck", "Accessibility permission: $isEnabled")
        return isEnabled
    }

    private fun requestAccessibilityPermission() {
        val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
        startActivityForResult(intent, REQUEST_ACCESSIBILITY_PERMISSION)
    }
}
