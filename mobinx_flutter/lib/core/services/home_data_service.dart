import 'package:flutter/foundation.dart';
import '../models/banner_model.dart';
import '../models/tournament_model.dart';
import '../models/notice_model.dart';
import 'firebase_service.dart';
import 'storage_service.dart';

/// Centralized Realtime Data Provider for Mobin X Home Screen
class HomeDataService {
  static final HomeDataService instance = HomeDataService._();
  HomeDataService._();

  // Reactive state notifiers
  final ValueNotifier<List<BannerModel>> bannersNotifier = ValueNotifier<List<BannerModel>>([]);
  final ValueNotifier<List<FlashDealModel>> flashDealsNotifier = ValueNotifier<List<FlashDealModel>>([]);
  final ValueNotifier<List<TournamentModel>> featuredTournamentsNotifier = ValueNotifier<List<TournamentModel>>([]);
  final ValueNotifier<NoticeModel?> activeNoticeNotifier = ValueNotifier<NoticeModel?>(null);
  final ValueNotifier<bool> isLoadingNotifier = ValueNotifier<bool>(false);

  /// Initialize Home Data from persistent disk cache immediately, then sync with Firestore in background
  Future<void> init() async {
    // 1. Populate from offline cache if available (instant real data, NO dummy placeholder flashing)
    try {
      final cachedBanners = StorageService.getCache('obin_live_banners');
      if (cachedBanners is List && cachedBanners.isNotEmpty) {
        final list = cachedBanners
            .map((b) => BannerModel.fromJson(Map<String, dynamic>.from(b)))
            .where((b) => b.isActive)
            .toList();
        if (list.isNotEmpty) bannersNotifier.value = list;
      }
    } catch (_) {}

    try {
      final cachedDeals = StorageService.getCache('obin_live_deals');
      if (cachedDeals is List && cachedDeals.isNotEmpty) {
        final list = cachedDeals
            .map((d) => FlashDealModel.fromJson(Map<String, dynamic>.from(d)))
            .where((d) => d.inStock)
            .toList();
        if (list.isNotEmpty) flashDealsNotifier.value = list;
      }
    } catch (_) {}

    // 2. Fetch live data immediately without artificial delay
    refresh();
    _setupRealtimeListeners();
  }

  void _setupRealtimeListeners() {
    if (!FirebaseService.isInitialized) return;
    try {
      FirebaseService.firestore.collection('banners').snapshots().listen((snap) {
        if (snap.docs.isNotEmpty) {
          final live = snap.docs
              .map((doc) => BannerModel.fromJson({...doc.data(), 'id': doc.id}))
              .where((b) => b.isActive)
              .toList();
          if (live.isNotEmpty) {
            bannersNotifier.value = live;
            StorageService.setCache('obin_live_banners', live.map((b) => b.toJson()).toList());
          }
        }
      });
      FirebaseService.firestore.collection('flashDeals').snapshots().listen((snap) {
        if (snap.docs.isNotEmpty) {
          final live = snap.docs
              .map((doc) => FlashDealModel.fromJson({...doc.data(), 'id': doc.id}))
              .where((d) => d.inStock)
              .toList();
          if (live.isNotEmpty) {
            flashDealsNotifier.value = live;
            StorageService.setCache('obin_live_deals', live.map((d) => d.toJson()).toList());
          }
        }
      });
      // Real-time listener for Admin Welcome Popup (Only when explicitly enabled by Admin)
      FirebaseService.firestore.collection('config').doc('notices').snapshots().listen((snap) {
        if (snap.exists && snap.data() != null) {
          final data = snap.data()!;
          if (data['welcomePopup'] is Map) {
            final wp = Map<String, dynamic>.from(data['welcomePopup'] as Map);
            if (wp['enabled'] == true) {
              activeNoticeNotifier.value = NoticeModel(
                id: wp['id']?.toString() ?? 'notice_${wp['title']}',
                title: wp['title']?.toString() ?? 'Notice',
                message: wp['message']?.toString() ?? '',
                category: wp['badge']?.toString() ?? 'NOTICE',
                actionText: wp['btnText']?.toString() ?? 'OK',
                actionUrl: wp['btnUrl']?.toString() ?? '',
              );
            } else {
              activeNoticeNotifier.value = null;
            }
          }
        }
      });
    } catch (_) {}
  }

  /// Pull to refresh / background sync with parallel non-blocking execution
  Future<void> refresh() async {
    if (isLoadingNotifier.value) return;
    isLoadingNotifier.value = true;

    try {
      if (FirebaseService.isInitialized) {
        // Parallel queries to prevent isolate thread stalling
        await Future.wait([
          // Banners
          FirebaseService.firestore
              .collection('banners')
              .get()
              .timeout(const Duration(seconds: 4))
              .then((bannerSnap) {
            if (bannerSnap.docs.isNotEmpty) {
              final liveBanners = bannerSnap.docs
                  .map((doc) => BannerModel.fromJson({...doc.data(), 'id': doc.id}))
                  .where((b) => b.isActive)
                  .toList();
              if (liveBanners.isNotEmpty) {
                bannersNotifier.value = liveBanners;
                StorageService.setCache('obin_live_banners', liveBanners.map((b) => b.toJson()).toList());
              }
            }
          }).catchError((_) => null),

          // Flash Deals
          FirebaseService.firestore
              .collection('flashDeals')
              .get()
              .timeout(const Duration(seconds: 4))
              .then((dealsSnap) {
            if (dealsSnap.docs.isNotEmpty) {
              final liveDeals = dealsSnap.docs
                  .map((doc) => FlashDealModel.fromJson({...doc.data(), 'id': doc.id}))
                  .where((d) => d.inStock)
                  .toList();
              if (liveDeals.isNotEmpty) {
                flashDealsNotifier.value = liveDeals;
                StorageService.setCache('obin_live_deals', liveDeals.map((d) => d.toJson()).toList());
              }
            }
          }).catchError((_) => null),

          // Tournaments
          FirebaseService.firestore
              .collection('tournaments')
              .limit(5)
              .get()
              .timeout(const Duration(seconds: 4))
              .then((tournSnap) {
            if (tournSnap.docs.isNotEmpty) {
              final liveTourns = tournSnap.docs
                  .map((doc) => TournamentModel.fromJson(doc.data()))
                  .toList();
              if (liveTourns.isNotEmpty) {
                featuredTournamentsNotifier.value = liveTourns;
              }
            }
          }).catchError((_) => null),

          // Config Notice
          FirebaseService.firestore
              .collection('config')
              .doc('notices')
              .get()
              .timeout(const Duration(seconds: 4))
              .then((noticeDoc) {
            if (noticeDoc.exists && noticeDoc.data() != null) {
              final data = noticeDoc.data()!;
              if (data['welcomePopup'] is Map) {
                final wp = Map<String, dynamic>.from(data['welcomePopup'] as Map);
                if (wp['enabled'] == true) {
                  activeNoticeNotifier.value = NoticeModel(
                    id: wp['id']?.toString() ?? 'notice_${wp['title']}',
                    title: wp['title']?.toString() ?? 'Notice',
                    message: wp['message']?.toString() ?? '',
                    category: wp['badge']?.toString() ?? 'NOTICE',
                    actionText: wp['btnText']?.toString() ?? 'OK',
                    actionUrl: wp['btnUrl']?.toString() ?? '',
                  );
                }
              }
            }
          }).catchError((_) => null),
        ]);
      }
    } catch (e) {
      debugPrint('[HomeDataService] Background sync error (gracefully using cache): $e');
    } finally {
      isLoadingNotifier.value = false;
    }
  }
}
