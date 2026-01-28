import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotiService {
  NotiService._internal();
  static final NotiService _instance = NotiService._internal();
  factory NotiService() => _instance;

  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  // INITIALIZE
  Future<void> initNotif() async {
    if (_isInitialized) return;

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosInit = IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await notificationsPlugin.initialize(initSettings);

    _isInitialized = true;
    print('✅ Notifications initialized');
  }

  // NOTIFICATION DETAILS
  NotificationDetails _notificationDetails() {
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

  // SHOW NOTIFICATION
  Future<void> showNotification({
    int id = 0,
    String? title,
    String? body,
  }) async {
    if (!_isInitialized) {
      print('⚠️ NotiService not initialized');
      return;
    }

      await notificationsPlugin.show(
      id,
      title,
      body,
      _notificationDetails(),
    );
  }
}