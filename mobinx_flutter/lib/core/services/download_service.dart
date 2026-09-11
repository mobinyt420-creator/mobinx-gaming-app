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

  void _setAndSortItems(List<DownloadItemModel> list) {
    list.sort((a, b) {
      if (a.isPinned != b.isPinned) {
        return a.isPinned ? -1 : 1;
      }
      if (a.order != 0 && b.order != 0) {
        return a.order.compareTo(b.order);
      }
      return b.createdAt.compareTo(a.createdAt);
    });
    itemsNotifier.value = list;
    StorageService.setCache('mobinx_downloads_cache', list.map((e) => e.toJson()).toList());
  }

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
          _setAndSortItems(list);
        }
      } catch (_) {}
    }

    // 2. Fetch latest live items asynchronously in background after initial render
    Future.delayed(const Duration(milliseconds: 1600), () {
      refresh();
      _setupFirestoreListener();
    });
  }

  void _setupFirestoreListener() {
    if (FirebaseService.isInitialized) {
      try {
        FirebaseService.firestore.collection('downloads').snapshots().listen((snap) {
          final liveList = snap.docs
              .map((d) => DownloadItemModel.fromJson({...d.data(), 'id': d.id}))
              .toList();
          _setAndSortItems(liveList);
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
        _setAndSortItems(liveList);
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
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        return await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
      return true;
    } catch (e) {
      debugPrint('[DownloadService] launch fallback: $e');
      try {
        final uri = Uri.parse(url.trim());
        return await launchUrl(uri, mode: LaunchMode.platformDefault);
      } catch (_) {
        return false;
      }
    }
  }
}
