import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io' show File;
import 'package:flutter/foundation.dart';
import 'models/note.dart';
import 'services/note_storage.dart';
import 'fimg.dart';

class EditScreen extends StatefulWidget {
  final Note note;
  const EditScreen({super.key, required this.note});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  late Note _note;
  final NoteStorage _storage = NoteStorage();
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _note = Note(
        id: widget.note.id,
        title: widget.note.title,
        content: widget.note.content,
        updatedAt: widget.note.updatedAt,
        imagePaths: List.from(widget.note.imagePaths),
        filePaths: List.from(widget.note.filePaths));
    _titleCtrl.text = _note.title;
    _contentCtrl.text = _note.content;
  }

  void _removeImage(int index) {
    setState(() {
      _note.imagePaths.removeAt(index);
    });
  }

  void _removeFile(int index) {
    setState(() {
      _note.filePaths.removeAt(index);
    });
  }

  Future<void> _saveAndPop() async {
    _note.title = _titleCtrl.text.trim();
    _note.content = _contentCtrl.text.trim();
    _note.updatedAt = DateTime.now();
    await _storage.addOrUpdateNote(_note);
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _saveAndPop();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Soạn thảo'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          leading: IconButton(onPressed: () async {
            await _saveAndPop();
          }, icon: const Icon(Icons.arrow_back)),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(children: [
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(hintText: 'Tiêu đề', border: InputBorder.none),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              maxLines: 1,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _contentCtrl,
                      decoration: const InputDecoration(hintText: 'Viết nội dung ở đây...', border: InputBorder.none),
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      expands: false,
                    ),
                    if (_note.imagePaths.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text('Hình ảnh:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: List.generate(_note.imagePaths.length, (index) {
                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: kIsWeb
                                    ? (_note.imagePaths[index].startsWith('data:')
                                        ? Image.memory(
                                            base64Decode(_note.imagePaths[index].split(',').last),
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                          )
                                        : Image.network(
                                            _note.imagePaths[index],
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => Container(
                                              width: 100,
                                              height: 100,
                                              color: Colors.grey[300],
                                              child: const Center(child: Icon(Icons.broken_image)),
                                            ),
                                          ))
                                    : Image.file(
                                        File(_note.imagePaths[index]),
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () => _removeImage(index),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.close, color: Colors.white, size: 20),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                    ],
                    if (_note.filePaths.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text('Tệp đính kèm:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(_note.filePaths.length, (index) {
                          final fileName = _note.filePaths[index].split('/').last;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                const Icon(Icons.attach_file, size: 20, color: Colors.grey),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(fileName, overflow: TextOverflow.ellipsis),
                                ),
                                IconButton(
                                  onPressed: () => _removeFile(index),
                                  icon: const Icon(Icons.close, size: 20, color: Colors.red),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton.extended(
                  onPressed: () async {
                    await FileImageHelper.pickImage(_note, () {
                      setState(() {});
                    });
                  },
                  icon: const Icon(Icons.image),
                  label: const Text('Thêm ảnh'),
                  heroTag: 'addImage',
                ),
                FloatingActionButton.extended(
                  onPressed: () async {
                    await FileImageHelper.pickFile(_note, () {
                      setState(() {});
                    });
                  },
                  icon: const Icon(Icons.attach_file),
                  label: const Text('Thêm tệp'),
                  heroTag: 'addFile',
                ),
              ],
            ),
          ]),
        ),
      ),
    );
  }
}
