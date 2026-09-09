import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  bool _isInit = false;

  /// Initialize and load cached registered matches and tournaments
  Future<void> init() async {
    if (_isInit) return;
    _isInit = true;

    // 1. Load registered matches from cache
    final cachedRegistered = StorageService.getCache('mobinx_registered_matches');
    if (cachedRegistered is List) {
      registeredIdsNotifier.value = cachedRegistered.map((e) => e.toString()).toSet();
    }

    // 2. Load cached tournaments from storage if available (no dummy data)
    final cachedTournaments = StorageService.getCache('mobinx_tournaments_data');
    if (cachedTournaments is List && cachedTournaments.isNotEmpty) {
      try {
        final cachedList = cachedTournaments
            .map((item) => TournamentModel.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
        _updateTournamentsList(cachedList);
      } catch (_) {}
    }

    // 3. Fetch latest from Firestore in background
    await refresh();

    // 4. Real-time sync listener for instant Admin updates
    if (FirebaseService.isInitialized) {
      try {
        FirebaseService.firestore.collection('tournaments').snapshots().listen((snap) {
          final liveList = snap.docs
              .map((doc) => TournamentModel.fromJson({...doc.data(), 'id': doc.id}))
              .where((t) => t.status.toUpperCase() != 'INACTIVE')
              .toList();
          _updateTournamentsList(liveList);
          StorageService.setCache('mobinx_tournaments_data', liveList.map((e) => e.toJson()).toList());
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
      final currentUser = AuthService.instance.currentUser;

      // 1. Add to local registered set
      final newRegistered = Set<String>.from(registeredIdsNotifier.value)..add(tournament.id);
      registeredIdsNotifier.value = newRegistered;
      await StorageService.setCache('mobinx_registered_matches', newRegistered.toList());

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

      // 2. Increment slot count locally and add to participants
      final currentList = tournamentsNotifier.value;
      final updatedList = currentList.map((t) {
        if (t.id == tournament.id) {
          final newSlots = (t.slotsFilled + 1).clamp(0, t.slotsTotal);
          final updatedParticipants = List<Map<String, dynamic>>.from(t.participants)..add(regData);
          return t.copyWith(
            slotsFilled: newSlots, 
            isRegistered: true,
            participants: updatedParticipants,
          );
        }
        return t;
      }).toList();
      tournamentsNotifier.value = updatedList;

      // 3. Update player stats locally
      if (currentUser != null) {
        final updatedUser = currentUser.copyWith(
          tournamentsJoined: currentUser.tournamentsJoined + 1,
        );
        AuthService.instance.userNotifier.value = updatedUser;
        await StorageService.saveUser(updatedUser);
      }

      // 4. Asynchronous Cloud Firestore sync
      if (FirebaseService.isInitialized) {
        await FirebaseService.firestore
            .collection('tournaments')
            .doc(tournament.id)
            .collection('participants')
            .doc(currentUser?.id ?? ffUid)
            .set(regData);

        // Update slots filled and participants list in Firestore
        await FirebaseService.firestore
            .collection('tournaments')
            .doc(tournament.id)
            .update({
          'slotsFilled': tournament.slotsFilled + 1,
          'participants': FieldValue.arrayUnion([regData]),
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

        final liveList = snap.docs
            .map((doc) => TournamentModel.fromJson({...doc.data(), 'id': doc.id}))
            .where((t) => t.status.toUpperCase() != 'INACTIVE')
            .toList();
        _updateTournamentsList(liveList);
        StorageService.setCache('mobinx_tournaments_data', liveList.map((e) => e.toJson()).toList());
      }
    } catch (e) {
      debugPrint('[TournamentService] Refresh error: $e');
    } finally {
      isLoadingNotifier.value = false;
    }
  }
}
