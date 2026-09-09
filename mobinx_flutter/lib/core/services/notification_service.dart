import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_service.dart';

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final String type; // 'tournament', 'topup', 'download', 'referral', 'general'
  final DateTime timestamp;
  final bool unread;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.unread = true,
  });

  NotificationItem copyWith({bool? unread}) {
    return NotificationItem(
      id: id,
      title: title,
      message: message,
      type: type,
      timestamp: timestamp,
      unread: unread ?? this.unread,
    );
  }

  factory NotificationItem.fromFirestore(String docId, Map<String, dynamic> data, bool isRead) {
    DateTime ts = DateTime.now();
    final rawTs = data['timestamp'] ?? data['createdAt'];
    if (rawTs != null) {
      if (rawTs is Timestamp) {
        ts = rawTs.toDate();
      } else if (rawTs is int) {
        ts = DateTime.fromMillisecondsSinceEpoch(rawTs);
      } else if (rawTs is String) {
        ts = DateTime.tryParse(rawTs) ?? DateTime.now();
      }
    }

    return NotificationItem(
      id: docId,
      title: data['title']?.toString() ?? 'Mobin X Notice',
      message: data['message']?.toString() ?? data['desc']?.toString() ?? data['body']?.toString() ?? '',
      type: data['type']?.toString().toLowerCase() ?? 'general',
      timestamp: ts,
      unread: !isRead,
    );
  }

  String get timeAgo {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }
}

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final ValueNotifier<List<NotificationItem>> notificationsNotifier = ValueNotifier<List<NotificationItem>>([]);
  final ValueNotifier<int> unreadCountNotifier = ValueNotifier<int>(0);

  final Set<String> _readIds = {};
  bool _isInit = false;

  static final List<NotificationItem> _defaultItems = [
    NotificationItem(
      id: 'default_notif_1',
      title: '🔥 Welcome to Mobin X Super App!',
      message: 'Experience ultra fast speed, instant diamond top-ups, and live tournaments in pure native Flutter.',
      type: 'general',
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      unread: true,
    ),
    NotificationItem(
      id: 'default_notif_2',
      title: '🏆 Free Fire Tournament Registration Open',
      message: 'Weekly CS & Battle Royale custom rooms are live with ৳5,000 bKash prize pool.',
      type: 'tournament',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      unread: true,
    ),
    NotificationItem(
      id: 'default_notif_3',
      title: '💎 Instant BD Top-Up Active',
      message: 'Direct in-game diamond delivery within 5-15 seconds via official UID gateway.',
      type: 'topup',
      timestamp: DateTime.now().subtract(const Duration(hours: 8)),
      unread: false,
    ),
    NotificationItem(
      id: 'default_notif_4',
      title: '🎁 Referral Rewards 2.0',
      message: 'Earn ৳20 per friend + free tournament pass when friends join with your code.',
      type: 'referral',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      unread: false,
    ),
  ];

  Future<void> init() async {
    if (_isInit) return;
    _isInit = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedRead = prefs.getStringList('mobinx_read_notifications') ?? [];
      _readIds.addAll(savedRead);
    } catch (_) {}

    // 1. Instant fallback so screen is never blank
    _updateList(_defaultItems);

    // 2. Real-time Firestore sync
    if (FirebaseService.isInitialized) {
      try {
        FirebaseService.firestore
            .collection('notifications')
            .limit(50)
            .snapshots()
            .listen((snap) {
          if (snap.docs.isNotEmpty) {
            final liveItems = snap.docs.map((doc) {
              final isRead = _readIds.contains(doc.id);
              return NotificationItem.fromFirestore(doc.id, doc.data(), isRead);
            }).toList();
            liveItems.sort((a, b) => b.timestamp.compareTo(a.timestamp));
            _updateList(liveItems);
          }
        }, onError: (e) {
          debugPrint('[NotificationService] Firestore snapshot error: $e');
        });
      } catch (e) {
        debugPrint('[NotificationService] Init error: $e');
      }
    }
  }

  void _updateList(List<NotificationItem> items) {
    notificationsNotifier.value = items;
    unreadCountNotifier.value = items.where((n) => n.unread).length;
  }

  List<NotificationItem> getByType(String type) {
    final list = notificationsNotifier.value;
    if (type.toLowerCase() == 'all') return list;
    return list.where((n) {
      final t = n.type.toLowerCase();
      if (type == 'tournament' && (t == 'tournament' || t.contains('tourn'))) return true;
      if (type == 'topup' && (t == 'topup' || t == 'top-up' || t.contains('diamond'))) return true;
      if (type == 'download' && (t == 'download' || t.contains('apk') || t.contains('tool'))) return true;
      if (type == 'referral' && (t == 'referral' || t.contains('reward') || t.contains('ref'))) return true;
      return t == type;
    }).toList();
  }

  Future<void> markAsRead(String id) async {
    _readIds.add(id);
    _persistReadIds();

    final updated = notificationsNotifier.value.map((item) {
      if (item.id == id) {
        return item.copyWith(unread: false);
      }
      return item;
    }).toList();

    _updateList(updated);
  }

  Future<void> markAllAsRead() async {
    for (final item in notificationsNotifier.value) {
      _readIds.add(item.id);
    }
    _persistReadIds();

    final updated = notificationsNotifier.value.map((item) {
      return item.copyWith(unread: false);
    }).toList();

    _updateList(updated);
  }

  Future<void> _persistReadIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('mobinx_read_notifications', _readIds.toList());
    } catch (_) {}
  }
}
