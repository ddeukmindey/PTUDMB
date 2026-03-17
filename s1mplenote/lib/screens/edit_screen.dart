import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/note.dart';
import '../services/storage_service.dart';

class EditScreen extends StatefulWidget {
  final Note? note;

  const EditScreen({super.key, this.note});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  final StorageService _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController =
        TextEditingController(text: widget.note?.content ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    // Do not save if both are empty and user didn't enter anything new
    if (title.isEmpty && content.isEmpty && widget.note == null) {
      return;
    }

    // if note is existing and hasn't changed, don't save
    if (widget.note != null &&
        title == widget.note!.title &&
        content == widget.note!.content) {
      return;
    }

    final now = DateTime.now();

    if (widget.note == null) {
      // Create new
      final newNote = Note(
        id: const Uuid().v4(),
        title: title,
        content: content,
        createdAt: now,
        updatedAt: now,
      );
      await _storageService.addOrUpdateNote(newNote);
    } else {
      // Update existing
      final updatedNote = widget.note!.copyWith(
        title: title,
        content: content,
        updatedAt: now,
      );
      await _storageService.addOrUpdateNote(updatedNote);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
      },
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () async {
              await _saveNote();
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Tiêu đề',
                    hintStyle: TextStyle(
                      color: Colors.black38,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    border: InputBorder.none,
                  ),
                  textInputAction: TextInputAction.next,
                ),
                Expanded(
                  child: TextField(
                    controller: _contentController,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    decoration: const InputDecoration(
                      hintText: 'Ghi chú văn bản...',
                      hintStyle: TextStyle(color: Colors.black38),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
