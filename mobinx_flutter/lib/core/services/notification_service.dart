import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'firebase_service.dart';

/// Top-level background message handler for FCM
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    debugPrint('[FCM Background] Received message: ${message.messageId}');
  } catch (e) {
    debugPrint('[FCM Background Error]: $e');
  }
}

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final String type; // 'tournament', 'topup', 'download', 'referral', 'general'
  final DateTime timestamp;
  final bool unread;
  final String? targetUrl;
  final String? imageUrl;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.unread = true,
    this.targetUrl,
    this.imageUrl,
  });

  NotificationItem copyWith({
    bool? unread,
    String? targetUrl,
    String? imageUrl,
  }) {
    return NotificationItem(
      id: id,
      title: title,
      message: message,
      type: type,
      timestamp: timestamp,
      unread: unread ?? this.unread,
      targetUrl: targetUrl ?? this.targetUrl,
      imageUrl: imageUrl ?? this.imageUrl,
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
      targetUrl: data['targetUrl']?.toString() ?? data['actionUrl']?.toString(),
      imageUrl: data['imageUrl']?.toString(),
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

  static const String channelId = 'mobinx_high_importance_channel';
  static const String channelName = 'Mobin X Official Alerts';
  static const String channelDescription = 'Real-time push notifications for tournaments, custom rooms, flash deals and updates';

  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  final ValueNotifier<List<NotificationItem>> notificationsNotifier = ValueNotifier<List<NotificationItem>>([]);
  final ValueNotifier<int> unreadCountNotifier = ValueNotifier<int>(0);
  final ValueNotifier<NotificationItem?> latestIncomingNotification = ValueNotifier<NotificationItem?>(null);

  final Set<String> _readIds = {};
  final Set<String> _knownIds = {};
  bool _isInit = false;
  final DateTime _appInitTime = DateTime.now();

  Future<void> init() async {
    if (_isInit) return;
    _isInit = true;

    // 1. Load locally cached read IDs
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedRead = prefs.getStringList('mobinx_read_notifications') ?? [];
      _readIds.addAll(savedRead);
    } catch (_) {}

    // 2. Initialize Local Notifications Plugin & Android Channel
    await _initLocalNotifications();

    // 3. Initialize Firebase Cloud Messaging (FCM)
    await _initFCM();

    // 4. Real-time Firestore notifications sync (Listens for admin panel broadcasts)
    _setupFirestoreListeners();
  }

  Future<void> _initLocalNotifications() async {
    try {
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosInit = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidInit,
        iOS: iosInit,
      );

      await _localNotifications.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint('[Local Notification Tapped]: ${response.payload}');
        },
      );

      // Create Android Notification Channel
      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        const androidChannel = AndroidNotificationChannel(
          channelId,
          channelName,
          description: channelDescription,
          importance: Importance.max,
          enableLights: true,
          enableVibration: true,
          playSound: true,
          showBadge: true,
        );
        await androidPlugin.createNotificationChannel(androidChannel);
      }
    } catch (e) {
      debugPrint('[NotificationService] Local notification init error: $e');
    }
  }

  Future<void> _initFCM() async {
    try {
      final messaging = FirebaseMessaging.instance;

      // Set background messaging handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // Request system permissions
      await requestPermission();

      // Subscribe to topics
      await messaging.subscribeToTopic('all');
      await messaging.subscribeToTopic('all_users');
      await messaging.subscribeToTopic('mobinx_broadcast');

      // Foreground message listener: Trigger system notification popup
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        final notif = message.notification;
        if (notif != null) {
          showSystemNotification(
            id: message.messageId ?? 'fcm_${DateTime.now().millisecondsSinceEpoch}',
            title: notif.title ?? 'Mobin X Alert',
            body: notif.body ?? '',
            payload: message.data['targetUrl'] ?? message.data['actionUrl'],
          );

          final item = NotificationItem(
            id: message.messageId ?? 'fcm_${DateTime.now().millisecondsSinceEpoch}',
            title: notif.title ?? 'Mobin X Alert',
            message: notif.body ?? '',
            type: message.data['type'] ?? 'general',
            timestamp: DateTime.now(),
            unread: true,
          );
          latestIncomingNotification.value = item;
        }
      });
    } catch (e) {
      debugPrint('[NotificationService] FCM init notice: $e');
    }
  }

  /// Request System Push Notification Permission (Android 13+ and iOS)
  Future<bool> requestPermission() async {
    try {
      // Firebase Messaging permission request
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      // Android 13+ Local Notification Permission
      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.requestNotificationsPermission();
      }

      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (e) {
      debugPrint('[NotificationService] Permission request error: $e');
      return false;
    }
  }

  /// Trigger a Real Android System Heads-Up Status Bar Notification
  Future<void> showSystemNotification({
    required String id,
    required String title,
    required String body,
    String? payload,
    String? type,
  }) async {
    try {
      final androidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: const Color(0xFF0284C7),
        enableLights: true,
        enableVibration: true,
        playSound: true,
        fullScreenIntent: true,
        ticker: title,
        visibility: NotificationVisibility.public,
        styleInformation: BigTextStyleInformation(
          body,
          contentTitle: title,
          summaryText: type != null ? 'Mobin X • ${type.toUpperCase()}' : 'Mobin X Official',
        ),
      );

      final details = NotificationDetails(android: androidDetails);
      final notifId = id.hashCode.abs() % 100000;
      await _localNotifications.show(
        id: notifId,
        title: title,
        body: body,
        notificationDetails: details,
        payload: payload,
      );
    } catch (e) {
      debugPrint('[NotificationService] Show system notification error: $e');
    }
  }

  void _setupFirestoreListeners() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!FirebaseService.isInitialized) return;
      try {
        // 1. Listen to notifications collection
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

            // Detect freshly broadcasted notification while app is running
            for (final item in liveItems) {
              if (!_knownIds.contains(item.id)) {
                _knownIds.add(item.id);
                // If notification arrived freshly from Admin panel, trigger System Notification
                if (item.timestamp.isAfter(_appInitTime.subtract(const Duration(seconds: 20)))) {
                  showSystemNotification(
                    id: item.id,
                    title: item.title,
                    body: item.message,
                    payload: item.targetUrl,
                    type: item.type,
                  );
                  latestIncomingNotification.value = item;
                }
              }
            }

            _updateList(liveItems);
          } else {
            _updateList([]);
          }
        }, onError: (e) {
          debugPrint('[NotificationService] Firestore snapshot error: $e');
        });

        // 2. Also listen to config/notices broadcast (Instantly triggers system notification)
        String? lastBroadcastId;
        FirebaseService.firestore
            .collection('config')
            .doc('notices')
            .snapshots()
            .listen((docSnap) {
          if (docSnap.exists && docSnap.data() != null) {
            final data = docSnap.data()!;
            final pushData = data['pushNotification'];
            if (pushData is Map<String, dynamic>) {
              final id = pushData['id']?.toString() ?? 'notice_${DateTime.now().millisecondsSinceEpoch}';
              final broadcastId = pushData['broadcastId']?.toString() ?? data['broadcastId']?.toString() ?? id;
              final isRead = _readIds.contains(broadcastId) || _readIds.contains(id);
              final notif = NotificationItem.fromFirestore(id, pushData, isRead);

              // Trigger if broadcastId changed (new send or resend from admin)
              if (broadcastId != lastBroadcastId) {
                lastBroadcastId = broadcastId;
                if (!_readIds.contains(broadcastId)) {
                  showSystemNotification(
                    id: notif.id,
                    title: notif.title,
                    body: notif.message,
                    payload: notif.targetUrl,
                    type: notif.type,
                  );
                  latestIncomingNotification.value = notif;
                }
              }
            }
          }
        }, onError: (e) {
          debugPrint('[NotificationService] Notices snapshot error: $e');
        });
      } catch (e) {
        debugPrint('[NotificationService] Init error: $e');
      }
    });
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
