import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/download_item_model.dart';
import 'firebase_service.dart';
import 'storage_service.dart';

class DownloadService {
  DownloadService._();
  static final instance = DownloadService._();

  final ValueNotifier<List<DownloadItemModel>> itemsNotifier = ValueNotifier([]);

  bool _isInit = false;

  Future<void> init() async {
    if (_isInit) return;
    _isInit = true;

    // 1. Load from local cache immediately (0ms flash, real data only)
    final cached = StorageService.getCache('mobinx_downloads_cache');
    if (cached is List && cached.isNotEmpty) {
      try {
        final list = cached
            .map((e) => DownloadItemModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        if (list.isNotEmpty) {
          itemsNotifier.value = list;
        }
      } catch (_) {}
    }

    // 2. Fetch latest live items asynchronously
    await refresh();

    // 3. Real-time Firestore stream listener
    if (FirebaseService.isInitialized) {
      try {
        FirebaseService.firestore.collection('downloads').snapshots().listen((snap) {
          final liveList = snap.docs
              .map((d) => DownloadItemModel.fromJson({...d.data(), 'id': d.id}))
              .toList();
          itemsNotifier.value = liveList;
          StorageService.setCache('mobinx_downloads_cache', liveList.map((e) => e.toJson()).toList());
        });
      } catch (_) {}
    }
  }

  Future<void> refresh() async {
    try {
      if (FirebaseService.isInitialized) {
        final snap = await FirebaseService.firestore
            .collection('downloads')
            .get()
            .timeout(const Duration(seconds: 4));

        final liveList = snap.docs
            .map((d) => DownloadItemModel.fromJson({...d.data(), 'id': d.id}))
            .toList();
        itemsNotifier.value = liveList;
        StorageService.setCache('mobinx_downloads_cache', liveList.map((e) => e.toJson()).toList());
      }
    } catch (e) {
      debugPrint('[DownloadService] refresh notice: $e');
    }
  }

  Future<bool> launchUrlString(String url) async {
    try {
      var target = url.trim();
      if (target.isEmpty) return false;
      if (!target.startsWith('http://') && !target.startsWith('https://')) {
        target = 'https://$target';
      }
      final uri = Uri.parse(target);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('[DownloadService] launch error: $e');
      return false;
    }
  }
}
