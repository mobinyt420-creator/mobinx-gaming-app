package com.mobinx.gaming

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.graphics.Color
import android.media.AudioAttributes
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import androidx.browser.customtabs.CustomTabColorSchemeParams
import androidx.browser.customtabs.CustomTabsIntent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.mobinx.app/custom_tabs"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        createNotificationChannels()
    }

    private fun createNotificationChannels() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

            // 1. High Importance Channel matching FCM v1 payload
            val highChannelId = "mobinx_high_importance_channel"
            val highChannelName = "OBIN Official Alerts"
            val highChannelDesc = "Real-time push notifications for OBIN Super App orders, top-ups, tournaments and deals"
            val highChannel = NotificationChannel(
                highChannelId,
                highChannelName,
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = highChannelDesc
                enableLights(true)
                lightColor = Color.parseColor("#1482FF")
                enableVibration(true)
                vibrationPattern = longArrayOf(0, 250, 250, 250)
                lockscreenVisibility = Notification.VISIBILITY_PUBLIC
                val soundUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
                val audioAttributes = AudioAttributes.Builder()
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .setUsage(AudioAttributes.USAGE_NOTIFICATION)
                    .build()
                setSound(soundUri, audioAttributes)
            }
            notificationManager.createNotificationChannel(highChannel)

            // 2. Secondary Channel
            val secChannelId = "obin_official_push_channel"
            val secChannel = NotificationChannel(
                secChannelId,
                "OBIN Push Channel",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Instant status bar alerts for all users"
                enableLights(true)
                lightColor = Color.parseColor("#1482FF")
                enableVibration(true)
            }
            notificationManager.createNotificationChannel(secChannel)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "openCustomTab") {
                val url = call.argument<String>("url")
                val colorHex = call.argument<String>("color") ?: "#1482FF"
                if (url != null) {
                    try {
                        val parsedColor = Color.parseColor(colorHex)
                        val colorSchemeParams = CustomTabColorSchemeParams.Builder()
                            .setToolbarColor(parsedColor)
                            .setNavigationBarColor(parsedColor)
                            .build()

                        val builder = CustomTabsIntent.Builder()
                            .setDefaultColorSchemeParams(colorSchemeParams)
                            .setColorSchemeParams(CustomTabsIntent.COLOR_SCHEME_LIGHT, colorSchemeParams)
                            .setColorSchemeParams(CustomTabsIntent.COLOR_SCHEME_DARK, colorSchemeParams)
                            .setShowTitle(true)
                            .setUrlBarHidingEnabled(false)
                            .setShareState(CustomTabsIntent.SHARE_STATE_ON)

                        val customTabsIntent = builder.build()
                        customTabsIntent.launchUrl(this, Uri.parse(url))
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("ERROR", e.message, null)
                    }
                } else {
                    result.error("INVALID_URL", "URL cannot be null", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
