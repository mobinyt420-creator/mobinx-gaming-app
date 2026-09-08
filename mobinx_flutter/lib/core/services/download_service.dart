import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/download_item_model.dart';
import 'firebase_service.dart';

class DownloadService {
  DownloadService._();
  static final instance = DownloadService._();

  final ValueNotifier<List<DownloadItemModel>> itemsNotifier = ValueNotifier([]);

  static final List<DownloadItemModel> _defaultItems = [
    DownloadItemModel(
      id: 'apk-1',
      title: 'Mobin X Proxy Ultra Boost APK (Latest V2.8)',
      category: 'Mobin APK',
      youtubeId: 'dQw4w9WgXcQ',
      videoThumbnail: 'assets/images/banner_booyah.jpg',
      videoDuration: '05:00',
      actionButtons: [
        DownloadActionModel(
          id: 'act-1',
          label: 'Pro APK Download',
          icon: 'download',
          url: 'https://mrmobin.blogspot.com/',
        ),
      ],
    ),
    DownloadItemModel(
      id: 'apk-2',
      title: 'Free Fire Max VIP Headshot Aim Config V4',
      category: 'Tools',
      youtubeId: 'LXb3EKWsInQ',
      videoThumbnail: 'assets/images/banner_esports.jpg',
      videoDuration: '12:10',
      actionButtons: [
        DownloadActionModel(
          id: 'act-1',
          label: 'Config APK Download',
          icon: 'download',
          url: 'https://mrmobin.blogspot.com/',
        ),
      ],
    ),
    DownloadItemModel(
      id: 'apk-3',
      title: 'Mobin X Game Booster Pro Max (Universal Optimizer)',
      category: 'Premium Apps',
      youtubeId: '5qap5aO4i9A',
      videoThumbnail: 'assets/images/banner_referral.jpg',
      videoDuration: '06:30',
      actionButtons: [
        DownloadActionModel(
          id: 'act-1',
          label: 'Booster APK Download',
          icon: 'download',
          url: 'https://mrmobin.blogspot.com/',
        ),
      ],
    ),
  ];

  Future<void> init() async {
    itemsNotifier.value = _defaultItems;
    await refresh();
  }

  Future<void> refresh() async {
    try {
      if (FirebaseService.isInitialized) {
        final snap = await FirebaseService.firestore
            .collection('downloads')
            .get()
            .timeout(const Duration(seconds: 4));

        if (snap.docs.isNotEmpty) {
          final liveList = snap.docs
              .map((d) => DownloadItemModel.fromJson({...d.data(), 'id': d.id}))
              .toList();
          if (liveList.isNotEmpty) {
            itemsNotifier.value = liveList;
          }
        }
      }
    } catch (e) {
      debugPrint('[DownloadService] refresh notice: $e');
    }
  }

  Future<bool> launchUrlString(String url) async {
    try {
      final uri = Uri.parse(url);
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
