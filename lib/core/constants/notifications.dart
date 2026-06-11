// import 'dart:convert';
// import 'dart:io';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import '../../features/users/client/notifications/ui/notifications.dart';
// import '../../firebase_options.dart';
// import '../../main_production.dart';
// import '../cache/cache_helper.dart';

// @pragma('vm:entry-point')
// Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   // لازم initialize هنا
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

//   // ممنوع UI هنا (لا Navigation ولا Local Notifications)
//   debugPrint("BG Message: id=${message.messageId}, data=${message.data}");
// }

// /// ===============================
// /// 2) LOCAL NOTIFICATIONS INSTANCE
// /// ===============================
// final FlutterLocalNotificationsPlugin _localNotifications =
//     FlutterLocalNotificationsPlugin();

// /// ===============================
// /// 3) ANDROID CHANNEL (موحّد)
// /// ===============================
// const AndroidNotificationChannel _androidChannel = AndroidNotificationChannel(
//   'high_importance_channel',
//   'High Importance Notifications',
//   description: 'This channel is used for important notifications.',
//   importance: Importance.high,
// );

// class NotificationHelper {
//   static String _deviceToken = "";

//   /// Call once in main() before runApp()
//   static Future<void> initFirebaseAndFCM() async {
//     // Firebase init
//     await Firebase.initializeApp(
//       options: DefaultFirebaseOptions.currentPlatform,
//     );

//     // Register background handler (مرة واحدة فقط)
//     FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

//     // Request permissions (خصوصًا iOS)
//     await _requestPermissions();

//     // Foreground presentation (iOS)
//     await FirebaseMessaging.instance
//         .setForegroundNotificationPresentationOptions(
//           alert: true,
//           badge: true,
//           sound: true,
//         );

//     // Init local notifications + channel
//     await _initLocalNotifications();

//     // Create Android channel
//     await _createAndroidChannel();

//     // Get token
//     await _getAndCacheDeviceToken();
//   }

//   /// Call once after runApp() (or in your App start)
//   static void setupListeners() {
//     // 1) Foreground messages -> show local notification
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
//       final hasNotification = message.notification != null;

//       // iOS + notification block → سيب النظام يعرض
//       if (Platform.isIOS && hasNotification) {
//         debugPrint("iOS system notification will be shown");
//         return;
//       }

//       // غير كده (Android أو data-only على iOS)
//       await _showLocalNotification(
//         title:
//             message.notification?.title ??
//             message.data['title'] ??
//             'Notification',
//         body: message.notification?.body ?? message.data['body'] ?? '',
//         data: message.data,
//       );
//     });

//     // 2) When user taps notification and app opens from background
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       debugPrint("Opened App from Notification: ${message.messageId}");
//       _openNotificationsScreen();
//     });

//     // 3) If app was terminated and opened by tapping notification
//     _handleInitialMessage();
//   }

//   /// ===============================
//   /// Permissions
//   /// ===============================
//   static Future<void> _requestPermissions() async {
//     if (Platform.isIOS) {
//       final settings = await FirebaseMessaging.instance.requestPermission(
//         alert: true,
//         badge: true,
//         sound: true,
//         provisional: false,
//       );
//       debugPrint("iOS permission: ${settings.authorizationStatus}");

//       final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
//       debugPrint("APNS Token: $apnsToken");
//     } else {
//       // Android 13+ might require runtime permission depending on your setup
//       await FirebaseMessaging.instance.requestPermission();
//     }
//   }

//   /// ===============================
//   /// Local notifications init
//   /// ===============================
//   static Future<void> _initLocalNotifications() async {
//     const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

//     const iosInit = DarwinInitializationSettings(
//       requestAlertPermission: true,
//       requestBadgePermission: true,
//       requestSoundPermission: true,
//     );

//     const initSettings = InitializationSettings(
//       android: androidInit,
//       iOS: iosInit,
//     );

//     await _localNotifications.initialize(
//       settings: initSettings,
//       onDidReceiveNotificationResponse: (NotificationResponse response) {
//         // tapped local notification
//         debugPrint("Local notification tapped. payload=${response.payload}");
//         _openNotificationsScreen();
//       },
//     );
//   }

//   static Future<void> _createAndroidChannel() async {
//     final androidPlugin =
//         _localNotifications
//             .resolvePlatformSpecificImplementation<
//               AndroidFlutterLocalNotificationsPlugin
//             >();

//     await androidPlugin?.createNotificationChannel(_androidChannel);
//   }

//   /// ===============================
//   /// Token
//   /// ===============================
//   static Future<void> _getAndCacheDeviceToken() async {
//     try {
//       _deviceToken = (await FirebaseMessaging.instance.getToken()) ?? "";
//       if (_deviceToken.isNotEmpty) {
//         CacheHelper.setDeviceToken(_deviceToken);
//       }
//       debugPrint(
//         "FCM token (${Platform.isIOS ? "iOS" : "Android"}): $_deviceToken",
//       );

//       // لو عايز تتابع تحديث التوكن
//       FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
//         _deviceToken = newToken;
//         CacheHelper.setDeviceToken(_deviceToken);
//         debugPrint("FCM token refreshed: $_deviceToken");
//       });
//     } catch (e) {
//       debugPrint("FCM token Exception :: $e");
//     }
//   }

//   /// ===============================
//   /// Local notification show
//   /// ===============================
//   static Future<void> _showLocalNotification({
//     required String title,
//     required String body,
//     Map<String, dynamic>? data,
//   }) async {
//     final payload = jsonEncode(data ?? {});

//     final androidDetails = AndroidNotificationDetails(
//       _androidChannel.id,
//       _androidChannel.name,
//       channelDescription: _androidChannel.description,
//       importance: Importance.max,
//       priority: Priority.high,
//     );

//     const iosDetails = DarwinNotificationDetails(
//       presentAlert: true,
//       presentBadge: true,
//       presentSound: true,
//     );

//     final details = NotificationDetails(
//       android: androidDetails,
//       iOS: iosDetails,
//     );

//     // استخدم id مختلف عشان الإشعارات متستبدلش بعضها
//     final notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

//     await _localNotifications.show(
//       id: notificationId,
//       title: title,
//       body: body,
//       notificationDetails: details,
//       payload: payload,
//     );
//   }

//   /// ===============================
//   /// Initial message when terminated
//   /// ===============================
//   static Future<void> _handleInitialMessage() async {
//     final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
//     if (initialMessage != null) {
//       debugPrint("Initial Message: ${initialMessage.messageId}");
//       _openNotificationsScreen();
//     }
//   }

//   /// ===============================
//   /// Navigation helper (safe)
//   /// ===============================
//   static void _openNotificationsScreen() {
//     final nav = navigatorKey.currentState;
//     if (nav == null) return;

//     nav.push(
//       MaterialPageRoute(
//         builder:
//             (_) =>
//                const Notifications()
                    
//       ),
//     );
//   }
// }
