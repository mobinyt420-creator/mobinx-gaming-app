import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'features/splash/splash_screen.dart';
import 'core/services/firebase_service.dart';
import 'core/services/storage_service.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'core/services/notification_service.dart';
import 'core/services/auth_service.dart';
import 'core/services/admob_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Guard global flutter errors
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('⚡ Mobin X Caught Error: ${details.exception}');
  };

  // 1. Initialize Firebase Core synchronously and register background messaging handler
  try {
    await FirebaseService.init();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  } catch (e) {
    debugPrint('Firebase init notice: $e');
  }

  // 2. Completely disable HTTP runtime font downloads (forces instant 0ms offline bundled fonts)
  GoogleFonts.config.allowRuntimeFetching = false;

  // 3. Fast local disk session init (<5ms)
  try {
    await StorageService.init();
  } catch (e) {
    debugPrint('Storage init notice: $e');
  }

  // Lock to portrait orientation for esports gaming UX
  try {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  } catch (_) {}

  // Configure transparent status bar & dark navigation bar
  try {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Color(0xFF030712),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  } catch (_) {}

  // 4. Launch UI
  runApp(const ObinApp());

  // 5. Initialize secondary runtime services
  _initSecondaryServices();
}

void _initSecondaryServices() async {
  try {
    await NotificationService.instance.init();
  } catch (e) {
    debugPrint('Notification init notice: $e');
  }

  try {
    await AuthService.instance.init();
  } catch (e) {
    debugPrint('Auth init notice: $e');
  }

  try {
    await AdMobService.instance.init();
  } catch (e) {
    debugPrint('AdMob init notice: $e');
  }
}

class ObinApp extends StatelessWidget {
  const ObinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
      home: const SplashScreen(),
    );
  }
}
