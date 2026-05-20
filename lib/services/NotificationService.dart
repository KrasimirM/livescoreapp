import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _matchChannel =
      AndroidNotificationChannel(
    'match_reminders',
    'Match reminders',
    description: 'Notifications before saved football matches',
    importance: Importance.high,
  );
  static const Duration _matchReminderOffset = Duration(minutes: 30);

  static Future<void> initialize() async {
    tz_data.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _notifications.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );

    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_matchChannel);
    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.requestExactAlarmsPermission();

    await _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  static Future<void> scheduleMatchReminder(Map match) async {
    final matchId = match['id']?.toString();
    final rawDate = match['utcDate']?.toString();
    if (matchId == null || matchId.isEmpty || rawDate == null) {
      throw StateError('Match data is missing notification fields.');
    }

    final kickoff = DateTime.tryParse(rawDate);
    if (kickoff == null) {
      throw StateError('Match kickoff date is invalid.');
    }

    final now = DateTime.now().toUtc();
    final kickoffTime = kickoff.toUtc();
    final reminderTime = kickoffTime.subtract(_matchReminderOffset);
    if (!kickoff.toUtc().isAfter(now)) {
      throw StateError('Reminder time has already passed.');
    }

    final homeTeam = match['homeTeam'] ?? {};
    final awayTeam = match['awayTeam'] ?? {};
    final homeName =
        (homeTeam['shortName'] ?? homeTeam['name'] ?? 'Home').toString();
    final awayName =
        (awayTeam['shortName'] ?? awayTeam['name'] ?? 'Away').toString();

    final notificationId = _notificationId(matchId);
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'match_reminders',
        'Match reminders',
        channelDescription: 'Notifications before saved football matches',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        category: AndroidNotificationCategory.reminder,
        enableVibration: true,
        playSound: true,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _notifications.cancel(notificationId);
    await _notifications.show(
      notificationId,
      'Notification set',
      'You set notification for $homeName vs $awayName.',
      details,
    );

    try {
      if (reminderTime.isAfter(now)) {
        await _notifications.zonedSchedule(
          _reminderNotificationId(matchId),
          '$homeName vs $awayName starts soon',
          'Kickoff is in 30 minutes.',
          tz.TZDateTime.from(reminderTime, tz.UTC),
          details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      }

      await _notifications.zonedSchedule(
        _kickoffNotificationId(matchId),
        '$homeName vs $awayName starts soon',
        'Kickoff is now.',
        tz.TZDateTime.from(kickoffTime, tz.UTC),
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      print('Error scheduling future match notifications: $e');
    }

    final pending = await _notifications.pendingNotificationRequests();
    print('Pending match notifications: ${pending.length}');
  }

  static Future<void> cancelMatchReminder(Map match) async {
    final matchId = match['id']?.toString();
    if (matchId == null || matchId.isEmpty) return;
    await _notifications.cancel(_notificationId(matchId));
    await _notifications.cancel(_reminderNotificationId(matchId));
    await _notifications.cancel(_kickoffNotificationId(matchId));
  }

  static int _notificationId(String matchId) {
    final parsed = int.tryParse(matchId);
    if (parsed != null) return parsed & 0x7fffffff;

    var hash = 0;
    for (final codeUnit in matchId.codeUnits) {
      hash = (hash * 31 + codeUnit) & 0x7fffffff;
    }
    return hash;
  }

  static int _reminderNotificationId(String matchId) {
    return (_notificationId(matchId) + 100000) & 0x7fffffff;
  }

  static int _kickoffNotificationId(String matchId) {
    return (_notificationId(matchId) + 200000) & 0x7fffffff;
  }
}
