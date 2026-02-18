import 'package:flutter/foundation.dart';
import '../../data/models/timetable_model.dart';
import '../../services/api_service.dart';
import '../../services/notification_service.dart';

class TimetableProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  final NotificationService _notificationService = NotificationService();

  List<TimetableModel> _timetable = [];
  bool _isLoading = false;
  String? _error;

  List<TimetableModel> get timetable => _timetable;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadTimetable() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _api.getTimetable();

    if (result.isSuccess && result.data != null) {
      final List<dynamic> data = result.data is List ? result.data : [];
      _timetable = data.map((json) => TimetableModel.fromJson(json)).toList();
      _error = null;
    } else {
      _error = result.errorMessage;
    }

    _isLoading = false;
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

  Future<bool> addTimetableEntry({
    required String subjectName,
    required String facultyName,
    required int dayOfWeek,
    required String startTime,
    required String endTime,
    required String roomNumber,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _api.createTimetableEntry(
      subject: subjectName,
      dayOfWeek: dayOfWeek,
      startTime: startTime,
      endTime: endTime,
      room: roomNumber,
      teacher: facultyName,
    );

    print('Create timetable result: ${result.isSuccess}, data: ${result.data}');

    if (result.isSuccess) {
      // Reload all timetable data from API to ensure we have the latest
      await loadTimetable();
      return true;
    } else {
      _error = result.errorMessage;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTimetableEntry(TimetableModel entry) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _api.updateTimetableEntry(
      id: entry.id,
      subject: entry.subjectName,
      dayOfWeek: entry.dayOfWeek,
      startTime: entry.startTime,
      endTime: entry.endTime,
      room: entry.roomNumber,
      teacher: entry.facultyName,
    );

    if (result.isSuccess) {
      final index = _timetable.indexWhere((e) => e.id == entry.id);
      if (index != -1) {
        _timetable[index] = entry;
      }
      _scheduleClassReminder(entry);
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _error = result.errorMessage;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTimetableEntry(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _api.deleteTimetableEntry(id);

    if (result.isSuccess) {
      _timetable.removeWhere((e) => e.id == id);
      await _notificationService.cancelNotification(id.hashCode + 20000);
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _error = result.errorMessage;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _scheduleClassReminder(TimetableModel entry) {
    final now = DateTime.now();
    final currentDay = now.weekday - 1;

    int daysUntilClass = entry.dayOfWeek - currentDay;
    if (daysUntilClass < 0) {
      daysUntilClass += 7;
    } else if (daysUntilClass == 0) {
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
