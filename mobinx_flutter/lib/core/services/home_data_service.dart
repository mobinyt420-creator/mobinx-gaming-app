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

  /// Default featured tournaments
  static final List<TournamentModel> _defaultTournaments = [
    TournamentModel(
      id: 'tourn-1',
      title: 'Mobin X Booyah Cup #44',
      mode: 'Squad Battle',
      map: 'Bermuda',
      entryFee: 'FREE',
      prizePool: '৳ 50,000',
      slotsTotal: 48,
      slotsFilled: 38,
      matchTime: 'Tonight at 08:30 PM',
      banner: 'assets/images/banner_esports.jpg',
      status: 'Upcoming',
      isLive: false,
    ),
    TournamentModel(
      id: 'tourn-2',
      title: 'All-Stars Clash Squad Championship',
      mode: '4v4 Clash Squad',
      map: 'Kalahari',
      entryFee: '50 Diamonds',
      prizePool: '৳ 50,000',
      slotsTotal: 32,
      slotsFilled: 18,
      matchTime: 'Tomorrow at 06:00 PM',
      banner: 'assets/images/banner_booyah.jpg',
      status: 'Upcoming',
      isLive: false,
    ),
    TournamentModel(
      id: 'tourn-3',
      title: 'Weekend Solo Headshot Masters',
      mode: 'Solo Headshot Only',
      map: 'Purgatory',
      entryFee: 'FREE',
      prizePool: '৳ 10,000',
      slotsTotal: 50,
      slotsFilled: 22,
      matchTime: 'Saturday at 04:00 PM',
      banner: 'assets/images/banner_referral.jpg',
      status: 'Upcoming',
      isLive: false,
    ),
  ];

  /// Initialize Home Data with instant defaults, then sync with Firestore in background
  Future<void> init() async {
    // 1. Populate instant defaults so user experiences 0ms UI render (no unwanted fake popup)
    bannersNotifier.value = _defaultBanners;
    flashDealsNotifier.value = _defaultFlashDeals;
    featuredTournamentsNotifier.value = _defaultTournaments;
    activeNoticeNotifier.value = null;

    // 2. Fetch live data from Firestore asynchronously
    await refresh();

    // 3. Setup real-time listeners for instant Admin Panel synchronization
    if (FirebaseService.isInitialized) {
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
        // Real-time listener for Admin Notices & Popup
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
            } else if (data['pushNotification'] is Map) {
              final pn = Map<String, dynamic>.from(data['pushNotification'] as Map);
              activeNoticeNotifier.value = NoticeModel.fromJson(pn);
            }
          }
        });
      } catch (_) {}
    }
  }

  /// Pull to refresh / background sync
  Future<void> refresh() async {
    if (isLoadingNotifier.value) return;
    isLoadingNotifier.value = true;

    try {
      if (FirebaseService.isInitialized) {
        // Fetch Live Banners (Supporting both active & isActive from Admin Panel)
        final bannerSnap = await FirebaseService.firestore
            .collection('banners')
            .get()
            .timeout(const Duration(seconds: 4));

        if (bannerSnap.docs.isNotEmpty) {
          final liveBanners = bannerSnap.docs
              .map((doc) => BannerModel.fromJson({...doc.data(), 'id': doc.id}))
              .where((b) => b.isActive)
              .toList();
          if (liveBanners.isNotEmpty) {
            bannersNotifier.value = liveBanners;
          }
        }

        // Fetch Live Flash Deals
        final dealsSnap = await FirebaseService.firestore
            .collection('flashDeals')
            .get()
            .timeout(const Duration(seconds: 4));

        if (dealsSnap.docs.isNotEmpty) {
          final liveDeals = dealsSnap.docs
              .map((doc) => FlashDealModel.fromJson({...doc.data(), 'id': doc.id}))
              .where((d) => d.inStock)
              .toList();
          if (liveDeals.isNotEmpty) {
            flashDealsNotifier.value = liveDeals;
          }
        }

        // Fetch Live Tournaments
        final tournSnap = await FirebaseService.firestore
            .collection('tournaments')
            .limit(5)
            .get()
            .timeout(const Duration(seconds: 4));

        if (tournSnap.docs.isNotEmpty) {
          final liveTourns = tournSnap.docs
              .map((doc) => TournamentModel.fromJson(doc.data()))
              .toList();
          if (liveTourns.isNotEmpty) {
            featuredTournamentsNotifier.value = liveTourns;
          }
        }

        // Fetch Live Notice from config/notices
        final noticeDoc = await FirebaseService.firestore
            .collection('config')
            .doc('notices')
            .get()
            .timeout(const Duration(seconds: 4));

        if (noticeDoc.exists && noticeDoc.data() != null) {
          final data = noticeDoc.data()!;
          if (data['pushNotification'] is Map) {
            activeNoticeNotifier.value = NoticeModel.fromJson(
              Map<String, dynamic>.from(data['pushNotification'] as Map),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('[HomeDataService] Background sync error (gracefully using cache): $e');
    } finally {
      isLoadingNotifier.value = false;
    }
  }
}
