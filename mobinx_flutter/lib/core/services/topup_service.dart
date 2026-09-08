import 'package:flutter/foundation.dart';
import 'firebase_service.dart';
import 'auth_service.dart';
import '../models/diamond_package_model.dart';
import '../models/topup_request_model.dart';

class TopupService {
  TopupService._();
  static final instance = TopupService._();

  final ValueNotifier<List<DiamondPackageModel>> packagesNotifier = ValueNotifier([]);
  final ValueNotifier<List<TopUpRequestModel>> historyNotifier = ValueNotifier([]);

  // Mock packages for MVP
  static const List<DiamondPackageModel> _mockPackages = [
    DiamondPackageModel(id: 'pkg_115', name: '115 Diamonds', diamonds: 115, priceBDT: 85, iconPath: '💎'),
    DiamondPackageModel(id: 'pkg_240', name: '240 Diamonds', diamonds: 240, priceBDT: 170, bonus: '+24 Bonus', iconPath: '💎'),
    DiamondPackageModel(id: 'pkg_610', name: '610 Diamonds', diamonds: 610, priceBDT: 420, bonus: '+61 Bonus', iconPath: '💎'),
    DiamondPackageModel(id: 'pkg_1240', name: '1240 Diamonds', diamonds: 1240, priceBDT: 850, bonus: '+124 Bonus', iconPath: '💎'),
    DiamondPackageModel(id: 'pkg_2530', name: '2530 Diamonds', diamonds: 2530, priceBDT: 1700, bonus: '+253 Bonus', iconPath: '💎'),
  ];

  Future<void> init() async {
    packagesNotifier.value = _mockPackages;
    await fetchHistory();
  }

  Future<void> fetchHistory() async {
    try {
      final user = AuthService.instance.currentUser;
      if (user == null) return;

      final snapshot = await FirebaseService.firestore
          .collection('topup_requests')
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .limit(20)
          .get();

      final history = snapshot.docs.map((doc) => TopUpRequestModel.fromMap(doc.data(), doc.id)).toList();
      historyNotifier.value = history;
    } catch (e) {
      debugPrint('[TopupService] fetchHistory error: $e');
    }
  }

  Future<bool> submitTopUpRequest(TopUpRequestModel request) async {
    try {
      await FirebaseService.firestore
          .collection('topup_requests')
          .doc(request.id)
          .set(request.toMap());

      // Prepend to local history
      historyNotifier.value = [request, ...historyNotifier.value];
      return true;
    } catch (e) {
      debugPrint('[TopupService] submitTopUpRequest error: $e');
      return false;
    }
  }
}
