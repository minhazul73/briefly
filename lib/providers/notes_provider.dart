import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/note_model.dart';
import '../services/firestore_service.dart';

/// Central state container for notes. All screens and widgets read from here;
/// none call Firestore directly.
class NotesProvider extends ChangeNotifier {
  NotesProvider() {
    _subscribeToNotes();
  }

  // ── State ─────────────────────────────────────────────────────────────────

  List<NoteModel> _notes = [];
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;
  StreamSubscription<List<NoteModel>>? _subscription;

  List<NoteModel> get notes => List.unmodifiable(_notes);
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  // ── Internal ──────────────────────────────────────────────────────────────

  void _subscribeToNotes() {
    _subscription = FirestoreService.instance.streamNotes().listen(
      (notes) {
        _notes = notes;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (Object error) {
        _isLoading = false;
        _errorMessage = error.toString();
        notifyListeners();
      },
    );
  }

  // ── Public mutations ──────────────────────────────────────────────────────

  /// Adds a new note. Returns [true] on success so the screen can pop.
  Future<bool> addNote(String title, String description) async {
    return _runSave(
      () => FirestoreService.instance.addNote(title, description),
    );
  }

  /// Updates an existing note. Returns [true] on success.
  Future<bool> updateNote(String id, String title, String description) async {
    return _runSave(
      () => FirestoreService.instance.updateNote(id, title, description),
    );
  }

  /// Deletes a note. Returns [true] on success.
  Future<bool> deleteNote(String id) async {
    // Optimistically remove from local list to prevent Dismissible tree assertions
    _notes = _notes.where((n) => n.id != id).toList();
    // notifyListeners() will be called immediately by _runSave
    return _runSave(() => FirestoreService.instance.deleteNote(id));
  }

  /// Clears the current error so it won't be shown again after the snackbar.
  void clearError() {
    _errorMessage = null;
    // No notifyListeners needed — callers check errorMessage once then clear it.
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  Future<bool> _runSave(Future<void> Function() action) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await action();
      _isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isSaving = false;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
