import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../data/database/database_service.dart';
import '../../data/models/exam_model.dart';
import '../../services/notification_service.dart';

class ExamProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  final NotificationService _notificationService = NotificationService();
  final Uuid _uuid = const Uuid();

  List<ExamModel> _exams = [];
  bool _isLoading = false;

  List<ExamModel> get exams => _exams;
  bool get isLoading => _isLoading;

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

  void loadExams(String userId) {
    _exams = _db.getExamsForUser(userId);
    notifyListeners();
  }

  Future<void> addExam({
    required String userId,
    required String examName,
    required String subject,
    required DateTime examDate,
    required String examTime,
    required String examLocation,
    String? notes,
  }) async {
    _isLoading = true;
    notifyListeners();

    final exam = ExamModel(
      id: _uuid.v4(),
      examName: examName,
      subject: subject,
      examDate: examDate,
      examTime: examTime,
      examLocation: examLocation,
      userId: userId,
      createdAt: DateTime.now(),
      notes: notes,
    );

    await _db.addExam(exam);
    _exams.add(exam);
    _exams.sort((a, b) => a.examDate.compareTo(b.examDate));

    // Schedule exam alerts
    await _notificationService.scheduleExamAlert(
      examId: exam.id,
      examName: exam.examName,
      subject: exam.subject,
      examDate: exam.examDate,
      location: exam.examLocation,
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateExam(ExamModel exam) async {
    await _db.updateExam(exam);
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

    notifyListeners();
  }

  Future<void> deleteExam(String id) async {
    await _db.deleteExam(id);
    await _notificationService.cancelExamAlerts(id);
    _exams.removeWhere((e) => e.id == id);
    notifyListeners();
  }
}

