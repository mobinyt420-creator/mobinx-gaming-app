package com.mobinx.gaming

import android.graphics.Color
import android.net.Uri
import androidx.browser.customtabs.CustomTabColorSchemeParams
import androidx.browser.customtabs.CustomTabsIntent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.mobinx.app/custom_tabs"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "openCustomTab") {
                val url = call.argument<String>("url")
                val colorHex = call.argument<String>("color") ?: "#004F9F"
                if (url != null) {
                    try {
                        val parsedColor = Color.parseColor(colorHex)
                        val colorSchemeParams = CustomTabColorSchemeParams.Builder()
                            .setToolbarColor(parsedColor)
                            .setNavigationBarColor(parsedColor)
                            .build()

                        val builder = CustomTabsIntent.Builder()
                            .setDefaultColorSchemeParams(colorSchemeParams)
                            .setShowTitle(true)
                            .setUrlBarHidingEnabled(false)
                            .setShareState(CustomTabsIntent.SHARE_STATE_ON)

                        try {
                            val displayMetrics = resources.displayMetrics
                            val initialHeight = (displayMetrics.heightPixels * 0.92).toInt()
                            builder.setInitialActivityHeightPx(initialHeight, CustomTabsIntent.ACTIVITY_HEIGHT_DEFAULT)
                            builder.setToolbarCornerRadiusDp(16)
                        } catch (_: Exception) {}

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
