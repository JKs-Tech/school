import 'dart:io';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:infixedu/config/app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/fees/paymentGateway/khalti/sdk/khalti.dart';
import 'utils/widget/page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:intl/intl.dart';
import 'package:infixedu/utils/localdb/DatabaseHelper.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  RemoteNotification notification =
      message.notification ?? RemoteNotification();
  print('onMessage data message notification = $notification');
  print('onMessage data message messageId = ${message.messageId}');
  onPushNotificationReceived(message.messageId ?? "", notification);
}

Future<void> onPushNotificationReceived(
  String messageId,
  RemoteNotification remoteNotification,
) async {
  final title = remoteNotification.title;
  final body = remoteNotification.body;
  final date = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
  dbHelper.saveNotification(messageId, date, title ?? "", body ?? "");
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

// ignore: prefer_typing_uninitialized_variables
var language;
bool langValue = false;
DatabaseHelper dbHelper = DatabaseHelper();

void main() async {
  try {
    // Ensure Flutter is initialized
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize Firebase
    await Firebase.initializeApp();

    // Initialize Firebase Crashlytics
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    // Initialize Firebase Analytics
    await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);

    // Initialize Firebase Messaging
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Set preferred orientations
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(
        statusBarColor: const Color(0xff280073),
      ),
    );

    // Set HTTP overrides
    HttpOverrides.global = MyHttpOverrides();

    // Initialize SharedPreferences
    final sharedPref = await SharedPreferences.getInstance();
    language = sharedPref.getString('language');
    debugPrint('Language: $language');

    // Initialize Khalti (only if not on iOS to avoid issues)
    if (!Platform.isIOS) {
      await Khalti.init(publicKey: khaltiPublicKey, enabledDebugging: true);
    }

    // Run the app
    runApp(MyApp());
  } catch (error, stackTrace) {
    // Log any initialization errors
    print('Error during app initialization: $error');
    FirebaseCrashlytics.instance.recordError(error, stackTrace);

    // Still run the app even if there's an error
    runApp(MyApp());
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MainPage();
  }
}

void printAll(String text) {
  final pattern = RegExp('.{1,800}'); // 1024 is the default chunk size
  pattern.allMatches(text).forEach((match) => print(match.group(0)));
}
