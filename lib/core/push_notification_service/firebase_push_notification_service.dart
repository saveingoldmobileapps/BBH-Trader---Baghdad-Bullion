import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:saveingold_fzco/core/theme/constant_strings.dart';
import 'package:saveingold_fzco/data/data_sources/local_database/local_database.dart';
import 'package:saveingold_fzco/presentation/screens/get_started_screen.dart';
import 'package:saveingold_fzco/presentation/screens/notification_screens/notification_screen.dart';

import '../../main.dart';
import '../../presentation/sharedProviders/loan_provider.dart';
import '../common_service.dart';
import '../sound_services.dart';
import '../sounds/app_sounds.dart';

class FirebasePushNotificationService {
  static final Logger _logger = Logger();

  static final FirebasePushNotificationService
  _firebasePushNotificationService = FirebasePushNotificationService();

  static FirebasePushNotificationService get instance =>
      _firebasePushNotificationService;
  static final AndroidNotificationChannel channel = AndroidNotificationChannel(
    'custom_sound_channel', // id
    'High Importance Notifications', // title
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
    playSound: true,
    sound: RawResourceAndroidNotificationSound('notification_sound'),
    enableVibration: true,
  );
  // static AndroidNotificationChannel channel = const AndroidNotificationChannel(
  //   'high_importance_channel', // idq
  //   'High Importance Notifications', // title
  //   description: 'This channel is used for important notifications.',
  //   // description,
  //   importance: Importance.max,
  // );

  static final flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  ///Firebase Push Notification
  static Future<void> initializeNotification({
    required String userTopic,
  }) async {
    // Initializing Channels
    await initializeChannels();

    String str = userTopic.toLowerCase();
    String topic = str.replaceAll(RegExp('[^A-Za-z0-9]'), '');
    _logger.i("beforeTopic: $topic");

    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: true,
      // Notification Center
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      _logger.i('User granted permission: ${settings.authorizationStatus}');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      _logger.i('User granted provisional permission');
    } else {
      _logger.i('User declined or has not accepted permission');
    }

    // subscribe to topic on each app start-up
    await FirebaseMessaging.instance.subscribeToTopic(topic).then((value) {
      _logger.i("TOPIC: $topic subscribe successful");
    });

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    //iOS
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    // FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    //   _logger.i(
    //     "onMessageRemote: ${message.notification?.title}, ${message.messageId}, ${message.messageType}",
    //   );
    //   RemoteNotification? notification = message.notification;
    //   AndroidNotification? android = message.notification?.android;
    //   // If `onMessage` is triggered with a notification, construct our own
    //   // local notification to show to users using the created channel.
    //   if (notification != null && android != null) {
    //     flutterLocalNotificationsPlugin.show(
    //       notification.hashCode,
    //       notification.title,
    //       notification.body,
    //       NotificationDetails(
    //         iOS: const DarwinNotificationDetails(
    //           presentBadge: true,
    //           presentAlert: true,
    //           presentSound: true,
    //         ),
    //         android: AndroidNotificationDetails(
    //           channel.id,
    //           channel.name,
    //           channelDescription: channel.description,
    //           icon: "@mipmap/launcher_icon", //android.smallIcon,
    //         ),
    //       ),
    //     );
    //     if (notification.body != null) {
    //       BuildContext? context =
    //           navigatorKey.currentContext; // Use your navigatorKey

    //       if (context == null) {
    //         _logger.e("Context is null! Cannot navigate.");
    //         return;
    //       }
    //       if (notification.title! == "Request Approved") {
    //         if (!context.mounted) return;
    //         await CommonService.logoutUser(context: context);
    //       }
    //       if (notification.title!.contains("Advance Status Updated")) {
    //         if (!context.mounted) return;

    //         final container = ProviderScope.containerOf(context);
    //         container
    //             .read(loanProvider.notifier)
    //             .fetchAllLoans(showLoading: false);
    //       }
    //     }
    //   }
    // });
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      _logger.i("onMessageRemote: ${message.notification?.title}");

      RemoteNotification? notification = message.notification;

      if (notification != null) {
        // FIX: Don't show a local notification on iOS
        if (Platform.isAndroid) {
          flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channelDescription: channel.description,
                icon: '@mipmap/launcher_icon',
                sound: const RawResourceAndroidNotificationSound(
                  'notification_sound',
                ),
                styleInformation: BigTextStyleInformation(
                  notification.body ?? '',
                  contentTitle: notification.title,
                ),
                priority: Priority.high,
                importance: Importance.max,
              ),
            ),
          );
        }
      }

      // Your existing handlers...
      if (message.notification?.title?.contains("Advance Status Updated") ??
          false) {
        _handleLoanStatusUpdate(message.data);
      } else if (message.notification?.title == "Request Approved" ||
          message.notification?.title == 'تمت الموافقة على الطلب' ||
          message.data['type'] == 'Account Approved') {
        _handleAccountApproval(message.data);
      } else if (message.notification?.title == "Buy price alert" ||
          message.notification?.title == 'تنبيه سعر الشراء' ||
          message.notification?.title == "Sell price alert" ||
          message.notification?.title == "تنبيه سعر البيع") {
        SoundPlayer().playSound(AppSounds.depositSounmd);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((event) async {
      _logger.i("onMessageOpenedApp: ${event.data}");
      //Type base event for the account approval
      String? type = event.data['type'];

      if (type != null) {
        navigateBasedOnNotificationType(type, event.data);
      }
    });
  }

  static void _handleLoanStatusUpdate(Map<String, dynamic> data) {
    BuildContext? context = navigatorKey.currentContext;

    if (context == null) {
      _logger.e("Context is null in _handleLoanStatusUpdate");
      return;
    }

    try {
      final container = ProviderScope.containerOf(context);
      if (context.mounted) {
        container.read(loanProvider.notifier).fetchAllLoans(showLoading: false);
      }
    } catch (e) {
      _logger.e("Error handling loan status update: $e");
    }
  }

  static void _handleAccountApproval(Map<String, dynamic> data) async {
    BuildContext? context = navigatorKey.currentContext;
    if (context == null || !context.mounted) {
      _logger.e("Context is null or not mounted in _handleAccountApproval");
      return;
    }
    bool faceIDEnabled = await LocalDatabase.instance.getFaceEnable() ?? false;
    bool isFingerPrintEnabled =
        await LocalDatabase.instance.getFingerEnable() ?? false;
    LocalDatabase.instance.storeFaceEnable(
      isEnable: false,
    );

    //  LocalDatabase.instance.storeFaceEnable(
    //   isEnable: faceIDEnabled,
    // );
    // await SecureStorageService.instance.storeAutoLogin(
    //   autoLogin: false,
    // );
    await LocalDatabase.instance.storeAutoLogin(
      autoLogin: false,
    );
    await LocalDatabase.instance.storeFingerEnable(
      isEnable: false,
    );
    String? email = await LocalDatabase.instance.read(
      key: Strings.userEmail,
    );
    // CommonService.logoutUser(context: context);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => GetStartedScreen()),
      ((route) => false),
    );
  }

  static Future<void> initializeChannels() async {
    _logger.i("initializing channels...");
    // tz.initializeTimeZones();

    /// Android Initialization Setting
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings(
          '@mipmap/launcher_icon',
        );

    /// iOS Initialization Setting
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          // onDidReceiveLocalNotification: onDidReceiveLocalNotification,
        );

    /// Settings
    const InitializationSettings settings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: initializationSettingsDarwin,
    );

    /// Local Notification Service
    await flutterLocalNotificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
      // onSelectNotification: onSelectNotification,
    );
  }

  static void onDidReceiveNotificationResponse(
    NotificationResponse notificationResponse,
  ) async {
    _navigateToNotificationScreen();
    _logger.i(
      "onDidReceiveNotificationResponse ${notificationResponse.notificationResponseType.name}",
    );
  }

  /// On Select Notification
  static void onSelectNotification(String? payload) {
    _logger.i("onSelectNotificationPayload: $payload");
    // Handle notification tap - navigate to Notification Screen
    _navigateToNotificationScreen();
  }

  /// Add this new method for navigation
  static void _navigateToNotificationScreen() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      BuildContext? context = navigatorKey.currentContext;

      if (context == null) {
        _logger.e("Context is null! Cannot navigate to notification screen.");
        return;
      }

      // Navigate to Notification Screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const NotificationScreen(),
        ),
      );
    });
  }

  /// on Did Receive Local Notification
  static void onDidReceiveLocalNotification(
    int id,
    String? title,
    String? body,
    String? payload,
  ) async {
    _logger.i("id: $id, title: $title, body: $body, payload: $payload");
  }

  /// Unsubscribe From Topic
  static Future<void> unsubscribeFromTopic({required String email}) async {
    String str = email.toLowerCase();
    String userEmail = str.replaceAll(RegExp('[^A-Za-z0-9]'), '');

    _logger.d("UserEmail for topic: $userEmail");

    await FirebaseMessaging.instance
        .unsubscribeFromTopic(userEmail)
        .then((value) {
          _logger.d("TOPIC: Unsubscribe successful");
        })
        .onError((error, stackTrace) {
          _logger.e(
            "TOPICError: Unsubscribe failed",
          );
        });
  }

  // static Future<void> unsubscribeFromTopic({required String email}) async {
  //   String str = email.toLowerCase();
  //   String userEmail = str.replaceAll(RegExp('[^A-Za-z0-9]'), '');
  //   _logger.d("UserEmail for topic:$userEmail");
  //   // subscribe to topic on each app start-up
  //   await FirebaseMessaging.instance
  //       .unsubscribeFromTopic(email)
  //       .then((value) {
  //         _logger.d("TOPIC: Unsubscribe successful");
  //       })
  //       .onError((error, stackTrace) {
  //         _logger.d("TOPICError: Unsubscribe successful");
  //       });
  // }

  //Personal Info Update notifiaction,if found specific type it will navigate to logout
  static final container = ProviderContainer();

  static void navigateBasedOnNotificationType(
    String type,
    Map<String, dynamic> data,
  ) {
    // Use your navigatorKey
    BuildContext? context = navigatorKey.currentContext;

    if (context == null) {
      _logger.e("Context is null! Cannot navigate.");
      return;
    }

    _logger.i("Navigating based on type: $type");

    switch (type) {
      case 'Profile update request Approved':
        CommonService.logoutUser(context: context);
        break;
      case 'Advance Status Updated.':
        container.read(loanProvider.notifier).fetchAllLoans();
        break;
      default:
        _logger.i("Unknown notification type: $type");
        break;
    }
  }
}
