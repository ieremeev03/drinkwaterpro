import 'package:flutter/material.dart';
import 'package:drinkwaterpro/pages/home/home_page.dart';
import 'package:drinkwaterpro/pages/auth/mobile.dart';
import 'dart:io';
import 'package:drinkwaterpro/pages/splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:drinkwaterpro/firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:drinkwaterpro/data/repository.dart';
import 'package:flutter_fgbg/flutter_fgbg.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart' ;
import 'package:drinkwaterpro/data/globals.dart' as globals;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:drinkwaterpro/controllers/home_controller.dart';
import 'package:drinkwaterpro/data/database.dart';
import 'package:appmetrica_plugin/appmetrica_plugin.dart';


void main() async {
  final Repository repo = new Repository();
  final DatabaseHandler handler = DatabaseHandler();
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  //FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  WidgetsFlutterBinding.ensureInitialized();

  AppMetrica.activate(AppMetricaConfig("b8d659d6-934e-4ef6-a375-d5b6ad9c507e"));

  final userLogin = await handler.isLoginUser();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;



  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  await messaging.setForegroundNotificationPresentationOptions(
    alert: true, // Required to display a heads up notification
    badge: true,
    sound: true,
  );

  globals.fmcAccept = settings.authorizationStatus.name.toString();

  print('User granted permission: ${settings.authorizationStatus}');



  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'Important notifications from my server.',
    importance: Importance.max,);

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);


  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: "ic_stat_check_circle",
            ),
          ));
    }

    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (notification != null) {
      print('Message also contained a notification: ${notification}');
    }
  });

  repo.add_log('start' );
  await analytics.logAppOpen();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DrinkWater.PRO',
      // убираем баннер
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Gilroy',
        backgroundColor: Colors.white,
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: AppBarTheme(
            backgroundColor: Colors.white,
            iconTheme: IconThemeData(
              color: Colors.black,
            )
        ),

      ),

      home: SplashPage(),
    );
  }
}

