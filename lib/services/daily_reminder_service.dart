import 'dart:ui'; // Для Color
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

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
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Обработка нажатия на уведомление (при необходимости)
      },
    );
  }

  /// Запланировать уведомления, повторяющиеся каждый день в 12:00 и 21:00.
  Future<void> scheduleDailyReminder() async {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);

    // --- Уведомление на 12:00 ---
    tz.TZDateTime scheduleDateNoon = tz.TZDateTime(
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

    final BigTextStyleInformation bigTextStyleNoon = BigTextStyleInformation(
      'Пора контролировать ваши показатели. Откройте приложение и узнайте, как вы справляетесь!',
      htmlFormatBigText: true,
      contentTitle: '<b>Полдень: Контроль показателей</b>',
      htmlFormatContentTitle: true,
      summaryText: 'Проверьте данные о вашем здоровье',
      htmlFormatSummaryText: true,
    );

    final AndroidNotificationDetails androidNoonDetails =
    AndroidNotificationDetails(
      'daily_health_channel_noon', // Идентификатор канала
      'Ежедневный контроль здоровья (день)', // Название канала
      channelDescription: 'Дневное уведомление для контроля здоровья',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      styleInformation: bigTextStyleNoon,
      showWhen: false,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      subtitle: 'Контроль показателей',
    );

    final NotificationDetails notifNoonDetails = NotificationDetails(
      android: androidNoonDetails,
      iOS: iosDetails,
    );

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      12345, // id уведомления для 12:00
      'Полдень: Контроль показателей',
      'Откройте приложение для проверки актуальных данных.',
      scheduleDateNoon,
      notifNoonDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    // --- Уведомление на 21:00 ---
    tz.TZDateTime scheduleDateEvening = tz.TZDateTime(
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

    final BigTextStyleInformation bigTextStyleEvening = BigTextStyleInformation(
      'Настало время ввести показатели – расскажите, как прошёл ваш день и получите рекомендации для улучшения самочувствия.',
      htmlFormatBigText: true,
      contentTitle: '<b>Вечер: Введите показатели</b>',
      htmlFormatContentTitle: true,
      summaryText: 'Введите данные о вашем здоровье',
      htmlFormatSummaryText: true,
    );

    final AndroidNotificationDetails androidEveningDetails =
    AndroidNotificationDetails(
      'daily_health_channel_evening',
      'Ежедневный контроль здоровья (вечер)',
      channelDescription: 'Вечернее уведомление для контроля здоровья',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      styleInformation: bigTextStyleEvening,
      showWhen: false,
    );

    final NotificationDetails notifEveningDetails = NotificationDetails(
      android: androidEveningDetails,
      iOS: iosDetails,
    );

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      12346, // id уведомления для 21:00
      'Вечер: Введите показатели',
      'Откройте приложение и введите данные, чтобы оценить, как прошёл ваш день.',
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
