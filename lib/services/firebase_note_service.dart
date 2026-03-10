// Firebase Firestore Service for SmartNote
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smartnote/models/note.dart';

class FirebaseNoteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser?.uid ?? 'anonymous';

  // Create a new note
  Future<void> createNote(Note note) async {
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('notes')
          .doc(note.id)
          .set({
        'id': note.id,
        'title': note.title,
        'content': note.content,
        'updatedAt': note.updatedAt.toIso8601String(),
        'imagePaths': note.imagePaths,
        'filePaths': note.filePaths,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error creating note: $e');
      rethrow;
    }
  }

  // Update an existing note
  Future<void> updateNote(Note note) async {
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('notes')
          .doc(note.id)
          .update({
        'title': note.title,
        'content': note.content,
        'imagePaths': note.imagePaths,
        'filePaths': note.filePaths,
        'updatedAt': note.updatedAt.toIso8601String(),
      });
    } catch (e) {
      print('Error updating note: $e');
      rethrow;
    }
  }

  // Delete a note
  Future<void> deleteNote(String noteId) async {
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('notes')
          .doc(noteId)
          .delete();
    } catch (e) {
      print('Error deleting note: $e');
      rethrow;
    }
  }

  // Get all notes for current user as a stream
  Stream<List<Note>> getNotes() {
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('notes')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Note.fromJson(doc.data()))
          .toList();
    });
  }

  // Search notes by title or content
  Future<List<Note>> searchNotes(String query) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('notes')
          .get();

      return snapshot.docs
          .map((doc) => Note.fromJson(doc.data()))
          .where((note) =>
              note.title.toLowerCase().contains(query.toLowerCase()) ||
              note.content.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } catch (e) {
      print('Error searching notes: $e');
      rethrow;
    }
  }

  // Get notes by tag
  Future<List<Note>> getNotesByTag(String tag) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('notes')
          .get();

      return snapshot.docs
          .map((doc) => Note.fromJson(doc.data()))
          .where((note) =>
              note.title.toLowerCase().contains(tag.toLowerCase()) ||
              note.content.toLowerCase().contains(tag.toLowerCase()))
          .toList();
    } catch (e) {
      print('Error getting notes by tag: $e');
      rethrow;
    }
  }

  // Batch update notes
  Future<void> batchUpdateNotes(List<Note> notes) async {
    try {
      WriteBatch batch = _firestore.batch();
      for (Note note in notes) {
        final docRef = _firestore
            .collection('users')
            .doc(_userId)
            .collection('notes')
            .doc(note.id);
        batch.update(docRef, note.toJson());
      }
      await batch.commit();
    } catch (e) {
      print('Error batch updating notes: $e');
      rethrow;
    }
  }
}
