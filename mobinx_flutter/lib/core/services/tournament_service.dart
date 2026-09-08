import 'package:flutter/foundation.dart';
import '../models/tournament_model.dart';
import 'storage_service.dart';
import 'firebase_service.dart';
import 'auth_service.dart';

/// Central Tournament and Esports Match State Manager
class TournamentService {
  static final TournamentService instance = TournamentService._();
  TournamentService._();

  final ValueNotifier<List<TournamentModel>> tournamentsNotifier = ValueNotifier<List<TournamentModel>>([]);
  final ValueNotifier<Set<String>> registeredIdsNotifier = ValueNotifier<Set<String>>({});
  final ValueNotifier<bool> isLoadingNotifier = ValueNotifier<bool>(false);

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
      date: 'TODAY',
      banner: 'assets/images/banner_esports.jpg',
      status: 'Ongoing',
      isLive: true,
      isRoomReleased: true,
      roomId: '9842105',
      roomPass: '7788',
      rules: 'Classic Bermuda map. Squad vs Squad. Emotes allowed. Team teaming is strictly banned.',
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
      date: 'TOMORROW',
      banner: 'assets/images/banner_booyah.jpg',
      status: 'Upcoming',
      isLive: false,
      isRoomReleased: false,
      rules: 'Best of 7 rounds. Unlimited ammo: OFF. Character skills: ON. Gun attributes: OFF.',
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
      date: 'SATURDAY',
      banner: 'assets/images/banner_referral.jpg',
      status: 'Upcoming',
      isLive: false,
      isRoomReleased: false,
      rules: 'Desert Eagle, M1887, Woodpecker only. Top 3 kills win instant bKash prizes.',
    ),
    TournamentModel(
      id: 'tourn-4',
      title: 'Mobin X Season 16 Grand Final',
      mode: 'Squad Championship',
      map: 'Bermuda',
      entryFee: 'FREE',
      prizePool: '৳ 100,000',
      slotsTotal: 48,
      slotsFilled: 48,
      matchTime: '09:00 PM',
      date: 'PAST EVENT',
      banner: 'assets/images/banner_esports.jpg',
      status: 'Completed',
      isLive: false,
      isRoomReleased: false,
      rules: 'Official tournament concluded. Prize money credited to champions.',
    ),
  ];

  bool _isInit = false;

  /// Initialize and load cached registered matches
  Future<void> init() async {
    if (_isInit) return;
    _isInit = true;

    // 1. Load registered matches from cache
    final cachedRegistered = StorageService.getCache('mobinx_registered_matches');
    if (cachedRegistered is List) {
      registeredIdsNotifier.value = cachedRegistered.map((e) => e.toString()).toSet();
    }

    // 2. Populate default tournaments only if currently empty (prevents 1s flash glitch)
    if (tournamentsNotifier.value.isEmpty) {
      _updateTournamentsList(_defaultTournaments);
    }

    // 3. Fetch latest from Firestore in background
    await refresh();

    // 4. Real-time sync listener for instant Admin updates
    if (FirebaseService.isInitialized) {
      try {
        FirebaseService.firestore.collection('tournaments').snapshots().listen((snap) {
          if (snap.docs.isNotEmpty) {
            final liveList = snap.docs.map((doc) => TournamentModel.fromJson({...doc.data(), 'id': doc.id})).toList();
            if (liveList.isNotEmpty) {
              _updateTournamentsList(liveList);
            }
          }
        });
      } catch (_) {}
    }
  }

  void _updateTournamentsList(List<TournamentModel> rawList) {
    final registered = registeredIdsNotifier.value;
    final updated = rawList.map((t) {
      return t.copyWith(isRegistered: registered.contains(t.id));
    }).toList();
    tournamentsNotifier.value = updated;
  }

  /// Register player for tournament
  Future<bool> registerPlayer({
    required TournamentModel tournament,
    required String ign,
    required String ffUid,
    required String phone,
    List<Map<String, String>> teammates = const [],
  }) async {
    try {
      // 1. Add to local registered set
      final newRegistered = Set<String>.from(registeredIdsNotifier.value)..add(tournament.id);
      registeredIdsNotifier.value = newRegistered;
      await StorageService.setCache('mobinx_registered_matches', newRegistered.toList());

      // 2. Increment slot count locally
      final currentList = tournamentsNotifier.value;
      final updatedList = currentList.map((t) {
        if (t.id == tournament.id) {
          final newSlots = (t.slotsFilled + 1).clamp(0, t.slotsTotal);
          return t.copyWith(slotsFilled: newSlots, isRegistered: true);
        }
        return t;
      }).toList();
      tournamentsNotifier.value = updatedList;

      // 3. Update player stats locally
      final currentUser = AuthService.instance.currentUser;
      if (currentUser != null) {
        final updatedUser = currentUser.copyWith(
          tournamentsJoined: currentUser.tournamentsJoined + 1,
        );
        AuthService.instance.userNotifier.value = updatedUser;
        await StorageService.saveUser(updatedUser);
      }

      // 4. Asynchronous Cloud Firestore sync
      if (FirebaseService.isInitialized) {
        final regData = {
          'tournamentId': tournament.id,
          'tournamentTitle': tournament.title,
          'userId': currentUser?.id ?? ffUid,
          'ign': ign,
          'ffUid': ffUid,
          'phone': phone,
          'teammates': teammates,
          'registeredAt': DateTime.now().millisecondsSinceEpoch,
        };

        await FirebaseService.firestore
            .collection('tournaments')
            .doc(tournament.id)
            .collection('participants')
            .doc(currentUser?.id ?? ffUid)
            .set(regData);

        // Update slots filled in Firestore
        await FirebaseService.firestore
            .collection('tournaments')
            .doc(tournament.id)
            .update({
          'slotsFilled': tournament.slotsFilled + 1,
        });
      }

      return true;
    } catch (e) {
      debugPrint('[TournamentService] Registration sync notice: $e');
      return true; // Still success on local client
    }
  }

  /// Admin or system release of room credentials
  Future<void> releaseRoomCredentials(String tournamentId, String roomId, String roomPass) async {
    final updated = tournamentsNotifier.value.map((t) {
      if (t.id == tournamentId) {
        return t.copyWith(
          roomId: roomId,
          roomPass: roomPass,
          isRoomReleased: true,
        );
      }
      return t;
    }).toList();
    tournamentsNotifier.value = updated;

    if (FirebaseService.isInitialized) {
      try {
        await FirebaseService.firestore.collection('tournaments').doc(tournamentId).update({
          'roomCredentials': {
            'roomId': roomId,
            'password': roomPass,
            'isReleased': true,
          },
          'isRoomReleased': true,
        });
      } catch (e) {
        debugPrint('[TournamentService] Release room creds notice: $e');
      }
    }
  }

  /// Pull to refresh
  Future<void> refresh() async {
    if (isLoadingNotifier.value) return;
    isLoadingNotifier.value = true;

    try {
      if (FirebaseService.isInitialized) {
        final snap = await FirebaseService.firestore
            .collection('tournaments')
            .get()
            .timeout(const Duration(seconds: 4));

        if (snap.docs.isNotEmpty) {
          final liveList = snap.docs.map((doc) => TournamentModel.fromJson({...doc.data(), 'id': doc.id})).toList();
          if (liveList.isNotEmpty) {
            _updateTournamentsList(liveList);
          }
        }
      }
    } catch (e) {
      debugPrint('[TournamentService] Refresh error: $e');
    } finally {
      isLoadingNotifier.value = false;
    }
  }
}
