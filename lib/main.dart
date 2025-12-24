import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get_storage/get_storage.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/core/push_notification_service/firebase_push_notification_service.dart';
import 'package:saveingold_fzco/firebase_options.dart';
import 'package:saveingold_fzco/l10n/L10n.dart';
import 'package:saveingold_fzco/presentation/sharedProviders/providers/language_provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'data/data_sources/network_sources/network_export.dart';
import 'l10n/app_localizations.dart';
import 'presentation/feature_injection.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Main.dart-> Handling a background message ${message.data}');
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  // MUST be the very first call before any plugin / platform channel usage.
  WidgetsFlutterBinding.ensureInitialized();

  runZonedGuarded(
    () async {
      // load .env early (non-blocking failures handled)
      try {
        await dotenv.load(fileName: ".env");
      } catch (e) {
        debugPrint("Could not load .env: $e");
      }

      final environment = dotenv.env['ENVIRONMENT'] ?? 'staging';
      final sentryDsnUrl = dotenv.env['SENTRY_DSN_URL'] ?? '';
      debugPrint("Environment: $environment");

      // Initialize Sentry (safe to await after binding)
      try {
        await SentryFlutter.init(
        (options) {
          options.dsn = sentryDsnUrl;
          options.environment = environment;
          },
        );
      } catch (e, st) {
        debugPrint("Sentry init failed: $e");
        // don't throw — we don't want Sentry failure to block startup
      }

      // Initialize other environment utils (non-blocking if they fail)
      try {
        await EnvUtils.init();
      } catch (e) {
        debugPrint("EnvUtils.init failed: $e");
      }

      // Initialize GetStorage
      try {
        await GetStorage.init();
      } catch (e) {
        debugPrint("GetStorage.init failed: $e");
      }

      // Initialize Firebase early (after binding and Sentry)
      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      } catch (e) {
        debugPrint("Firebase.initializeApp failed: $e");
      }

      // Request notification permission BEFORE calling getAPNSToken.
      // This avoids iOS hanging on first-run when APNs calls are made too early.
      if (Platform.isIOS) {
        try {
          await FirebaseMessaging.instance.requestPermission(
            alert: true,
            badge: true,
            sound: true,
          );
        } catch (e) {
          debugPrint("FirebaseMessaging.requestPermission failed: $e");
        }
      }

      // Set presentation options for iOS foreground notifications.
      try {
        await FirebaseMessaging.instance
            .setForegroundNotificationPresentationOptions(
              alert: true,
              badge: true,
              sound: true,
            );
      } catch (e) {
        debugPrint("setForegroundNotificationPresentationOptions failed: $e");
      }

      // Get FCM token (safe to await)
      try {
        final fcmToken = await FirebaseMessaging.instance.getToken();
        debugPrint("FCM TOKEN: $fcmToken");
      } catch (e) {
        debugPrint("getToken failed: $e");
      }

      // Listen for token refresh (non-blocking)
      try {
        FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
          debugPrint("New refreshed FCM token: $newToken");
        });
      } catch (e) {
        debugPrint("onTokenRefresh listen failed: $e");
      }

      // Initialize Stripe (after binding and Firebase). If Stripe settings missing, don't crash.
      final stripePublishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? "";
      final stripeMerchantId = dotenv.env['STRIPE_MERCHANT_ID'] ?? "";
      try {
        Stripe.publishableKey = stripePublishableKey;
        Stripe.merchantIdentifier = stripeMerchantId;
        await Stripe.instance.applySettings();
      } catch (e) {
        debugPrint("Stripe initialization failed (non-fatal): $e");
      }

      // setup DI / locator
      try {
        setupLocator();
      } catch (e) {
        debugPrint("setupLocator failed: $e");
      }

      // UI chrome (safe)
      try {
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: Colors.transparent,
            statusBarBrightness: Brightness.light,
            statusBarIconBrightness: Brightness.light,
          ),
        );
        SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.manual,
          overlays: [
            SystemUiOverlay.bottom,
            SystemUiOverlay.top,
          ],
        );
      } catch (e) {
        debugPrint("SystemChrome setup failed: $e");
      }

      // Firebase background handler registration
      try {
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );
      } catch (e) {
        debugPrint("onBackgroundMessage registration failed: $e");
      }

      // iOS APNs token retrieval: attempt with timeout to avoid blocking on first install.
      if (Platform.isIOS) {
        try {
          // Try to get APNs token quickly; if not available, schedule an async attempt later so app won't wait.
          String? apnsToken;
          try {
            apnsToken = await FirebaseMessaging.instance.getAPNSToken().timeout(
              const Duration(seconds: 5),
            );
          } catch (_) {
            // timeout or other error - ignore here and try later without awaiting
            apnsToken = null;
          }

        if (apnsToken != null) {
          // We have APNs token now — initialize notification service
            try {
          await FirebasePushNotificationService.initializeNotification(
            userTopic: "saveingoldApp",
          );
            } catch (e) {
              debugPrint("FirebasePushNotificationService.init failed: $e");
            }
        } else {
            // APNs token not ready yet — attempt initialization asynchronously (non-blocking)
            FirebaseMessaging.instance
                .getAPNSToken()
                .then((token) async {
                  if (token != null) {
                    try {
            await FirebasePushNotificationService.initializeNotification(
              userTopic: "saveingoldApp",
            );
                    } catch (e) {
                      debugPrint("Deferred notification init failed: $e");
                    }
                  } else {
                    debugPrint("APNs token still null on deferred attempt");
                  }
                })
                .catchError((e) {
                  debugPrint("Deferred getAPNSToken error: $e");
                });
          }
        } catch (e) {
          debugPrint("APNs handling failed: $e");
        }
      } else {
        // Android: initialize immediately (we await here because it's quick)
        try {
        await FirebasePushNotificationService.initializeNotification(
          userTopic: "saveingoldApp",
        );
        } catch (e) {
          debugPrint(
            "FirebasePushNotificationService.init (android) failed: $e",
          );
        }
      }

      // Foreground message handler — keep light, avoid heavy processing here
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Main.dart -> Got a message whilst in the foreground!');
        debugPrint('Message data: ${message.data}');
        if (message.notification != null) {
          debugPrint(
            'Main.dart -> Message also contained a notification: ${message.notification!.title}',
          );
          if (message.data['type'] == 'chat') {
            debugPrint("Type is Chat Opened (foreground)");
          }
        }
      });

      // When user opens a notification
      FirebaseMessaging.onMessageOpenedApp.listen((event) {
        debugPrint("onMessageOpenedApp: ${event.data}");
        if (event.data['type'] == 'chat') {
          debugPrint("Type is Chat Opened (opened app)");
        }
      });

      // initial message when app launched from terminated state
      try {
        final initialMessage = await FirebaseMessaging.instance
            .getInitialMessage();
        if (initialMessage != null) {
          debugPrint(
            'main.dart -> App opened from killed state by a notification!',
          );
          debugPrint('Initial message data: ${initialMessage.data}');
          if (initialMessage.data['type'] == 'chat') {
            debugPrint("Type is Chat Opened from killed state");
          }
        }
      } catch (e) {
        debugPrint("getInitialMessage failed: $e");
      }

      // final app startup
      debugPrint("App is running");
      final container = ProviderContainer();
      try {
      await container.read(languageProvider.notifier).getLanguage();
      } catch (e) {
        debugPrint("getLanguage failed: $e");
      }

      runApp(
        UncontrolledProviderScope(
          container: container,
          child: const MyApp(),
        ),
      );
    },
    (exception, stackTrace) async {
      // report but don't block the app shutdown / freeze behavior
      try {
      await Sentry.captureException(exception, stackTrace: stackTrace);
      } catch (e) {
        debugPrint("Sentry.captureException failed: $e");
      }
    },
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  Key key = UniqueKey();

  @override
  Widget build(BuildContext context) {
    final languageState = ref.watch(languageProvider);
    final locale = Locale(languageState.languageCode);
    CommonService.lang = locale.languageCode;

    /// initializing resources
    initializeResources(context: context);
    sizes!.initializeSize(context);

    /// Set orientation preferences based on device type
    if (!sizes!.isPhone) {
      // Allow both portrait and landscape for tablets
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      /// Restrict to portrait mode for phones
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    }

    return MaterialApp(
      key: key,
      title: 'SaveInGold',
      locale: locale,
      navigatorKey: navigatorKey,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: L10n.all,
      localeResolutionCallback: (locale, supportedLocales) {
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first;
      },
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(1.0)),
          child: Directionality(
            textDirection: locale.languageCode == 'ar'
                ? TextDirection.rtl
                : TextDirection.ltr,
            child: child!,
          ),
        );
      },
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: AppRoutes.getStartedScreen,
      routes: AppRoutes.routes,
    );
  }
}
