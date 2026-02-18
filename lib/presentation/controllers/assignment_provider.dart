import 'package:flutter/foundation.dart';
import '../../data/models/assignment_model.dart';
import '../../services/api_service.dart';
import '../../services/notification_service.dart';

class AssignmentProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  final NotificationService _notificationService = NotificationService();

  List<AssignmentModel> _assignments = [];
  bool _isLoading = false;
  String? _error;
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
  String? get error => _error;
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

  Future<void> loadAssignments() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _api.getAssignments();

    if (result.isSuccess && result.data != null) {
      final List<dynamic> data = result.data is List ? result.data : [];
      _assignments = data.map((json) => AssignmentModel.fromJson(json)).toList();
      _assignments.sort((a, b) => a.dueDate.compareTo(b.dueDate));
      _error = null;
    } else {
      _error = result.errorMessage;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addAssignment({
    required String title,
    required String subject,
    required DateTime dueDate,
    required String priority,
    String? description,
    int? customReminderMinutes,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _api.createAssignment(
      title: title,
      subject: subject,
      description: description,
      dueDate: dueDate.toIso8601String(),
      status: 'Pending',
      priority: priority,
    );

    print('Create assignment result: ${result.isSuccess}, data: ${result.data}');

    if (result.isSuccess) {
      // Reload all assignments from API to ensure we have the latest
      await loadAssignments();
      return true;
    } else {
      _error = result.errorMessage;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateAssignment(AssignmentModel assignment) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _api.updateAssignment(
      id: assignment.id,
      title: assignment.title,
      subject: assignment.subject,
      description: assignment.description,
      dueDate: assignment.dueDate.toIso8601String(),
      status: assignment.status,
      priority: assignment.priority,
    );

    if (result.isSuccess) {
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

  Future<bool> toggleAssignmentStatus(AssignmentModel assignment) async {
    final newStatus = assignment.status == 'Pending' ? 'Completed' : 'Pending';
    final updated = assignment.copyWith(status: newStatus);

    // Optimistic update - update UI immediately
    final index = _assignments.indexWhere((a) => a.id == assignment.id);
    if (index != -1) {
      _assignments[index] = updated;
      notifyListeners();
    }

    // Try using the complete endpoint if marking complete
    ApiResponse result;
    if (newStatus == 'Completed') {
      result = await _api.completeAssignment(assignment.id);
    } else {
      result = await _api.updateAssignment(
        id: assignment.id,
        title: assignment.title,
        subject: assignment.subject,
        description: assignment.description,
        dueDate: assignment.dueDate.toIso8601String(),
        status: newStatus,
        priority: assignment.priority,
      );
    }

    if (result.isSuccess) {
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
      return true;
    } else {
      // Revert optimistic update
      if (index != -1) {
        _assignments[index] = assignment;
        notifyListeners();
      }
      _error = result.errorMessage;
      return false;
    }
  }

  Future<bool> deleteAssignment(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _api.deleteAssignment(id);

    if (result.isSuccess) {
      await _notificationService.cancelAssignmentReminders(id);
      _assignments.removeWhere((a) => a.id == id);
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
