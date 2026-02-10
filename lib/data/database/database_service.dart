import 'dart:core';

import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_model.dart';
import '../models/timetable_model.dart';
import '../models/assignment_model.dart';
import '../models/exam_model.dart';
import '../models/note_model.dart';
import '../models/notice_model.dart';
import '../../core/constants/app_constants.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  late Box<UserModel> _usersBox;
  late Box<TimetableModel> _timetableBox;
  late Box<AssignmentModel> _assignmentsBox;
  late Box<ExamModel> _examsBox;
  late Box<NoteModel> _notesBox;
  late Box<NoticeModel> _noticesBox;
  late Box _settingsBox;

  Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(UserModelAdapter());
    Hive.registerAdapter(TimetableModelAdapter());
    Hive.registerAdapter(AssignmentModelAdapter());
    Hive.registerAdapter(ExamModelAdapter());
    Hive.registerAdapter(NoteModelAdapter());
    Hive.registerAdapter(NoticeModelAdapter());

    // Open boxes
    _usersBox = await Hive.openBox<UserModel>(AppConstants.usersBox);
    _timetableBox = await Hive.openBox<TimetableModel>(AppConstants.timetableBox);
    _assignmentsBox = await Hive.openBox<AssignmentModel>(AppConstants.assignmentsBox);
    _examsBox = await Hive.openBox<ExamModel>(AppConstants.examsBox);
    _notesBox = await Hive.openBox<NoteModel>(AppConstants.notesBox);
    _noticesBox = await Hive.openBox<NoticeModel>(AppConstants.noticesBox);
    _settingsBox = await Hive.openBox(AppConstants.settingsBox);
  }

  // ==================== USER OPERATIONS ====================

  Future<void> createUser(UserModel user) async {
    await _usersBox.put(user.id, user);
  }

  UserModel? getUserById(String id) {
    return _usersBox.get(id);
  }

  UserModel? getUserByEmail(String email) {
    try {
      return _usersBox.values.firstWhere(
        (user) => user.email.toLowerCase() == email.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  List<UserModel> getAllUsers() {
    return _usersBox.values.toList();
  }

  Future<void> updateUser(UserModel user) async {
    await _usersBox.put(user.id, user);
  }

  Future<void> deleteUser(String id) async {
    await _usersBox.delete(id);
  }

  // ==================== TIMETABLE OPERATIONS ====================

  Future<void> addTimetableEntry(TimetableModel entry) async {
    await _timetableBox.put(entry.id, entry);
  }

  List<TimetableModel> getTimetableForUser(String userId) {
    return _timetableBox.values
        .where((entry) => entry.userId == userId)
        .toList();
  }

  List<TimetableModel> getTimetableForDay(String userId, int dayOfWeek) {
    return _timetableBox.values
        .where((entry) => entry.userId == userId && entry.dayOfWeek == dayOfWeek)
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  Future<void> updateTimetableEntry(TimetableModel entry) async {
    await _timetableBox.put(entry.id, entry);
  }

  Future<void> deleteTimetableEntry(String id) async {
    await _timetableBox.delete(id);
  }

  // ==================== ASSIGNMENT OPERATIONS ====================

  Future<void> addAssignment(AssignmentModel assignment) async {
    await _assignmentsBox.put(assignment.id, assignment);
  }

  List<AssignmentModel> getAssignmentsForUser(String userId) {
    return _assignmentsBox.values
        .where((a) => a.userId == userId)
        .toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  List<AssignmentModel> getPendingAssignments(String userId) {
    return _assignmentsBox.values
        .where((a) => a.userId == userId && a.status == 'Pending')
        .toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  List<AssignmentModel> getCompletedAssignments(String userId) {
    return _assignmentsBox.values
        .where((a) => a.userId == userId && a.status == 'Completed')
        .toList()
      ..sort((a, b) => b.dueDate.compareTo(a.dueDate));
  }

  List<AssignmentModel> getUpcomingAssignments(String userId, {int limit = 5}) {
    final now = DateTime.now();
    return _assignmentsBox.values
        .where((a) => a.userId == userId &&
                      a.status == 'Pending' &&
                      a.dueDate.isAfter(now))
        .toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate))
      ..take(limit);
  }

  Future<void> updateAssignment(AssignmentModel assignment) async {
    await _assignmentsBox.put(assignment.id, assignment);
  }

  Future<void> deleteAssignment(String id) async {
    await _assignmentsBox.delete(id);
  }

  // ==================== EXAM OPERATIONS ====================

  Future<void> addExam(ExamModel exam) async {
    await _examsBox.put(exam.id, exam);
  }

  List<ExamModel> getExamsForUser(String userId) {
    return _examsBox.values
        .where((e) => e.userId == userId)
        .toList()
      ..sort((a, b) => a.examDate.compareTo(b.examDate));
  }

  List<ExamModel> getUpcomingExams(String userId) {
    final now = DateTime.now();
    return _examsBox.values
        .where((e) => e.userId == userId && e.examDate.isAfter(now))
        .toList()
      ..sort((a, b) => a.examDate.compareTo(b.examDate));
  }

  ExamModel? getNextExam(String userId) {
    final upcoming = getUpcomingExams(userId);
    return upcoming.isNotEmpty ? upcoming.first : null;
  }

  Future<void> updateExam(ExamModel exam) async {
    await _examsBox.put(exam.id, exam);
  }

  Future<void> deleteExam(String id) async {
    await _examsBox.delete(id);
  }

  // ==================== NOTES OPERATIONS ====================

  Future<void> addNote(NoteModel note) async {
    await _notesBox.put(note.id, note);
  }

  List<NoteModel> getNotesForUser(String userId) {
    return _notesBox.values
        .where((n) => n.userId == userId)
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  List<NoteModel> searchNotes(String userId, String query) {
    final lowerQuery = query.toLowerCase();
    return _notesBox.values
        .where((n) => n.userId == userId &&
                      (n.title.toLowerCase().contains(lowerQuery) ||
                       n.content.toLowerCase().contains(lowerQuery)))
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Future<void> updateNote(NoteModel note) async {
    await _notesBox.put(note.id, note);
  }

  Future<void> deleteNote(String id) async {
    await _notesBox.delete(id);
  }

  // ==================== NOTICE OPERATIONS ====================

  Future<void> addNotice(NoticeModel notice) async {
    await _noticesBox.put(notice.id, notice);
  }

  List<NoticeModel> getAllNotices() {
    return _noticesBox.values.toList()
      ..sort((a, b) => b.datePosted.compareTo(a.datePosted));
  }

  Future<void> updateNotice(NoticeModel notice) async {
    await _noticesBox.put(notice.id, notice);
  }

  Future<void> deleteNotice(String id) async {
    await _noticesBox.delete(id);
  }

  // ==================== SETTINGS OPERATIONS ====================

  Future<void> setCurrentUserId(String? userId) async {
    if (userId == null) {
      await _settingsBox.delete(AppConstants.currentUserKey);
    } else {
      await _settingsBox.put(AppConstants.currentUserKey, userId);
    }
  }

  String? getCurrentUserId() {
    return _settingsBox.get(AppConstants.currentUserKey);
  }

  Future<void> setLoggedIn(bool value) async {
    await _settingsBox.put(AppConstants.isLoggedInKey, value);
  }

  bool isLoggedIn() {
    return _settingsBox.get(AppConstants.isLoggedInKey, defaultValue: false);
  }

  UserModel? getCurrentUser() {
    final userId = getCurrentUserId();
    if (userId == null) return null;
    return getUserById(userId);
  }
}

