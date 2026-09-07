import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Mobin X Central Firebase Service Manager
class FirebaseService {
  static bool _initialized = false;
  static bool get isInitialized => _initialized;

  static FirebaseFirestore get firestore => FirebaseFirestore.instance;
  static FirebaseAuth get auth => FirebaseAuth.instance;

  static Future<void> init() async {
    if (_initialized) return;

    try {
      if (kIsWeb) {
        await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: 'AIzaSyAhXqIMw0YFQFtlrPBzhUNnvl3Oye7kU88',
            appId: '1:219633934545:web:530b11c03ab12a87e065f0',
            messagingSenderId: '219633934545',
            projectId: 'obin-shop',
            storageBucket: 'obin-shop.firebasestorage.app',
          ),
        );
      } else {
        // Android reads google-services.json automatically
        await Firebase.initializeApp();
      }
      _initialized = true;
      debugPrint('⚡ Mobin X: Firebase Core & Firestore Initialized Successfully');
    } catch (e) {
      debugPrint('Firebase initialization notice: $e');
    }
  }

  // --- FIRESTORE USER SYNC ---
  static Future<void> syncUserToCloud(Map<String, dynamic> userData) async {
    try {
      final docId = userData['id']?.toString() ?? userData['uid']?.toString();
      if (docId == null || docId.isEmpty) return;

      await firestore.collection('users').doc(docId).set(
        userData,
        SetOptions(merge: true),
      );
      debugPrint('✅ Player profile synchronized to Cloud Firestore: $docId');
    } catch (e) {
      debugPrint('Firestore user sync notice: $e');
    }
  }
}
