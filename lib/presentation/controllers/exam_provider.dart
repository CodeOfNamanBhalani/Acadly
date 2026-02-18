import 'package:flutter/foundation.dart';
import '../../data/models/exam_model.dart';
import '../../services/api_service.dart';
import '../../services/notification_service.dart';

class ExamProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  final NotificationService _notificationService = NotificationService();

  List<ExamModel> _exams = [];
  bool _isLoading = false;
  String? _error;

  List<ExamModel> get exams => _exams;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<ExamModel> get upcomingExams {
    final now = DateTime.now();
    return _exams.where((e) => e.examDate.isAfter(now)).toList();
  }

  List<ExamModel> get pastExams {
    final now = DateTime.now();
    return _exams.where((e) => e.examDate.isBefore(now)).toList();
  }

  ExamModel? get nextExam {
    final upcoming = upcomingExams;
    return upcoming.isNotEmpty ? upcoming.first : null;
  }

  Future<void> loadExams() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _api.getExams();

    if (result.isSuccess && result.data != null) {
      final List<dynamic> data = result.data is List ? result.data : [];
      _exams = data.map((json) => ExamModel.fromJson(json)).toList();
      _exams.sort((a, b) => a.examDate.compareTo(b.examDate));
      _error = null;
    } else {
      _error = result.errorMessage;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addExam({
    required String examName,
    required String subject,
    required DateTime examDate,
    required String examTime,
    required String examLocation,
    String? notes,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    // Combine date and time for API
    final timeParts = examTime.split(':');
    final combinedDateTime = DateTime(
      examDate.year,
      examDate.month,
      examDate.day,
      int.tryParse(timeParts[0]) ?? 0,
      int.tryParse(timeParts.length > 1 ? timeParts[1] : '0') ?? 0,
    );

    final result = await _api.createExam(
      subject: subject,
      examType: examName,
      examDate: combinedDateTime.toIso8601String(),
      room: examLocation,
      notes: notes,
    );

    print('Create exam result: ${result.isSuccess}, data: ${result.data}');

    if (result.isSuccess) {
      // Reload all exams from API to ensure we have the latest
      await loadExams();
      return true;
    } else {
      _error = result.errorMessage;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateExam(ExamModel exam) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _api.updateExam(
      id: exam.id,
      subject: exam.subject,
      examType: exam.examName,
      examDate: exam.examDate.toIso8601String(),
      room: exam.examLocation,
      notes: exam.notes,
    );

    if (result.isSuccess) {
      final index = _exams.indexWhere((e) => e.id == exam.id);
      if (index != -1) {
        _exams[index] = exam;
      }
      _exams.sort((a, b) => a.examDate.compareTo(b.examDate));

      // Reschedule exam alerts
      await _notificationService.cancelExamAlerts(exam.id);
      await _notificationService.scheduleExamAlert(
        examId: exam.id,
        examName: exam.examName,
        subject: exam.subject,
        examDate: exam.examDate,
        location: exam.examLocation,
      );

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

  Future<bool> deleteExam(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _api.deleteExam(id);

    if (result.isSuccess) {
      await _notificationService.cancelExamAlerts(id);
      _exams.removeWhere((e) => e.id == id);
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
}
