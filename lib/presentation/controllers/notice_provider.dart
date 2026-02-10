import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../data/database/database_service.dart';
import '../../data/models/notice_model.dart';

class NoticeProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  final Uuid _uuid = const Uuid();

  List<NoticeModel> _notices = [];
  bool _isLoading = false;

  List<NoticeModel> get notices => _notices;
  bool get isLoading => _isLoading;

  List<NoticeModel> get importantNotices =>
      _notices.where((n) => n.isImportant).toList();

  List<NoticeModel> get recentNotices =>
      _notices.take(5).toList();

  void loadNotices() {
    _notices = _db.getAllNotices();
    notifyListeners();
  }

  Future<void> addNotice({
    required String title,
    required String description,
    required String postedBy,
    bool isImportant = false,
  }) async {
    _isLoading = true;
    notifyListeners();

    final notice = NoticeModel(
      id: _uuid.v4(),
      title: title,
      description: description,
      datePosted: DateTime.now(),
      postedBy: postedBy,
      isImportant: isImportant,
    );

    await _db.addNotice(notice);
    _notices.insert(0, notice);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateNotice(NoticeModel notice) async {
    await _db.updateNotice(notice);
    final index = _notices.indexWhere((n) => n.id == notice.id);
    if (index != -1) {
      _notices[index] = notice;
    }
    notifyListeners();
  }

  Future<void> deleteNotice(String id) async {
    await _db.deleteNotice(id);
    _notices.removeWhere((n) => n.id == id);
    notifyListeners();
  }
}

