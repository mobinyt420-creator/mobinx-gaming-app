# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Flutter Local Notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-dontwarn com.dexterous.flutterlocalnotifications.**

# Google Sign-In
-keep class com.google.android.gms.auth.** { *; }

# MobinX Application
-keep class com.mobinx.gaming.** { *; }

# Google Mobile Ads
-keep class com.google.android.gms.ads.** { *; }
-dontwarn com.google.android.gms.ads.**

# URL Launcher & AndroidX Browser
-keep class androidx.browser.customtabs.** { *; }
-keep class io.flutter.plugins.urllauncher.** { *; }

# WebView Flutter
-keep class io.flutter.plugins.webviewflutter.** { *; }
-dontwarn io.flutter.plugins.webviewflutter.**

# SharedPreferences & Storage
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# Sqflite Local Database
-keep class com.tekartik.sqflite.** { *; }

# Keep annotations
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
