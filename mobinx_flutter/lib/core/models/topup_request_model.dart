import 'package:cloud_firestore/cloud_firestore.dart';

class TopUpRequestModel {
  final String id;
  final String userId;
  final String playerId;
  final String packageId;
  final String paymentMethod;
  final String trxId;
  final double amount;
  final String status; // 'pending', 'approved', 'rejected'
  final DateTime createdAt;

  const TopUpRequestModel({
    required this.id,
    required this.userId,
    required this.playerId,
    required this.packageId,
    required this.paymentMethod,
    required this.trxId,
    required this.amount,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'playerId': playerId,
      'packageId': packageId,
      'paymentMethod': paymentMethod,
      'trxId': trxId,
      'amount': amount,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory TopUpRequestModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parsedDate = DateTime.now();
    if (map['createdAt'] is Timestamp) {
      parsedDate = (map['createdAt'] as Timestamp).toDate();
    } else if (map['createdAt'] is String) {
      parsedDate = DateTime.tryParse(map['createdAt']) ?? DateTime.now();
    }

    return TopUpRequestModel(
      id: docId,
      userId: map['userId'] ?? '',
      playerId: map['playerId'] ?? '',
      packageId: map['packageId'] ?? '',
      paymentMethod: map['paymentMethod'] ?? '',
      trxId: map['trxId'] ?? '',
      amount: map['amount']?.toDouble() ?? 0.0,
      status: map['status'] ?? 'pending',
      createdAt: parsedDate,
    );
  }
}
