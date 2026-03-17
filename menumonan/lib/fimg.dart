import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'models/note.dart';

class FileImageHelper {
  static final ImagePicker _imagePicker = ImagePicker();

  static Future<void> pickImage(Note note, VoidCallback onUpdate) async {
    if (kIsWeb) {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.single;
        final bytes = file.bytes;
        if (bytes != null) {
          final ext = file.extension ?? 'png';
          final dataUri = 'data:image/$ext;base64,${base64Encode(bytes)}';
          note.imagePaths.add(dataUri);
          onUpdate();
        }
      }
    } else {
      final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        note.imagePaths.add(image.path);
        onUpdate();
      }
    }
  }

  static Future<void> pickFile(Note note, VoidCallback onUpdate) async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(withData: true);
    if (result != null && result.files.isNotEmpty) {
      final f = result.files.single;
      if (kIsWeb) {
        if (f.bytes != null) {
          final ext = f.extension ?? 'bin';
          final dataUri = 'data:application/$ext;base64,${base64Encode(f.bytes!)}';
          note.filePaths.add(dataUri);
        } else {
          note.filePaths.add(f.name);
        }
      } else {
        final path = f.path;
        if (path != null && path.isNotEmpty) {
          note.filePaths.add(path);
        } else {
          note.filePaths.add(f.name);
        }
      }
      onUpdate();
    }
  }
}
