import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/note_model.dart';
import '../../data/database/database_service.dart';

class NoteProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  final Uuid _uuid = const Uuid();

  // Notes List
  List<NoteModel> _notes = [];

  // Search List
  List<NoteModel> _searchResults = [];

  // States
  bool _isLoading = false;
  bool _isSearching = false;

  String _searchQuery = '';

  // Getters
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  String get searchQuery => _searchQuery;

  List<NoteModel> get notes =>
      _isSearching ? _searchResults : _notes;

  // ----------------------------
  // LOAD NOTES
  // ----------------------------
  void loadNotes(String userId) {
    _notes = _db.getNotesForUser(userId);

    // Sort latest updated first
    _notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    notifyListeners();
  }

  // ----------------------------
  // SEARCH NOTES
  // ----------------------------
  void searchNotes(String userId, String query) {
    _searchQuery = query;

    if (query.isEmpty) {
      _isSearching = false;
      _searchResults = [];
    } else {
      _isSearching = true;
      _searchResults = _db.searchNotes(userId, query);
    }

    notifyListeners();
  }

  // Clear Search
  void clearSearch() {
    _isSearching = false;
    _searchQuery = '';
    _searchResults = [];

    notifyListeners();
  }

  // ----------------------------
  // ADD NOTE
  // ----------------------------
  Future<void> addNote({
    required String userId,
    required String title,
    required String content,
    String? color,
  }) async {
    _isLoading = true;
    notifyListeners();

    final now = DateTime.now();

    final note = NoteModel(
      id: _uuid.v4(),
      userId: userId,
      title: title,
      content: content,
      color: color,
      createdAt: now,
      updatedAt: now,
    );

    await _db.addNote(note);

    // Insert newest note on top
    _notes.insert(0, note);

    _isLoading = false;
    notifyListeners();
  }

  // ----------------------------
  // UPDATE NOTE
  // ----------------------------
  Future<void> updateNote(NoteModel note) async {
    final updatedNote = note.copyWith(
      updatedAt: DateTime.now(),
    );

    await _db.updateNote(updatedNote);

    final index = _notes.indexWhere((n) => n.id == note.id);

    if (index != -1) {
      _notes[index] = updatedNote;
    }

    // Sort again after update
    _notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    notifyListeners();
  }

  // ----------------------------
  // DELETE NOTE
  // ----------------------------
  Future<void> deleteNote(String id) async {
    await _db.deleteNote(id);

    _notes.removeWhere((n) => n.id == id);
    _searchResults.removeWhere((n) => n.id == id);

    notifyListeners();
  }
}
