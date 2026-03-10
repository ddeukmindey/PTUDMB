// Example: Integrating Firebase into SmartNote UI
// This shows how to use FirebaseNoteService in your widgets

import 'package:flutter/material.dart';
import 'package:smartnote/models/note.dart';
import 'package:smartnote/services/firebase_note_service.dart';
import 'package:smartnote/services/firebase_auth_service.dart';

class FirebaseNoteScreenExample extends StatefulWidget {
  const FirebaseNoteScreenExample({super.key});

  @override
  State<FirebaseNoteScreenExample> createState() =>
      _FirebaseNoteScreenExampleState();
}

class _FirebaseNoteScreenExampleState extends State<FirebaseNoteScreenExample> {
  final FirebaseNoteService _noteService = FirebaseNoteService();
  final FirebaseAuthService _authService = FirebaseAuthService();

  @override
  void initState() {
    super.initState();
    _checkUserLogin();
  }

  void _checkUserLogin() {
    // Check if user is logged in
    if (_authService.currentUser == null) {
      // Redirect to login screen
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes (Firebase)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.signOut();
              if (mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
        ],
      ),
      body: _buildNotesList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateNoteDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  // Display notes using real-time stream
  Widget _buildNotesList() {
    return StreamBuilder<List<Note>>(
      stream: _noteService.getNotes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        final notes = snapshot.data ?? [];

        if (notes.isEmpty) {
          return const Center(
            child: Text('No notes yet. Create one!'),
          );
        }

        return ListView.builder(
          itemCount: notes.length,
          itemBuilder: (context, index) {
            final note = notes[index];
            return _NoteCard(
              note: note,
              onDelete: () => _deleteNote(note.id),
              onEdit: () => _showEditNoteDialog(note),
            );
          },
        );
      },
    );
  }

  // Show dialog to create note
  void _showCreateNoteDialog() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Note'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: contentController,
              decoration: const InputDecoration(labelText: 'Content'),
              maxLines: 5,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final note = Note(
                id: DateTime.now().toString(),
                title: titleController.text,
                content: contentController.text,
                updatedAt: DateTime.now(),
              );

              try {
                await _noteService.createNote(note);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Note created!')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  // Show dialog to edit note
  void _showEditNoteDialog(Note note) {
    final titleController = TextEditingController(text: note.title);
    final contentController = TextEditingController(text: note.content);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Note'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: contentController,
              decoration: const InputDecoration(labelText: 'Content'),
              maxLines: 5,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final updatedNote = Note(
                id: note.id,
                title: titleController.text,
                content: contentController.text,
                updatedAt: DateTime.now(),
                imagePaths: note.imagePaths,
                filePaths: note.filePaths,
              );

              try {
                await _noteService.updateNote(updatedNote);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Note updated!')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  // Delete a note
  Future<void> _deleteNote(String noteId) async {
    try {
      await _noteService.deleteNote(noteId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note deleted!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}

// Simple note card widget
class _NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _NoteCard({
    required this.note,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        title: Text(
          note.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          note.content,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              onTap: onEdit,
              child: const Text('Edit'),
            ),
            PopupMenuItem(
              onTap: onDelete,
              child: const Text('Delete'),
            ),
          ],
        ),
      ),
    );
  }
}
