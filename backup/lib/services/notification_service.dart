import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  late FlutterLocalNotificationsPlugin _plugin;

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  Future<void> init() async {
    _plugin = FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings android =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings ios = DarwinInitializationSettings();

    const InitializationSettings settings = InitializationSettings(
      android: android,
      iOS: ios,
    );

    await _plugin.initialize(settings);
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails android = AndroidNotificationDetails(
      'astroview_channel',
      'AstroView Notifications',
      channelDescription: 'Notifications for new APOD images',
      importance: Importance.max,
      priority: Priority.high,
    );

    const DarwinNotificationDetails ios = DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: android,
      iOS: ios,
    );

    await _plugin.show(id, title, body, details);
  }
}