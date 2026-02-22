// lib/services/notification_service.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../firebase_options.dart';
import 'firestore_service.dart';

// ✅ Top-level background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  debugPrint('📱 Background message received: ${message.messageId}');
  debugPrint('Title: ${message.notification?.title}');
  debugPrint('Body: ${message.notification?.body}');
  debugPrint('Data: ${message.data}');
}

class NotificationService {
  // Singleton pattern
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();
  final FirestoreService _firestoreService = FirestoreService();

  bool _isInitialized = false;
  String? _fcmToken;

  // Getters
  bool get isInitialized => _isInitialized;
  String? get fcmToken => _fcmToken;

  /// ✅ Initialize notification service
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('⚠️ NotificationService already initialized');
      return;
    }

    try {
      debugPrint('🚀 Initializing NotificationService...');

      // 1. Request permissions
      final settings = await _requestPermissions();

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        debugPrint('❌ User denied notification permissions');
        return;
      }

      debugPrint('✅ Notification permissions granted');

      // 2. Initialize local notifications
      await _initializeLocalNotifications();

      // 3. Setup message handlers
      await _setupMessageHandlers();

      // 4. Get and save FCM token
      await _initializeFcmToken();

      // 5. Listen for token refresh
      _fcm.onTokenRefresh.listen(_onTokenRefresh);

      _isInitialized = true;
      debugPrint('✅ NotificationService initialized successfully');
    } catch (e, stackTrace) {
      debugPrint('❌ Error initializing NotificationService: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  /// ✅ Request notification permissions
  Future<NotificationSettings> _requestPermissions() async {
    final settings = await _fcm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint('Permission status: ${settings.authorizationStatus}');
    return settings;
  }

  /// ✅ Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    final settings = await _fcm.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  /// ✅ Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    await _fcm.subscribeToTopic(topic);
    debugPrint('✅ Subscribed to topic: $topic');
  }

  /// ✅ Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _fcm.unsubscribeFromTopic(topic);
    debugPrint('✅ Unsubscribed from topic: $topic');
  }

  /// ✅ Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    // Android initialization settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS/macOS initialization settings
    final iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: (id, title, body, payload) async {
        debugPrint('📱 iOS local notification received: $title');
      },
    );

    const macosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      macOS: macosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
      onDidReceiveBackgroundNotificationResponse: _onNotificationTapped,
    );

    debugPrint('✅ Local notifications initialized');

    // Create notification channels (Android only)
    if (Platform.isAndroid) {
      await _createNotificationChannels();
    }
  }

  /// ✅ Create Android notification channels
  Future<void> _createNotificationChannels() async {
    final androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin == null) return;

    // Main notification channel
    const mainChannel = AndroidNotificationChannel(
      'lumixo_channel',
      'Lumixo Notifications',
      description: 'General notifications for Lumixo app',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    // Image ready channel
    const imageChannel = AndroidNotificationChannel(
      'lumixo_image_ready',
      'Image Ready',
      description: 'Notifications when your AI image is ready',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    // Promotional channel
    const promoChannel = AndroidNotificationChannel(
      'lumixo_promotions',
      'Promotions',
      description: 'Special offers and promotions',
      importance: Importance.defaultImportance,
      playSound: true,
    );

    await androidPlugin.createNotificationChannel(mainChannel);
    await androidPlugin.createNotificationChannel(imageChannel);
    await androidPlugin.createNotificationChannel(promoChannel);

    debugPrint('✅ Android notification channels created');
  }

  /// ✅ Setup FCM message handlers
  Future<void> _setupMessageHandlers() async {
    // Background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // App opened from notification (background/terminated)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Check for initial message (app opened from terminated state)
    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('📱 App opened from notification: ${initialMessage.messageId}');
      _handleMessageOpenedApp(initialMessage);
    }

    debugPrint('✅ Message handlers setup complete');
  }

  /// ✅ Handle foreground messages
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('📱 Foreground message received');
    debugPrint('Title: ${message.notification?.title}');
    debugPrint('Body: ${message.notification?.body}');
    debugPrint('Data: ${message.data}');

    // Show local notification when app is in foreground
    await _showLocalNotification(message);
  }

  /// ✅ Handle notification opened app
  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('📱 Message opened app');
    debugPrint('Data: ${message.data}');

    // Handle navigation based on notification data
    _handleNotificationNavigation(message.data);
  }

  /// ✅ Handle notification tap
  @pragma('vm:entry-point')
  static void _onNotificationTapped(NotificationResponse response) {
    debugPrint('📱 Notification tapped');
    debugPrint('ID: ${response.id}');
    debugPrint('Payload: ${response.payload}');

    // Handle navigation based on payload
    if (response.payload != null) {
      // Parse payload and navigate
      // You can use a global navigator key or event bus here
    }
  }

  /// ✅ Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    try {
      final notification = message.notification;
      if (notification == null) {
        debugPrint('⚠️ No notification payload found');
        return;
      }

      // Determine channel based on notification type
      String channelId = 'lumixo_channel';
      if (message.data['type'] == 'image_ready') {
        channelId = 'lumixo_image_ready';
      } else if (message.data['type'] == 'promotion') {
        channelId = 'lumixo_promotions';
      }

      // Android notification details
      final androidDetails = AndroidNotificationDetails(
        channelId,
        channelId == 'lumixo_image_ready'
            ? 'Image Ready'
            : channelId == 'lumixo_promotions'
            ? 'Promotions'
            : 'Lumixo Notifications',
        channelDescription: _getChannelDescription(channelId),
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        largeIcon: notification.android?.imageUrl != null
            ? DrawableResourceAndroidBitmap('@mipmap/ic_launcher')
            : null,
        styleInformation: notification.body != null
            ? BigTextStyleInformation(
          notification.body!,
          contentTitle: notification.title,
          summaryText: 'Lumixo',
        )
            : null,
        playSound: true,
        enableVibration: true,
        enableLights: true,
        color: const Color(0xFF6C63FF), // This now works
      );

      // iOS notification details
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        badgeNumber: 1,
        interruptionLevel: InterruptionLevel.active,
      );

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Show notification
      await _localNotifications.show(
        message.hashCode,
        notification.title ?? 'Lumixo',
        notification.body ?? 'You have a new notification',
        notificationDetails,
        payload: message.data['payload'] ?? message.data.toString(),
      );

      debugPrint('✅ Local notification shown');
    } catch (e, stackTrace) {
      debugPrint('❌ Error showing local notification: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  /// ✅ Get channel description
  String _getChannelDescription(String channelId) {
    switch (channelId) {
      case 'lumixo_image_ready':
        return 'Notifications when your AI image is ready';
      case 'lumixo_promotions':
        return 'Special offers and promotions';
      default:
        return 'General notifications for Lumixo app';
    }
  }

  /// ✅ Initialize and save FCM token
  Future<void> _initializeFcmToken() async {
    try {
      _fcmToken = await _fcm.getToken();

      if (_fcmToken != null) {
        debugPrint('✅ FCM Token: $_fcmToken');
        await _saveFcmTokenToFirestore(_fcmToken!);
      } else {
        debugPrint('⚠️ Failed to get FCM token');
      }
    } catch (e) {
      debugPrint('❌ Error getting FCM token: $e');
    }
  }

  /// ✅ Save FCM token to Firestore
  Future<void> _saveFcmTokenToFirestore(String token) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId != null) {
        await _firestoreService.updateFcmToken(userId, token);
        debugPrint('✅ FCM token saved to Firestore');
      } else {
        debugPrint('⚠️ No user logged in, FCM token not saved');
      }
    } catch (e) {
      debugPrint('❌ Error saving FCM token to Firestore: $e');
    }
  }

  /// ✅ Handle token refresh
  Future<void> _onTokenRefresh(String token) async {
    debugPrint('🔄 FCM token refreshed: $token');
    _fcmToken = token;
    await _saveFcmTokenToFirestore(token);
  }

  /// ✅ Handle notification navigation
  void _handleNotificationNavigation(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    final id = data['id'] as String?;

    debugPrint('🧭 Navigation type: $type, id: $id');

    // Implement navigation logic here
    // You might want to use a navigation service or event bus
    switch (type) {
      case 'image_ready':
        debugPrint('→ Navigate to image result: $id');
        // navigationService.navigateToImageResult(id);
        break;
      case 'coin_purchased':
        debugPrint('→ Navigate to coin history');
        break;
      case 'premium_activated':
        debugPrint('→ Navigate to premium screen');
        break;
      default:
        debugPrint('Unknown notification type: $type');
    }
  }
}
