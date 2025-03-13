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
    // Здесь можно реализовать навигацию по экрану при нажатии на уведомление
  }

  /// Запланировать уведомления, повторяющиеся каждый день в 12:00 и 21:00.
  Future<void> scheduleDailyReminder() async {
    // Общий стиль для уведомлений
    final now = tz.TZDateTime.now(tz.local);

    // --- Уведомление на 12:00 ---
    var scheduleDateNoon = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      12,
      0,
    );
    if (scheduleDateNoon.isBefore(now)) {
      scheduleDateNoon = scheduleDateNoon.add(const Duration(days: 1));
    }

    // Креативный стиль для дневного уведомления
    final BigTextStyleInformation bigTextStyleNoon = BigTextStyleInformation(
      'День – отличный повод проверить своё здоровье и сделать шаг к лучшей версии себя!',
      htmlFormatBigText: true,
      contentTitle: 'Полдень – время обновления!',
      htmlFormatContentTitle: true,
      summaryText: 'Ежедневное напоминание для вашего здоровья',
      htmlFormatSummaryText: true,
    );

    final AndroidNotificationDetails androidNoonDetails =
    AndroidNotificationDetails(
      'daily_health_channel_noon',
      'Ежедневный контроль здоровья (день)',
      channelDescription: 'Дневное напоминание для заботы о вашем здоровье',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      styleInformation: bigTextStyleNoon,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    final NotificationDetails notifNoonDetails = NotificationDetails(
      android: androidNoonDetails,
      iOS: iosDetails,
    );

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      12345, // id уведомления для 12:00
      'Полдень – время обновления!',
      'Пришло время проверить свои показатели и сделать паузу для заботы о себе!',
      scheduleDateNoon,
      notifNoonDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      // Повторяем каждый день в указанное время:
      matchDateTimeComponents: DateTimeComponents.time,
    );

    // --- Уведомление на 21:00 ---
    var scheduleDateEvening = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      21,
      0,
    );
    if (scheduleDateEvening.isBefore(now)) {
      scheduleDateEvening = scheduleDateEvening.add(const Duration(days: 1));
    }

    // Креативный стиль для вечернего уведомления
    final BigTextStyleInformation bigTextStyleEvening = BigTextStyleInformation(
      'Вечер – прекрасное время подвести итоги дня и настроиться на завтрашние победы!',
      htmlFormatBigText: true,
      contentTitle: 'Ночь для заботы о себе!',
      htmlFormatContentTitle: true,
      summaryText: 'Ежедневное напоминание для вашего здоровья',
      htmlFormatSummaryText: true,
    );

    final AndroidNotificationDetails androidEveningDetails =
    AndroidNotificationDetails(
      'daily_health_channel_evening',
      'Ежедневный контроль здоровья (вечер)',
      channelDescription: 'Вечернее напоминание для заботы о вашем здоровье',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      styleInformation: bigTextStyleEvening,
    );

    final NotificationDetails notifEveningDetails = NotificationDetails(
      android: androidEveningDetails,
      iOS: iosDetails,
    );

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      12346, // id уведомления для 21:00
      'Ночь для заботы о себе!',
      'Вечер – отличное время подвести итоги дня и настроиться на завтрашние победы!',
      scheduleDateEvening,
      notifEveningDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Отменить уведомления (если надо)
  Future<void> cancelReminder() async {
    await _flutterLocalNotificationsPlugin.cancel(12345);
    await _flutterLocalNotificationsPlugin.cancel(12346);
  }
}
