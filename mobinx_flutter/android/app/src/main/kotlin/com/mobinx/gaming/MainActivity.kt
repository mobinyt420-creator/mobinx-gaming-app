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
                val colorHex = call.argument<String>("color") ?: "#0284C7"
                if (url != null) {
                    try {
                        val parsedColor = Color.parseColor(colorHex)
                        val colorSchemeParams = CustomTabColorSchemeParams.Builder()
                            .setToolbarColor(parsedColor)
                            .setNavigationBarColor(parsedColor)
                            .build()

                        val customTabsIntent = CustomTabsIntent.Builder()
                            .setDefaultColorSchemeParams(colorSchemeParams)
                            .setShowTitle(true)
                            .build()

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
