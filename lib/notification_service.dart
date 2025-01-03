import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  factory NotificationService() => _instance;

  const NotificationService._();

  static const NotificationService _instance = NotificationService._();

  static final _localNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();

    await _localNotificationsPlugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@drawable/ic_noti'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (resp) {},
    );
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    Map<String, dynamic>? payload,
  }) async {
    // logger.i('scheduledDate: $scheduledDate');
    log('tzLocal: ${tz.local}');
    final scheduledDateTime = tz.TZDateTime.from(scheduledDate, tz.local);

    await _localNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDateTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_quotes_channel_id',
          'Daily Quotes',
          icon: '@drawable/ic_noti',
        ),
        iOS: DarwinNotificationDetails(
          sound: 'assets/notification.mp3',
        ),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: jsonEncode(payload),
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}
