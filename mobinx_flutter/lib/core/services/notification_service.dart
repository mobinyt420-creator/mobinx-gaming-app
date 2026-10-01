import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:url_launcher/url_launcher.dart';
import 'firebase_service.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../features/tournaments/tournaments_screen.dart';
import '../../features/downloads/downloads_screen.dart';

/// Top-level background message handler for FCM
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await FirebaseService.init();
    debugPrint('[FCM Background] Received message: ${message.messageId} | data: ${message.data}');
    
    // If it's a data-only message (or background payload without automatic OS notification display), render local notification
    if (message.notification == null && message.data.isNotEmpty) {
      final title = message.data['title']?.toString() ?? 'OBIN Official Alert';
      final body = message.data['body']?.toString() ?? 
                   message.data['message']?.toString() ?? 
                   message.data['desc']?.toString() ?? 
                   '';
      if (title.isNotEmpty || body.isNotEmpty) {
        final localNotifs = FlutterLocalNotificationsPlugin();
        const androidInit = AndroidInitializationSettings('@drawable/ic_stat_obin');
        await localNotifs.initialize(settings: const InitializationSettings(android: androidInit));
        const androidDetails = AndroidNotificationDetails(
          'mobinx_high_importance_channel',
          'OBIN Official Alerts',
          channelDescription: 'Real-time push notifications for OBIN Super App orders, top-ups, tournaments and deals',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@drawable/ic_stat_obin',
          color: Color(0xFF0284C7),
          tag: 'obin_alert',
          playSound: true,
          enableVibration: true,
          visibility: NotificationVisibility.public,
        );
        final payload = message.data['url'] ?? message.data['targetUrl'] ?? message.data['actionUrl'] ?? message.data['link'];
        await localNotifs.show(
          id: 1001,
          title: title,
          body: body.isNotEmpty ? body : 'Tap to open OBIN App',
          notificationDetails: const NotificationDetails(android: androidDetails),
          payload: payload?.toString(),
        );
      }
    }
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
      title: data['title']?.toString() ?? 'OBIN Notice',
      message: data['message']?.toString() ?? data['desc']?.toString() ?? data['body']?.toString() ?? '',
      type: data['type']?.toString().toLowerCase() ?? 'general',
      timestamp: ts,
      unread: !isRead,
      targetUrl: data['url']?.toString() ?? data['targetUrl']?.toString() ?? data['actionUrl']?.toString() ?? data['link']?.toString(),
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
  static const String channelName = 'OBIN Official Alerts';
  static const String channelDescription = 'Real-time push notifications for OBIN Super App orders, top-ups, tournaments and deals';

  static const String secondaryChannelId = 'obin_official_push_channel';

  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  final ValueNotifier<List<NotificationItem>> notificationsNotifier = ValueNotifier<List<NotificationItem>>([]);
  final ValueNotifier<int> unreadCountNotifier = ValueNotifier<int>(0);

  final Set<String> _readIds = {};
  bool _isInit = false;

  Future<void> init() async {
    if (_isInit) return;
    _isInit = true;

    // 1. Load locally cached read IDs
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedRead = prefs.getStringList('obin_read_notifications') ?? prefs.getStringList('mobinx_read_notifications') ?? [];
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
      const androidInit = AndroidInitializationSettings('@drawable/ic_stat_obin');
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
          handleActionPayload(response.payload);
        },
      );

      // Create Android Notification Channels (Primary & Secondary)
      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        // Channel 1: Primary high importance (matches Firebase Admin FCM payload)
        const androidChannel1 = AndroidNotificationChannel(
          channelId,
          channelName,
          description: channelDescription,
          importance: Importance.max,
          enableLights: true,
          enableVibration: true,
          playSound: true,
          showBadge: true,
        );
        await androidPlugin.createNotificationChannel(androidChannel1);

        // Channel 2: Secondary OBIN channel
        const androidChannel2 = AndroidNotificationChannel(
          secondaryChannelId,
          'OBIN Push Channel',
          description: 'Instant status bar alerts for all users',
          importance: Importance.max,
          enableLights: true,
          enableVibration: true,
          playSound: true,
          showBadge: true,
        );
        await androidPlugin.createNotificationChannel(androidChannel2);

        // Channel 3: Fallback FCM channel (used by Firebase Console if not specified)
        const androidChannel3 = AndroidNotificationChannel(
          'fcm_fallback_notification_channel',
          'OBIN Notifications',
          description: 'General notifications & broadcast updates',
          importance: Importance.max,
          enableLights: true,
          enableVibration: true,
          playSound: true,
          showBadge: true,
        );
        await androidPlugin.createNotificationChannel(androidChannel3);
      }
    } catch (e) {
      debugPrint('[NotificationService] Local notification init error: $e');
    }
  }

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static String? pendingActionPayload;

  /// Safely opens external URLs or deep-links to app screens when notifications are clicked
  static Future<void> handleActionPayload(String? payload) async {
    final clean = payload?.trim() ?? '';
    debugPrint('🔔 [NotificationService] Handling notification payload: $clean');

    // 1. External URL (e.g. https://... or http://...)
    if (clean.startsWith('http://') || clean.startsWith('https://')) {
      final uri = Uri.tryParse(clean);
      if (uri != null) {
        try {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          return;
        } catch (e) {
          debugPrint('⚠️ [NotificationService] Failed to launch external url: $e');
        }
      }
    }

    // 2. In-App Screen Navigation
    final nav = navigatorKey.currentState;
    if (nav != null) {
      if (clean == 'tournaments') {
        nav.push(MaterialPageRoute(builder: (_) => const TournamentsScreen()));
      } else if (clean == 'downloads') {
        nav.push(MaterialPageRoute(builder: (_) => const DownloadsScreen()));
      } else {
        nav.push(MaterialPageRoute(builder: (_) => const NotificationsScreen()));
      }
    } else {
      // Store to navigate after splash finishes
      pendingActionPayload = clean.isNotEmpty ? clean : 'notifications';
    }
  }

  /// Process any pending notification tap from cold-start launch
  static void processPendingNotification() {
    if (pendingActionPayload == null) return;
    final payload = pendingActionPayload;
    pendingActionPayload = null;
    handleActionPayload(payload);
  }

  Future<void> _initFCM() async {
    try {
      final messaging = FirebaseMessaging.instance;

      // Set background messaging handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // Listen for token refreshes
      messaging.onTokenRefresh.listen((token) {
        _syncFCMToken(token);
      });

      // Explicitly request Push Notification permission on first launch (essential for Android 13+)
      try {
        await requestPermission();
      } catch (e) {
        debugPrint('[NotificationService] Request permission notice: $e');
      }

      // Unconditionally register FCM token and subscribe to broadcast topics
      // Ensures background push delivery to closed devices regardless of initial prompt timing
      await _registerAndSubscribe(messaging);

      // Foreground message listener: Trigger native system notification in status bar (deduplicated)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        final notif = message.notification;
        final data = message.data;
        final title = notif?.title ?? data['title'] ?? 'OBIN Official Alert';
        final body = notif?.body ?? data['body'] ?? data['message'] ?? '';
        final payload = data['url'] ?? data['targetUrl'] ?? data['actionUrl'] ?? data['link'];
        final broadcastId = data['broadcastId']?.toString();
        final notifId = data['id']?.toString() ?? message.messageId ?? 'fcm_${DateTime.now().millisecondsSinceEpoch}';

        if (title.isNotEmpty || body.isNotEmpty) {
          showSystemNotification(
            id: notifId,
            broadcastId: broadcastId,
            title: title,
            body: body,
            payload: payload?.toString(),
            type: data['type'],
          );
        }
      });

      // Background tap handler: user taps on OS notification when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('🔔 [FCM] Notification opened app from background: ${message.data}');
        final payload = message.data['url'] ?? message.data['targetUrl'] ?? message.data['actionUrl'] ?? message.data['link'];
        handleActionPayload(payload?.toString());
      });

      // Cold start / terminated tap handler: app launched by tapping notification
      messaging.getInitialMessage().then((RemoteMessage? message) {
        if (message != null) {
          debugPrint('🔔 [FCM] Notification opened app from terminated state: ${message.data}');
          final payload = message.data['url'] ?? message.data['targetUrl'] ?? message.data['actionUrl'] ?? message.data['link'];
          handleActionPayload(payload?.toString());
        }
      });
    } catch (e) {
      debugPrint('[NotificationService] FCM init notice: $e');
    }
  }

  /// Check if Push Notification Permission is currently granted
  Future<bool> isPermissionGranted() async {
    try {
      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        final areEnabled = await androidPlugin.areNotificationsEnabled();
        if (areEnabled != null) return areEnabled;
      }
      final settings = await FirebaseMessaging.instance.getNotificationSettings();
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (e) {
      debugPrint('[NotificationService] Check permission error: $e');
      return false;
    }
  }

  /// Request System Push Notification Permission (Android 13+ and iOS)
  Future<bool> requestPermission() async {
    try {
      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.requestNotificationsPermission();
      }

      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      final isGranted = await isPermissionGranted();
      if (isGranted) {
        await _registerAndSubscribe(messaging);
      }

      return isGranted;
    } catch (e) {
      debugPrint('[NotificationService] Permission request error: $e');
      return false;
    }
  }

  Future<void> _registerAndSubscribe(FirebaseMessaging messaging) async {
    try {
      // Unsubscribe from legacy redundant topics to prevent duplicate delivery
      try {
        await messaging.unsubscribeFromTopic('all');
        await messaging.unsubscribeFromTopic('all_users');
        await messaging.unsubscribeFromTopic('mobinx_broadcast');
      } catch (_) {}

      // Subscribe to ONLY ONE canonical broadcast topic
      await messaging.subscribeToTopic('obin_broadcast');

      // Fetch device registration token & persist to Firestore
      final token = await messaging.getToken();
      if (token != null) {
        await _syncFCMToken(token);
      }
      debugPrint('🔔 [NotificationService] Subscribed to canonical topic (obin_broadcast) & synced token');
    } catch (e) {
      debugPrint('[NotificationService] Token register error: $e');
    }
  }

  Future<void> _syncFCMToken(String token) async {
    try {
      if (!FirebaseService.isInitialized) return;
      await FirebaseService.firestore.collection('fcm_tokens').doc(token).set({
        'token': token,
        'platform': 'android',
        'app': 'OBIN',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('[NotificationService] Sync FCM token notice: $e');
    }
  }

  // Deduplication cache: tracks signatures of notifications shown in the last 3 minutes
  static final Map<String, int> _recentlyShownSignatures = {};

  static bool isDuplicateOrSpam(String signature) {
    if (signature.isEmpty) return false;
    final now = DateTime.now().millisecondsSinceEpoch;
    _recentlyShownSignatures.removeWhere((_, time) => now - time > 180000);

    if (_recentlyShownSignatures.containsKey(signature)) {
      final elapsed = now - _recentlyShownSignatures[signature]!;
      if (elapsed < 120000) { // 2 minutes debounce
        return true;
      }
    }
    _recentlyShownSignatures[signature] = now;
    return false;
  }

  /// Trigger a Real Android System Heads-Up Status Bar Notification (with strict deduplication)
  Future<void> showSystemNotification({
    required String id,
    required String title,
    required String body,
    String? payload,
    String? type,
    String? broadcastId,
  }) async {
    try {
      // 1. Strict deduplication: ensure exactly ONE notification per event, zero duplicates
      final signature = (broadcastId != null && broadcastId.isNotEmpty)
          ? broadcastId
          : (id.isNotEmpty && !id.startsWith('fcm_') && !id.startsWith('notice_'))
              ? id
              : '${title.trim().toLowerCase()}_${body.trim().toLowerCase()}';

      if (isDuplicateOrSpam(signature)) {
        debugPrint('🛡️ [NotificationService] Deduplication: suppressed duplicate notification "$signature"');
        return;
      }

      final androidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.max,
        priority: Priority.max,
        icon: '@drawable/ic_stat_obin',
        color: const Color(0xFF0284C7),
        tag: 'obin_alert',
        enableLights: true,
        enableVibration: true,
        playSound: true,
        ticker: title,
        visibility: NotificationVisibility.public,
        styleInformation: BigTextStyleInformation(
          body,
          contentTitle: title,
          summaryText: type != null ? 'OBIN • ${type.toUpperCase()}' : 'OBIN Official',
        ),
      );

      final details = NotificationDetails(android: androidDetails);
      // Fixed ID 1001 ensures exactly ONE status bar notification ever exists (collapses previous)
      const notifId = 1001;
      await _localNotifications.show(
        id: notifId,
        title: title,
        body: body,
        notificationDetails: details,
        payload: (payload != null && payload.trim().isNotEmpty) ? payload.trim() : 'notifications',
      );
      debugPrint('🔔 [NotificationService] Displayed System Notification: $title - $body (id: $notifId)');
    } catch (e) {
      debugPrint('[NotificationService] Show system notification error: $e');
    }
  }

  Future<void> _setupFirestoreListeners() async {
    // Wait until Firebase is initialized (poll up to 15 times with 200ms delay)
    int retries = 0;
    while (!FirebaseService.isInitialized && retries < 15) {
      await Future.delayed(const Duration(milliseconds: 200));
      retries++;
    }

    if (!FirebaseService.isInitialized) {
      debugPrint('[NotificationService] Firebase not ready yet, retrying listener in 2s...');
      Future.delayed(const Duration(seconds: 2), () {
        _setupFirestoreListeners();
      });
      return;
    }

    try {
      // 1. Listen to notifications collection (solely for updating in-app notification center inbox)
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
        } else {
          _updateList([]);
        }
      }, onError: (e) {
        debugPrint('[NotificationService] Firestore snapshot error: $e');
      });

      // 2. Also listen to config/notices broadcast (Solely for in-app notices state sync)
      FirebaseService.firestore
          .collection('config')
          .doc('notices')
          .snapshots()
          .listen((docSnap) async {
        if (docSnap.exists && docSnap.data() != null) {
          final data = docSnap.data()!;
          final pushData = data['pushNotification'];
          if (pushData is Map<String, dynamic>) {
            final id = pushData['id']?.toString() ?? 'notice_${DateTime.now().millisecondsSinceEpoch}';
            final broadcastId = pushData['broadcastId']?.toString() ?? data['broadcastId']?.toString() ?? id;

            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('obin_last_seen_broadcast_id', broadcastId);
          }
        }
      }, onError: (e) {
        debugPrint('[NotificationService] Notices snapshot error: $e');
      });
    } catch (e) {
      debugPrint('[NotificationService] Init error: $e');
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
    unreadCountNotifier.value = 0;
    _persistReadIds();

    final updated = notificationsNotifier.value.map((item) {
      return item.copyWith(unread: false);
    }).toList();

    notificationsNotifier.value = updated;
  }

  Future<void> _persistReadIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _readIds.toList();
      await prefs.setStringList('obin_read_notifications', list);
      await prefs.setStringList('mobinx_read_notifications', list);
    } catch (_) {}
  }
}
