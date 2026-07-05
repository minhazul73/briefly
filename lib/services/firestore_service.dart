import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/note_model.dart';
import '../utils/constants.dart';

/// All Firestore access lives here. Providers call this; they never import
/// cloud_firestore directly.
class FirestoreService {
  FirestoreService._();
  static final FirestoreService instance = FirestoreService._();

  final CollectionReference _col = FirebaseFirestore.instance.collection(
    AppConstants.notesCollection,
  );

  // ── Reads ──────────────────────────────────────────────────────────────────

  /// Live stream of notes ordered newest-first.
  Stream<List<NoteModel>> streamNotes() {
    return _col
        .orderBy(AppConstants.fieldCreatedAt, descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((doc) => NoteModel.fromSnapshot(doc)).toList(),
        );
  }

  // ── Writes ─────────────────────────────────────────────────────────────────

  Future<void> addNote(String title, String description) async {
    try {
      await _col.add({
        AppConstants.fieldTitle: title,
        AppConstants.fieldDescription: description,
        AppConstants.fieldCreatedAt: FieldValue.serverTimestamp(),
        AppConstants.fieldUpdatedAt: FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw Exception(_friendlyMessage(e));
    }
  }

  Future<void> updateNote(String id, String title, String description) async {
    try {
      await _col.doc(id).update({
        AppConstants.fieldTitle: title,
        AppConstants.fieldDescription: description,
        AppConstants.fieldUpdatedAt: FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw Exception(_friendlyMessage(e));
    }
  }

  Future<void> deleteNote(String id) async {
    try {
      await _col.doc(id).delete();
    } on FirebaseException catch (e) {
      throw Exception(_friendlyMessage(e));
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _friendlyMessage(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return 'Permission denied. Check your Firestore security rules.';
      case 'unavailable':
        return 'Could not reach Firestore. Check your internet connection.';
      case 'not-found':
        return 'The note no longer exists.';
      default:
        return e.message ?? 'An unexpected error occurred.';
    }
  }
}
