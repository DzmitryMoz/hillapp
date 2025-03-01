import 'dart:ui'; // Для Color
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  // Singleton
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Инициализация данных для работы с часовыми поясами
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iOSSettings = DarwinInitializationSettings();

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iOSSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Обработка нажатия на уведомление (при необходимости)
      },
    );
  }

  /// Метод для установки/перенастройки уведомления.
  /// Если уведомление с таким [id] уже существовало, оно отменяется и создаётся заново.
  /// Если [scheduledDate] уже прошла, можно либо не ставить уведомление, либо сдвинуть на будущее.
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    // (1) Отменяем старое уведомление с таким же id
    await flutterLocalNotificationsPlugin.cancel(id);

    // (2) Если scheduledDate уже в прошлом — решаем, что делать.
    // Допустим, просто не ставим уведомление (или можно сдвинуть на следующий день).
    final now = DateTime.now();
    if (scheduledDate.isBefore(now)) {
      // Если нужно сдвинуть на будущее — раскомментируйте:
      // scheduledDate = scheduledDate.add(const Duration(days: 1));

      // Или вообще не ставим уведомление:
      print(
          'NotificationService.scheduleNotification: время уже прошло ($scheduledDate), уведомление не установлено.');
      return;
    }

    // Преобразование DateTime в tz.TZDateTime с учётом локальной временной зоны
    final tz.TZDateTime tzScheduledDate =
    tz.TZDateTime.from(scheduledDate, tz.local);

    // Настраиваем стиль уведомления (пример с BigPictureStyleInformation)
    final BigPictureStyleInformation bigPictureStyleInformation =
    BigPictureStyleInformation(
      const DrawableResourceAndroidBitmap('@mipmap/pill_icon'),
      contentTitle: '<b>$title</b>',
      summaryText: body,
      htmlFormatContentTitle: true,
      htmlFormatSummaryText: true,
    );

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'pill_calendar_channel_id', // Идентификатор канала
      'Приёмы препаратов', // Название канала
      channelDescription: 'Уведомления для календаря таблеток',
      importance: Importance.max,
      priority: Priority.high,
      color: const Color(0xFF00B4AB),
      styleInformation: bigPictureStyleInformation,
    );

    final DarwinNotificationDetails iosPlatformChannelSpecifics =
    const DarwinNotificationDetails(
      subtitle: 'Приём препарата',
    );

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iosPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tzScheduledDate,
      platformChannelSpecifics,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,
    );
  }
}
