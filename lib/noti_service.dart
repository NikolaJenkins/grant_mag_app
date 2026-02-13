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
    await notificationsPlugin.initialize(initializationSettings);
    print("End of initNotification");
  }

  //NOTIFICATIONS DETAIL SETUP
  NotificationDetails notificationDetails() {
    
    print("Beginning of NotificationDetails");
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'default_channel_id',
        'General Notifications',
        'General Notification state',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: IOSNotificationDetails(),
    );
  }

  //SHOW NOTIFICATIONS
  // Future<void> showNotification({
  //   int id = 0,
  //   String? title,
  //   String? body,
  //   }) async {
  //     print("Just before returning notificationPlugin.show");
  //     return notificationsPlugin.show(
  //       id, 
  //       title, 
  //       body, 
  //       const NotificationDetails(),
  //     );

    // Instant notifications
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    print("just before notificationsPlugin.show");
    await notificationsPlugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'instant_notification_channel_id',
          'Instant Notifications',
          'Instant notification channel',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: IOSNotificationDetails())
    );
    print("just after notificationsPlugin.show");
  }
}