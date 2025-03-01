import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Сервис для локальных уведомлений
class DailyReminderService {
  // Singleton
  static final DailyReminderService _instance = DailyReminderService._internal();
  factory DailyReminderService() => _instance;
  DailyReminderService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Инициализация часовых поясов
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
    DarwinInitializationSettings();

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );
  }

  // Если нужно обработать клик на уведомление:
  void _onNotificationResponse(NotificationResponse response) {
    // Можно открыть нужный экран, если используете Named Routes
    // Например:
    // if (response.payload == 'daily_health') {
    //   Navigator.pushNamed(context, '/growth_tracking');
    // }
  }

  /// Запланировать уведомление, повторяющееся каждый день в заданное [hour, minute].
  Future<void> scheduleDailyReminder({
    int hour = 9,
    int minute = 0,
  }) async {
    // Удалим старое, если нужно
    // await _flutterLocalNotificationsPlugin.cancelAll();

    // Стиль уведомления
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'daily_health_channel',
      'Ежедневный контроль здоровья',
      channelDescription: 'Напоминание вносить показатели роста/веса',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher', // Иконка приложения
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails notifDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Время для ежедневного уведомления
    // Используем локальную временную зону
    final now = tz.TZDateTime.now(tz.local);
    // Запланируем на сегодня в [hour:minute], если уже прошло — на завтра
    var scheduleDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduleDate.isBefore(now)) {
      scheduleDate = scheduleDate.add(const Duration(days: 1));
    }

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      12345, // id уведомления
      'Пора ввести показатели',
      'Не забывайте контролировать рост и вес — здоровье превыше всего!',
      scheduleDate,
      notifDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      // Повторяем раз в сутки:
      matchDateTimeComponents: DateTimeComponents.time,
      // => каждый день в [hour:minute]
    );
  }

  /// Отменить уведомление (если надо)
  Future<void> cancelReminder() async {
    await _flutterLocalNotificationsPlugin.cancel(12345);
  }
}
