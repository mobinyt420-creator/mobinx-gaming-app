import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_constants.dart';
import 'firebase_service.dart';

/// Store & Top-Up In-App Browser Service (Matching Screenshot 3)
class StoreService {
  StoreService._();
  static final StoreService instance = StoreService._();

  String _topUpUrl = AppConstants.topUpPartnerUrl;
  String _shopUrl = 'https://www.obinshop.com/';

  String get topUpUrl => _topUpUrl;
  String get shopUrl => _shopUrl;

  Future<void> init() async {
    try {
      if (FirebaseService.isInitialized) {
        final doc = await FirebaseService.firestore
            .collection('config')
            .doc('urls')
            .get()
            .timeout(const Duration(seconds: 4));

        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          if (data['topup'] != null && data['topup'].toString().isNotEmpty) {
            _topUpUrl = data['topup'].toString();
          }
          if (data['shop'] != null && data['shop'].toString().isNotEmpty) {
            _shopUrl = data['shop'].toString();
          }
        }
      }
    } catch (e) {
      debugPrint('[StoreService] URL sync notice: $e');
    }
  }

  /// Opens the store inside an Android Chrome Custom Tab / In-App Browser (Image 3)
  /// Guaranteed compatibility with bKash/Nagad payments and Google Sign-In
  Future<bool> openStore({
    required String url,
    String? title,
  }) async {
    final uri = Uri.parse(url);
    try {
      // Launch in in-app browser view (Chrome Custom Tab)
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.inAppBrowserView,
        browserConfiguration: const BrowserConfiguration(
          showTitle: true,
        ),
      );
      if (launched) return true;
    } catch (e) {
      debugPrint('[StoreService] inAppBrowserView failed: $e');
    }

    // Fallback to external browser if needed
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  Future<bool> openTopUp() => openStore(url: _topUpUrl, title: 'Noob Top Up');
  Future<bool> openShop() => openStore(url: _shopUrl, title: 'Mobin X Shop');

  Future<bool> openUrlInBrowserView(
    String url, {
    String? title,
    Color? barColor,
  }) =>
      openStore(url: url, title: title);
}
