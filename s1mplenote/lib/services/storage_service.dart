import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note.dart';

class StorageService {
  static const String _notesKey = 'notes_data';

  Future<List<Note>> getNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final String? notesString = prefs.getString(_notesKey);

    if (notesString == null || notesString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> decodedList = jsonDecode(notesString);
      return decodedList.map((item) => Note.fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveNotes(List<Note> notes) async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedList = jsonEncode(notes.map((e) => e.toJson()).toList());
    await prefs.setString(_notesKey, encodedList);
  }

  Future<void> addOrUpdateNote(Note note) async {
    final List<Note> notes = await getNotes();
    final index = notes.indexWhere((n) => n.id == note.id);

    if (index != -1) {
      notes[index] = note;
    } else {
      notes.insert(0, note); // Insert new notes at the top
    }

    await saveNotes(notes);
  }

  Future<void> deleteNote(String id) async {
    final List<Note> notes = await getNotes();
    notes.removeWhere((n) => n.id == id);
    await saveNotes(notes);
  }
}
