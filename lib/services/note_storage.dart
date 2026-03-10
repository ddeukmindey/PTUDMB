import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartnote/models/note.dart';

class NoteStorage {
  static const _key = 'smartnote_notes_v1';

  Future<List<Note>> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_key);
    if (s == null || s.isEmpty) return [];
    try {
      return Note.listFromJson(s);
    } catch (_) {
      return [];
    }
  }

  Future<void> saveNotes(List<Note> notes) async {
    final prefs = await SharedPreferences.getInstance();
    final s = Note.listToJson(notes);
    await prefs.setString(_key, s);
  }

  Future<void> addOrUpdateNote(Note note) async {
    final notes = await loadNotes();
    final idx = notes.indexWhere((n) => n.id == note.id);
    if (idx >= 0) {
      notes[idx] = note;
    } else {
      notes.insert(0, note);
    }
    await saveNotes(notes);
  }

  Future<void> deleteNote(String id) async {
    final notes = await loadNotes();
    // remove files belonging to the note from storage directory
    final removed = notes.where((n) => n.id == id).toList();
    for (var note in removed) {
      for (var p in [...note.imagePaths, ...note.filePaths]) {
        try {
          final f = File(p);
          if (await f.exists()) await f.delete();
        } catch (_) {}
      }
    }
    notes.removeWhere((n) => n.id == id);
    await saveNotes(notes);
  }
}
