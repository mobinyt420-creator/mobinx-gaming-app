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

  // 1. Completely disable HTTP runtime font downloads (forces instant 0ms offline bundled fonts)
  GoogleFonts.config.allowRuntimeFetching = false;

  // 2. Fast local disk session init (<5ms)
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

  // 3. Launch UI immediately for instant cold-start (<50ms)
  runApp(const MobinXApp());

  // 4. Initialize Firebase, Notifications, and Cloud Services concurrently without blocking first frame
  _initBackgroundServices();
}

void _initBackgroundServices() async {
  try {
    await FirebaseService.init().timeout(const Duration(seconds: 3));
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  } catch (e) {
    debugPrint('Firebase init notice: $e');
  }

  try {
    NotificationService.instance.init();
  } catch (e) {
    debugPrint('Notification init notice: $e');
  }

  try {
    AuthService.instance.init();
  } catch (e) {
    debugPrint('Auth init notice: $e');
  }

  try {
    AdMobService.instance.init();
  } catch (e) {
    debugPrint('AdMob init notice: $e');
  }
}

class MobinXApp extends StatelessWidget {
  const MobinXApp({super.key});

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
