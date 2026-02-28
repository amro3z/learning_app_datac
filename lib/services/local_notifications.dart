import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotifications {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static late GlobalKey<NavigatorState> navigatorKey;

  /// Initialize notifications
  static Future<void> init(GlobalKey<NavigatorState> key) async {
    navigatorKey = key;

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        );

    await flutterLocalNotificationsPlugin.initialize(
    settings: initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        if (response.payload != null) {
          final data = jsonDecode(response.payload!);

          navigatorKey.currentState?.pushNamed(
            data['route'],
            arguments: Map<String, dynamic>.from(data['arguments'] ?? {}),
          );
        }
      },
    );
  }

  /// Show notification with full arguments
  static Future<void> showNotification({
    required String title,
    required String body,
    required bool navigator,
    Map<String, dynamic>? arguments,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'enroll_channel_id',
          'Enrollment Notifications',
          channelDescription: 'Notifications for course enrollments',
          importance: Importance.max,
          priority: Priority.high,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    final payload = jsonEncode({
      'route': '/course_details',
      'arguments': arguments,
    });

    await flutterLocalNotificationsPlugin.show(
      id: 0,
      title: title,
      body: body  ,
     notificationDetails: notificationDetails,
      payload:navigator? payload : 'payload',
    );
  }
}
