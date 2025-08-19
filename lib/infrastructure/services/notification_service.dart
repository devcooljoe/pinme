import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'pinme_reminders';
  static const String _channelName = 'Location Reminders';
  static const String _channelDescription =
      'Notifications for location-based reminders';

  static Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    await _createNotificationChannel();
  }

  static Future<void> _createNotificationChannel() async {
    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      showBadge: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(androidChannel);
  }

  static Future<void> showReminderNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      actions: [
        AndroidNotificationAction(
          'mark_done',
          'Mark Done',
          titleColor: Color.fromARGB(255, 0, 255, 0),
        ),
        AndroidNotificationAction(
          'snooze',
          'Snooze 15m',
          titleColor: Color.fromARGB(255, 255, 165, 0),
        ),
        AndroidNotificationAction(
          'disable',
          'Disable',
          titleColor: Color.fromARGB(255, 255, 0, 0),
        ),
      ],
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      categoryIdentifier: 'reminder_category',
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, details, payload: payload);
  }

  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  static void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    final actionId = response.actionId;

    if (payload == null) return;

    switch (actionId) {
      case 'mark_done':
        _handleMarkDone(payload);
        break;
      case 'snooze':
        _handleSnooze(payload);
        break;
      case 'disable':
        _handleDisable(payload);
        break;
      default:
        _handleDefaultTap(payload);
    }
  }

  static void _handleMarkDone(String reminderId) {
    // Mark reminder as completed (could disable temporarily)
    if (kDebugMode) print('Marking reminder $reminderId as done');
  }

  static void _handleSnooze(String reminderId) {
    // Snooze for 15 minutes
    if (kDebugMode) print('Snoozing reminder $reminderId for 15 minutes');
  }

  static void _handleDisable(String reminderId) {
    // Disable the reminder
    if (kDebugMode) print('Disabling reminder $reminderId');
  }

  static void _handleDefaultTap(String reminderId) {
    // Open app to reminder details
    if (kDebugMode) print('Opening reminder $reminderId');
  }

  static Future<bool> requestPermissions() async {
    final androidImplementation =
        _notifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    if (androidImplementation != null) {
      return await androidImplementation.requestNotificationsPermission() ??
          false;
    }

    final iosImplementation =
        _notifications
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >();

    if (iosImplementation != null) {
      return await iosImplementation.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }

    return false;
  }
}
