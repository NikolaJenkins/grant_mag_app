import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotiService {
  final notificationsPlugin = FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  

  //INITIAlIZE
  Future<void> initNotif() async {
    
    if (_isInitialized) return; //prevent re-initialization
    //prepare android init settings
    const initSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher'); //FLUTTER ICON - CHANGE LATER
    //prepare ios init settings
    const initSettingsIOS = IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // init settings
    const initsettings = InitializationSettings(
      android: initSettingsAndroid,
      iOS: initSettingsIOS,
    );

    //initialize the plugin
    FlutterLocalNotificationsPlugin test = FlutterLocalNotificationsPlugin();
    await test.initialize(const InitializationSettings(
      android: initSettingsAndroid,
      iOS: initSettingsIOS
    ));
    print("End of initNotif");
  }
  //NOTIFICATIONS DETAIL SETUP
  NotificationDetails notificationDetails() {
    
    print("Beginning of NotificationDetails");
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_channel_id', 
        'Daily Notifications',
        'Daily Notification Channel',
        importance: Importance.max,
        //priority: Priority.high,
      ),
      iOS: IOSNotificationDetails(),
    );
  }
  //SHOW NOTIFICATIONS
  Future<void> showNotification({
    int id = 0,
    String? title,
    String? body,
    }) async {
      print("Just before returning notificationPlugin.show");
      return notificationsPlugin.show(
        id, 
        title, 
        body, 
        const NotificationDetails(),
      );
  }
  }
  //ON NOTI TAP