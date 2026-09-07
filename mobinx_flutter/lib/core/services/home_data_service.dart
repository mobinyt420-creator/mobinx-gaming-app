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

  /// Default in-app announcement notice
  static final NoticeModel _defaultNotice = NoticeModel(
    id: 'mobinx_welcome_v1',
    title: '🔥 Welcome to Mobin X Esports Super App!',
    message: 'Free Fire Custom Tournaments, Instant BD Diamond Top-Up, and VIP Sensitivity calibrators are now active.\n\nMake sure to add your Free Fire UID in your Profile tab to automatically receive match room codes!',
    category: 'ANNOUNCEMENT',
    actionText: "LET'S PLAY 🎮",
  );

  /// Initialize Home Data with instant defaults, then sync with Firestore in background
  Future<void> init() async {
    // 1. Populate instant defaults so user experiences 0ms UI render
    bannersNotifier.value = _defaultBanners;
    flashDealsNotifier.value = _defaultFlashDeals;
    featuredTournamentsNotifier.value = _defaultTournaments;
    activeNoticeNotifier.value = _defaultNotice;

    // 2. Fetch live data from Firestore asynchronously
    await refresh();
  }

  /// Pull to refresh / background sync
  Future<void> refresh() async {
    if (isLoadingNotifier.value) return;
    isLoadingNotifier.value = true;

    try {
      if (FirebaseService.isInitialized) {
        // Fetch Live Banners
        final bannerSnap = await FirebaseService.firestore
            .collection('banners')
            .where('isActive', isEqualTo: true)
            .get()
            .timeout(const Duration(seconds: 4));

        if (bannerSnap.docs.isNotEmpty) {
          final liveBanners = bannerSnap.docs
              .map((doc) => BannerModel.fromJson(doc.data()))
              .toList();
          if (liveBanners.isNotEmpty) {
            bannersNotifier.value = liveBanners;
          }
        }

        // Fetch Live Flash Deals
        final dealsSnap = await FirebaseService.firestore
            .collection('flashDeals')
            .where('inStock', isEqualTo: true)
            .get()
            .timeout(const Duration(seconds: 4));

        if (dealsSnap.docs.isNotEmpty) {
          final liveDeals = dealsSnap.docs
              .map((doc) => FlashDealModel.fromJson(doc.data()))
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
