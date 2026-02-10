import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../data/database/database_service.dart';
import '../../data/models/assignment_model.dart';
import '../../services/notification_service.dart';

class AssignmentProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  final NotificationService _notificationService = NotificationService();
  final Uuid _uuid = const Uuid();

  List<AssignmentModel> _assignments = [];
  bool _isLoading = false;
  String _filter = 'All'; // All, Pending, Completed

  List<AssignmentModel> get assignments {
    switch (_filter) {
      case 'Pending':
        return _assignments.where((a) => a.status == 'Pending').toList();
      case 'Completed':
        return _assignments.where((a) => a.status == 'Completed').toList();
      default:
        return _assignments;
    }
  }

  List<AssignmentModel> get allAssignments => _assignments;
  bool get isLoading => _isLoading;
  String get filter => _filter;

  List<AssignmentModel> get upcomingAssignments {
    final now = DateTime.now();
    return _assignments
        .where((a) => a.status == 'Pending' && a.dueDate.isAfter(now))
        .take(5)
        .toList();
  }

  int get pendingCount => _assignments.where((a) => a.status == 'Pending').length;
  int get overdueCount => _assignments.where((a) => a.isOverdue).length;

  void setFilter(String filter) {
    _filter = filter;
    notifyListeners();
  }

  void loadAssignments(String userId) {
    _assignments = _db.getAssignmentsForUser(userId);
    notifyListeners();
  }

  Future<void> addAssignment({
    required String userId,
    required String title,
    required String subject,
    required DateTime dueDate,
    required String priority,
    String? description,
    int? customReminderMinutes,
  }) async {
    _isLoading = true;
    notifyListeners();

    final assignment = AssignmentModel(
      id: _uuid.v4(),
      title: title,
      subject: subject,
      dueDate: dueDate,
      priority: priority,
      status: 'Pending',
      userId: userId,
      createdAt: DateTime.now(),
      description: description,
      customReminderMinutes: customReminderMinutes,
    );

    await _db.addAssignment(assignment);
    _assignments.add(assignment);
    _assignments.sort((a, b) => a.dueDate.compareTo(b.dueDate));

    // Schedule reminders
    await _notificationService.scheduleAssignmentReminders(
      assignmentId: assignment.id,
      title: assignment.title,
      subject: assignment.subject,
      dueDate: assignment.dueDate,
      customReminderMinutes: customReminderMinutes,
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateAssignment(AssignmentModel assignment) async {
    await _db.updateAssignment(assignment);
    final index = _assignments.indexWhere((a) => a.id == assignment.id);
    if (index != -1) {
      _assignments[index] = assignment;
    }
    _assignments.sort((a, b) => a.dueDate.compareTo(b.dueDate));

    // Reschedule reminders
    await _notificationService.cancelAssignmentReminders(assignment.id);
    if (assignment.status == 'Pending') {
      await _notificationService.scheduleAssignmentReminders(
        assignmentId: assignment.id,
        title: assignment.title,
        subject: assignment.subject,
        dueDate: assignment.dueDate,
        customReminderMinutes: assignment.customReminderMinutes,
      );
    }

    notifyListeners();
  }

  Future<void> toggleAssignmentStatus(AssignmentModel assignment) async {
    final newStatus = assignment.status == 'Pending' ? 'Completed' : 'Pending';
    final updated = assignment.copyWith(status: newStatus);

    // Optimistic update - update UI immediately
    final index = _assignments.indexWhere((a) => a.id == assignment.id);
    if (index != -1) {
      _assignments[index] = updated;
      notifyListeners();
    }

    // Then persist to database and handle notifications in background
    await _db.updateAssignment(updated);
    _assignments.sort((a, b) => a.dueDate.compareTo(b.dueDate));

    // Handle notifications
    await _notificationService.cancelAssignmentReminders(assignment.id);
    if (updated.status == 'Pending') {
      await _notificationService.scheduleAssignmentReminders(
        assignmentId: updated.id,
        title: updated.title,
        subject: updated.subject,
        dueDate: updated.dueDate,
        customReminderMinutes: updated.customReminderMinutes,
      );
    }

    notifyListeners();
  }

  Future<void> deleteAssignment(String id) async {
    await _db.deleteAssignment(id);
    await _notificationService.cancelAssignmentReminders(id);
    _assignments.removeWhere((a) => a.id == id);
    notifyListeners();
  }
}

