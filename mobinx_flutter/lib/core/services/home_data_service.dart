import 'package:flutter/foundation.dart';
import '../models/banner_model.dart';
import '../models/tournament_model.dart';
import '../models/notice_model.dart';
import 'firebase_service.dart';

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

  /// Default mock banners for offline & 0-ms instant load
  static final List<BannerModel> _defaultBanners = [
    BannerModel(
      id: 'banner-1',
      title: 'BOOYAH PASS SEASON 17',
      badge: 'SEASON 17',
      image: 'assets/images/banner_booyah.jpg',
      actionUrl: 'topup',
    ),
    BannerModel(
      id: 'banner-2',
      title: 'GLOBAL ESPORTS CUP 2026',
      badge: 'GRAND FINALS',
      image: 'assets/images/banner_esports.jpg',
      actionUrl: 'tournaments',
    ),
    BannerModel(
      id: 'banner-3',
      title: 'DAILY REDEEM CODES & UPDATES',
      badge: 'COMMUNITY',
      image: 'assets/images/banner_referral.jpg',
      actionUrl: 'telegram',
    ),
  ];

  /// Default flash deals
  static final List<FlashDealModel> _defaultFlashDeals = [
    FlashDealModel(
      id: 'flash-1',
      diamondAmount: '100 DIAMONDS',
      price: '৳ 80.00',
      badge: '100% BONUS',
      bonus: '+100 Free',
    ),
    FlashDealModel(
      id: 'flash-2',
      diamondAmount: '310 DIAMONDS',
      price: '৳ 270.00',
      badge: 'POPULAR',
      bonus: '+31 Free',
    ),
    FlashDealModel(
      id: 'flash-3',
      diamondAmount: '520 DIAMONDS',
      price: '৳ 420.00',
      badge: 'BEST VALUE',
      bonus: '+52 Free',
    ),
    FlashDealModel(
      id: 'flash-4',
      diamondAmount: '1060 DIAMONDS',
      price: '৳ 820.00',
      badge: 'LIMITED',
      bonus: '+106 Free',
    ),
    FlashDealModel(
      id: 'flash-5',
      diamondAmount: '2180 DIAMONDS',
      price: '৳ 1650.00',
      badge: 'MEGA DEAL',
      bonus: '+218 Free',
    ),
    FlashDealModel(
      id: 'flash-6',
      diamondAmount: '5600 DIAMONDS',
      price: '৳ 4100.00',
      badge: 'VIP DEAL',
      bonus: '+560 Free',
    ),
  ];

  /// Default featured tournaments (empty by default, loaded from Firestore)
  static final List<TournamentModel> _defaultTournaments = [];

  /// Initialize Home Data with instant defaults, then sync with Firestore in background
  Future<void> init() async {
    // 1. Populate instant defaults so user experiences 0ms UI render
    bannersNotifier.value = _defaultBanners;
    flashDealsNotifier.value = _defaultFlashDeals;
    featuredTournamentsNotifier.value = _defaultTournaments;
    activeNoticeNotifier.value = null;

    // 2. Fetch live data from Firestore asynchronously after UI paints completely (prevents UI freeze)
    Future.delayed(const Duration(milliseconds: 1500), () {
      refresh();
      _setupRealtimeListeners();
    });
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
          if (live.isNotEmpty) bannersNotifier.value = live;
        }
      });
      FirebaseService.firestore.collection('flashDeals').snapshots().listen((snap) {
        if (snap.docs.isNotEmpty) {
          final live = snap.docs
              .map((doc) => FlashDealModel.fromJson({...doc.data(), 'id': doc.id}))
              .where((d) => d.inStock)
              .toList();
          if (live.isNotEmpty) flashDealsNotifier.value = live;
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
              .timeout(const Duration(seconds: 3))
              .then((bannerSnap) {
            if (bannerSnap.docs.isNotEmpty) {
              final liveBanners = bannerSnap.docs
                  .map((doc) => BannerModel.fromJson({...doc.data(), 'id': doc.id}))
                  .where((b) => b.isActive)
                  .toList();
              if (liveBanners.isNotEmpty) {
                bannersNotifier.value = liveBanners;
              }
            }
          }).catchError((_) => null),

          // Flash Deals
          FirebaseService.firestore
              .collection('flashDeals')
              .get()
              .timeout(const Duration(seconds: 3))
              .then((dealsSnap) {
            if (dealsSnap.docs.isNotEmpty) {
              final liveDeals = dealsSnap.docs
                  .map((doc) => FlashDealModel.fromJson({...doc.data(), 'id': doc.id}))
                  .where((d) => d.inStock)
                  .toList();
              if (liveDeals.isNotEmpty) {
                flashDealsNotifier.value = liveDeals;
              }
            }
          }).catchError((_) => null),

          // Tournaments
          FirebaseService.firestore
              .collection('tournaments')
              .limit(5)
              .get()
              .timeout(const Duration(seconds: 3))
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
              .timeout(const Duration(seconds: 3))
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
