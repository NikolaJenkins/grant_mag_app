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
    const initSettingsIOS = DarwinInitializationSettings(
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
    await notificationsPlugin.initialize(initSettings);
  }
  //NOTIFICATIONS DETAIL SETUP

  //SHOW NOTIFICATIONS

  //ON NOTI TAP
}