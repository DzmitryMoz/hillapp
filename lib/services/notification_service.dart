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

    const DarwinInitializationSettings iOSSettings =
    DarwinInitializationSettings();

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

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    // Преобразование DateTime в tz.TZDateTime с учетом локальной временной зоны
    final tz.TZDateTime tzScheduledDate =
    tz.TZDateTime.from(scheduledDate, tz.local);

    // Настраиваем стиль уведомления с большим изображением (иконка таблетки)
    final BigPictureStyleInformation bigPictureStyleInformation =
    BigPictureStyleInformation(
      DrawableResourceAndroidBitmap('@mipmap/pill_icon'),
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
    DarwinNotificationDetails(
      attachments: [DarwinNotificationAttachment('pill_icon.png')],
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
