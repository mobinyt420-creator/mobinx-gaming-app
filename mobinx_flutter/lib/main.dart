import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'features/splash/splash_screen.dart';
import 'core/services/firebase_service.dart';
import 'core/services/storage_service.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/services/notification_service.dart';

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

  // 3. Initialize Firebase & Notification system asynchronously in background
  FirebaseService.init().then((_) {
    NotificationService.instance.init();
  }).catchError((e) {
    debugPrint('Background Firebase init: $e');
  });

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
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  } catch (_) {}

  runApp(const MobinXApp());
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
