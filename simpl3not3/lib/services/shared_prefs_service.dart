import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note_model.dart';

class SharedPrefsService {
  static const String _notesKey = 'notes_data_v1';

  Future<List<Note>> getNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_notesKey);
    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((e) => Note.fromJson(e)).toList();
    }
    return [];
  }

  Future<void> saveNotes(List<Note> notes) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = notes.map((e) => e.toJson()).toList();
    await prefs.setString(_notesKey, jsonEncode(jsonList));
  }

  Future<void> saveNote(Note note) async {
    final notes = await getNotes();
    final index = notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      notes[index] = note; // Update existing
    } else {
      notes.insert(0, note); // Add new at the beginning
    }
    // Sort by updated time (newest first)
    notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    await saveNotes(notes);
  }

  Future<void> deleteNote(String id) async {
    final notes = await getNotes();
    notes.removeWhere((e) => e.id == id);
    await saveNotes(notes);
  }
}
