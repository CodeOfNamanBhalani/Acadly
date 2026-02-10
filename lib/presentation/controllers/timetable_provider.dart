import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../data/database/database_service.dart';
import '../../data/models/timetable_model.dart';
import '../../services/notification_service.dart';

class TimetableProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  final NotificationService _notificationService = NotificationService();
  final Uuid _uuid = const Uuid();

  List<TimetableModel> _timetable = [];
  bool _isLoading = false;

  List<TimetableModel> get timetable => _timetable;
  bool get isLoading => _isLoading;

  void loadTimetable(String userId) {
    _timetable = _db.getTimetableForUser(userId);
    notifyListeners();
  }

  List<TimetableModel> getTimetableForDay(int dayOfWeek) {
    return _timetable
        .where((entry) => entry.dayOfWeek == dayOfWeek)
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  List<TimetableModel> getTodayClasses() {
    final today = DateTime.now().weekday - 1; // Monday = 0
    return getTimetableForDay(today);
  }

  Future<void> addTimetableEntry({
    required String userId,
    required String subjectName,
    required String facultyName,
    required int dayOfWeek,
    required String startTime,
    required String endTime,
    required String roomNumber,
  }) async {
    _isLoading = true;
    notifyListeners();

    final entry = TimetableModel(
      id: _uuid.v4(),
      subjectName: subjectName,
      facultyName: facultyName,
      dayOfWeek: dayOfWeek,
      startTime: startTime,
      endTime: endTime,
      roomNumber: roomNumber,
      userId: userId,
    );

    await _db.addTimetableEntry(entry);
    _timetable.add(entry);

    // Schedule class reminder
    _scheduleClassReminder(entry);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateTimetableEntry(TimetableModel entry) async {
    await _db.updateTimetableEntry(entry);
    final index = _timetable.indexWhere((e) => e.id == entry.id);
    if (index != -1) {
      _timetable[index] = entry;
    }

    // Reschedule class reminder
    _scheduleClassReminder(entry);

    notifyListeners();
  }

  Future<void> deleteTimetableEntry(String id) async {
    await _db.deleteTimetableEntry(id);
    _timetable.removeWhere((e) => e.id == id);
    await _notificationService.cancelNotification(id.hashCode + 20000);
    notifyListeners();
  }

  void _scheduleClassReminder(TimetableModel entry) {
    // Calculate next occurrence of this class
    final now = DateTime.now();
    final currentDay = now.weekday - 1;

    int daysUntilClass = entry.dayOfWeek - currentDay;
    if (daysUntilClass < 0) {
      daysUntilClass += 7;
    } else if (daysUntilClass == 0) {
      // Check if class time has passed today
      final timeParts = entry.startTime.split(':');
      final classTime = DateTime(
        now.year, now.month, now.day,
        int.parse(timeParts[0]), int.parse(timeParts[1]),
      );
      if (now.isAfter(classTime)) {
        daysUntilClass = 7;
      }
    }

    final timeParts = entry.startTime.split(':');
    final nextClassDate = DateTime(
      now.year, now.month, now.day + daysUntilClass,
      int.parse(timeParts[0]), int.parse(timeParts[1]),
    );

    _notificationService.scheduleClassReminder(
      timetableId: entry.id,
      subjectName: entry.subjectName,
      roomNumber: entry.roomNumber,
      classTime: nextClassDate,
    );
  }
}

