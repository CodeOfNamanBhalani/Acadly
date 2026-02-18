import 'package:flutter/foundation.dart';

import '../../data/models/note_model.dart';
import '../../services/api_service.dart';

class NoteProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  // Notes List
  List<NoteModel> _notes = [];

  // Search List
  List<NoteModel> _searchResults = [];

  // States
  bool _isLoading = false;
  bool _isSearching = false;
  String? _error;

  String _searchQuery = '';

  // Getters
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  String? get error => _error;
  String get searchQuery => _searchQuery;

  List<NoteModel> get notes =>
      _isSearching ? _searchResults : _notes;

  // ----------------------------
  // LOAD NOTES
  // ----------------------------
  Future<void> loadNotes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _api.getNotes();

    if (result.isSuccess && result.data != null) {
      final List<dynamic> data = result.data is List ? result.data : [];
      _notes = data.map((json) => NoteModel.fromJson(json)).toList();
      // Sort latest updated first
      _notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      _error = null;
    } else {
      _error = result.errorMessage;
    }

    _isLoading = false;
    notifyListeners();
  }

  // ----------------------------
  // SEARCH NOTES
  // ----------------------------
  void searchNotes(String query) {
    _searchQuery = query;

    if (query.isEmpty) {
      _isSearching = false;
      _searchResults = [];
    } else {
      _isSearching = true;
      final lowerQuery = query.toLowerCase();
      _searchResults = _notes
          .where((n) =>
              n.title.toLowerCase().contains(lowerQuery) ||
              n.content.toLowerCase().contains(lowerQuery))
          .toList();
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
  Future<bool> addNote({
    required String title,
    required String content,
    String? color,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _api.createNote(
      title: title,
      content: content,
    );

    print('Create note result: ${result.isSuccess}, data: ${result.data}');

    if (result.isSuccess) {
      // Reload all notes from API to ensure we have the latest
      await loadNotes();
      return true;
    } else {
      _error = result.errorMessage;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ----------------------------
  // UPDATE NOTE
  // ----------------------------
  Future<bool> updateNote(NoteModel note) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _api.updateNote(
      id: note.id,
      title: note.title,
      content: note.content,
    );

    if (result.isSuccess) {
      final updatedNote = note.copyWith(updatedAt: DateTime.now());
      final index = _notes.indexWhere((n) => n.id == note.id);

      if (index != -1) {
        _notes[index] = updatedNote;
      }

      // Sort again after update
      _notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
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

  // ----------------------------
  // DELETE NOTE
  // ----------------------------
  Future<bool> deleteNote(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _api.deleteNote(id);

    if (result.isSuccess) {
      _notes.removeWhere((n) => n.id == id);
      _searchResults.removeWhere((n) => n.id == id);
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
