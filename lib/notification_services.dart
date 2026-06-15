import 'dart:developer';
import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:push_notifications/chat_screen.dart';
import 'package:push_notifications/home_screen.dart';

class NotificationServices {
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  void initLocalNotification({
    required BuildContext context,
    required RemoteMessage message,
  }) async {
    var androidInitializationSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    var iosInitializationSettings = DarwinInitializationSettings();
    var initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (payload) {
        messageHandler(message);
      },
    );
  }

  void firebaseInit({required BuildContext context}) {
    FirebaseMessaging.onMessage.listen((event) {
      if (kDebugMode) {
        print(event.notification!.title);
        print(event.notification!.body);
        print('Notification payload: ${event.data}');
      }
      if (Platform.isAndroid) {
        if (context.mounted) {
          initLocalNotification(context: context, message: event);
        }
        showNotificationOnForeground(message: event);
      } else {
        showNotificationOnForeground(message: event);
      }
    });
  }

  Future<void> showNotificationOnForeground({
    required RemoteMessage message,
  }) async {
    AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notification',
      importance: Importance.max,
      playSound: true,
    );

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          channel.id.toString(),
          channel.name.toString(),
          channelDescription: 'channel description',
          importance: Importance.high,
          priority: Priority.high,
          ticker: 'ticker',
          icon: '@mipmap/ic_launcher',
        );

    DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );
    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );

    Future.delayed(Duration(), () {
      flutterLocalNotificationsPlugin.show(
        id: 0,
        title: message.notification!.title,
        body: message.notification!.body,
        notificationDetails: notificationDetails,
      );
    });
  }

  void requestNotificationPermission() async {
    NotificationSettings settings = await firebaseMessaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      AppSettings.openAppSettings(type: AppSettingsType.notification);
      print('User declined or has not accepted permission');
    }
  }

  void onTokenRefresh() {
    firebaseMessaging.onTokenRefresh.listen((event) {
      event.toString();
    });
  }

  Future<String> getDeviceToken() async {
    String? token = await firebaseMessaging.getToken();

    return token!;
  }

  void messageHandler(RemoteMessage message) {
    if (message.data['screen'] == 'chat') {
      navigatorKey.currentState?.push(MaterialPageRoute(builder: (context) => ChatScreen()));
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (context) => ChatScreen()),
      // );
    }
  }
  Future<void> setupInteractedMessage() async {
    // 1. Handle message that opened the app from TERMINATED state
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      // Add a small delay to ensure the UI is ready to transition
      WidgetsBinding.instance.addPostFrameCallback((_) {
        messageHandler(initialMessage);
      });
    }

    // 2. Handle message that opened the app from BACKGROUND state
    FirebaseMessaging.onMessageOpenedApp.listen(messageHandler);
  }


  // Future<void> onBackgroundMessageHandle(BuildContext context) async {
  //   //   when the app is terminated
  //   RemoteMessage? initialMessage = await firebaseMessaging.getInitialMessage();
  //   if (initialMessage != null) {
  //     log('Initial message: $initialMessage');
  //     if (context.mounted) {
  //       messageHandler(context: context, message: initialMessage);
  //     }
  //   }
  //   //   when app is in the background state.
  //   FirebaseMessaging.onMessageOpenedApp.listen((event) {
  //     if (context.mounted) {
  //       messageHandler(context: context, message: event);
  //     }
  //   });
  // }
}
