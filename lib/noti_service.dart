import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotiService {
  final notificationsPlugin = FlutterLocalNotificationsPlugin();

  final bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  

  //INITIAlIZE
  Future<void> initNotification() async {
    
    if (_isInitialized) return; //prevent re-initialization
    //prepare android init settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher'); //FLUTTER ICON - CHANGE LATER
    //prepare ios init settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // init settings
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    //initialize the plugin
    // FlutterLocalNotificationsPlugin test = FlutterLocalNotificationsPlugin();
    await notificationsPlugin.initialize(initSettings);
    print("End of initNotification");
  }

  //NOTIFICATIONS DETAIL SETUP
  NotificationDetails notificationDetails() {
    
    print("Beginning of NotificationDetails");
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_channel_id', 
        'Daily Notifications',
        channelDescription: 'Daily Notification Channel',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
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
  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    await notificationsPlugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'instant_notification_channel_id',
          'Instant Notifications',
          channelDescription: 'Instant notification channel',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails())
    );
  }
  }
  //ON NOTI TAP