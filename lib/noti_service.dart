import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotiService {
  NotiService._internal();
  static final NotiService _instance = NotiService._internal();
  factory NotiService() => _instance;

  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // final bool _isInitialized = false;

  // bool get isInitialized => _isInitialized;
  

  //INITIAlIZE
  Future<void> initNotification() async {

    print("Start of initNotification");
    print("Target platform: $defaultTargetPlatform");
    
    // if (_isInitialized) return; //prevent re-initialization
    //prepare android init settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher'); //FLUTTER ICON - CHANGE LATER
    //prepare ios init settings
    const iosSettings = IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // init settings
    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    //initialize the plugin
    // FlutterLocalNotificationsPlugin test = FlutterLocalNotificationsPlugin();
    await notificationsPlugin.initialize(
      settings: initializationSettings
    );

    notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
    print("End of initNotification");
  }

  //NOTIFICATIONS DETAIL SETUP
  NotificationDetails notificationDetails() {
    
    print("Beginning of NotificationDetails");
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'default_channel_id',
        'General Notifications',
        channelDescription: 'General Notification state',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
  }

    // Instant notifications
  Future<void> showNotification({
    required int notifId,
    required String notifTitle,
    required String notifBody,
  }) async {
    print("just before notificationsPlugin.show");
    const NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        '0',
        'Notification Title',
        channelDescription: 'You were notified!',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
      ),
      iOS: DarwinNotificationDetails()
    );
    await notificationsPlugin.show(
      id: 0,
      title: 'plain title',
      body: 'plain body',
      notificationDetails: notificationDetails,
      payload: 'item x',
    );
    print("just after notificationsPlugin.show");
  }

  // Future<void> showNotification() async {
  //   const AndroidNotificationDetails androidNotificationDetails =
  //       AndroidNotificationDetails(
  //         'your channel id',
  //         'your channel name',
  //         channelDescription: 'your channel description',
  //         importance: Importance.max,
  //         priority: Priority.high,
  //         ticker: 'ticker',
  //       );
  //   const NotificationDetails notificationDetails = NotificationDetails(
  //     android: androidNotificationDetails,
  //   );
  //   print("just before notificationsPlugin.show()");
  //   await notificationsPlugin.show(
  //     id: 0,
  //     title: 'plain title',
  //     body: 'plain body',
  //     notificationDetails: notificationDetails,
  //     payload: 'item x',
  //   );
  // }
}