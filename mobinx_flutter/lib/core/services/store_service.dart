import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_constants.dart';
import 'firebase_service.dart';

/// Store & Top-Up In-App Browser Service (Matching Screenshot 3)
class StoreService {
  StoreService._();
  static final StoreService instance = StoreService._();

  static const MethodChannel _customTabsChannel = MethodChannel('com.mobinx.app/custom_tabs');

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

  /// Opens the store inside an Android Chrome Custom Tab with exact brand toolbar color
  Future<bool> openStore({
    required String url,
    String? title,
    String colorHex = '#0284C7',
  }) async {
    // 1. First priority: Native Android Custom Tabs with explicit brand toolbar color
    try {
      final res = await _customTabsChannel.invokeMethod('openCustomTab', {
        'url': url,
        'color': colorHex,
      });
      if (res == true) return true;
    } catch (e) {
      debugPrint('[StoreService] Native CustomTab fallback: $e');
    }

    // 2. Fallback to inAppBrowserView
    final uri = Uri.parse(url);
    try {
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

    // 3. Fallback to external browser if needed
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  /// Top Up opens with brand Sky Blue (#0284C7)
  Future<bool> openTopUp() => openStore(
        url: _topUpUrl,
        title: 'Noob Top Up',
        colorHex: '#0284C7',
      );

  /// Shop opens with brand Warm Orange (#F97316)
  Future<bool> openShop() => openStore(
        url: _shopUrl,
        title: 'Mobin X Shop',
        colorHex: '#F97316',
      );

  Future<bool> openUrlInBrowserView(
    String url, {
    String? title,
    Color? barColor,
    String colorHex = '#0284C7',
  }) =>
      openStore(
        url: url,
        title: title,
        colorHex: barColor != null
            ? '#${barColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}'
            : colorHex,
      );
}

