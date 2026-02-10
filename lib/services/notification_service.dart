import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
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

    // Request permissions for Android 13+
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    // You can navigate to specific screens based on payload
  }

  // Show immediate notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'campus_companion_channel',
      'Campus Companion',
      channelDescription: 'Notifications for Campus Companion App',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, details, payload: payload);
  }

  // Schedule notification for specific time
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    if (scheduledDate.isBefore(DateTime.now())) {
      return; // Don't schedule past notifications
    }

    const androidDetails = AndroidNotificationDetails(
      'campus_companion_scheduled',
      'Scheduled Reminders',
      channelDescription: 'Scheduled notifications for reminders',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  // Schedule assignment reminder (1 day before and 1 hour before)
  Future<void> scheduleAssignmentReminders({
    required String assignmentId,
    required String title,
    required String subject,
    required DateTime dueDate,
    int? customReminderMinutes,
  }) async {
    final baseId = assignmentId.hashCode;

    // 1 day before reminder
    final oneDayBefore = dueDate.subtract(const Duration(days: 1));
    if (oneDayBefore.isAfter(DateTime.now())) {
      await scheduleNotification(
        id: baseId,
        title: '📚 Assignment Due Tomorrow',
        body: '$title ($subject) is due tomorrow!',
        scheduledDate: oneDayBefore,
        payload: 'assignment:$assignmentId',
      );
    }

    // 1 hour before reminder
    final oneHourBefore = dueDate.subtract(const Duration(hours: 1));
    if (oneHourBefore.isAfter(DateTime.now())) {
      await scheduleNotification(
        id: baseId + 1,
        title: '⏰ Assignment Due in 1 Hour',
        body: '$title ($subject) is due in 1 hour!',
        scheduledDate: oneHourBefore,
        payload: 'assignment:$assignmentId',
      );
    }

    // Custom reminder if set
    if (customReminderMinutes != null) {
      final customReminder = dueDate.subtract(Duration(minutes: customReminderMinutes));
      if (customReminder.isAfter(DateTime.now())) {
        await scheduleNotification(
          id: baseId + 2,
          title: '🔔 Assignment Reminder',
          body: '$title ($subject) is due in $customReminderMinutes minutes!',
          scheduledDate: customReminder,
          payload: 'assignment:$assignmentId',
        );
      }
    }
  }

  // Schedule exam alert
  Future<void> scheduleExamAlert({
    required String examId,
    required String examName,
    required String subject,
    required DateTime examDate,
    required String location,
  }) async {
    final baseId = examId.hashCode + 10000;

    // 1 day before
    final oneDayBefore = examDate.subtract(const Duration(days: 1));
    if (oneDayBefore.isAfter(DateTime.now())) {
      await scheduleNotification(
        id: baseId,
        title: '📝 Exam Tomorrow',
        body: '$examName ($subject) tomorrow at $location',
        scheduledDate: oneDayBefore,
        payload: 'exam:$examId',
      );
    }

    // 2 hours before
    final twoHoursBefore = examDate.subtract(const Duration(hours: 2));
    if (twoHoursBefore.isAfter(DateTime.now())) {
      await scheduleNotification(
        id: baseId + 1,
        title: '🚨 Exam in 2 Hours',
        body: '$examName ($subject) at $location',
        scheduledDate: twoHoursBefore,
        payload: 'exam:$examId',
      );
    }
  }

  // Schedule class reminder (10 min before)
  Future<void> scheduleClassReminder({
    required String timetableId,
    required String subjectName,
    required String roomNumber,
    required DateTime classTime,
  }) async {
    final tenMinBefore = classTime.subtract(const Duration(minutes: 10));
    if (tenMinBefore.isAfter(DateTime.now())) {
      await scheduleNotification(
        id: timetableId.hashCode + 20000,
        title: '🏫 Class in 10 minutes',
        body: '$subjectName at Room $roomNumber',
        scheduledDate: tenMinBefore,
        payload: 'class:$timetableId',
      );
    }
  }

  // Cancel specific notification
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  // Cancel assignment reminders
  Future<void> cancelAssignmentReminders(String assignmentId) async {
    final baseId = assignmentId.hashCode;
    await _notifications.cancel(baseId);
    await _notifications.cancel(baseId + 1);
    await _notifications.cancel(baseId + 2);
  }

  // Cancel exam alerts
  Future<void> cancelExamAlerts(String examId) async {
    final baseId = examId.hashCode + 10000;
    await _notifications.cancel(baseId);
    await _notifications.cancel(baseId + 1);
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}

