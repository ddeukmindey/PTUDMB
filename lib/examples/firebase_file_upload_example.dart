// Example: Upload Images and Files to Notes
import 'dart:io' show File;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:smartnote/models/note.dart';
import 'package:smartnote/services/firebase_note_service.dart';
import 'package:smartnote/services/firebase_storage_service.dart';

class FirebaseFileUploadScreenExample extends StatefulWidget {
  final Note initialNote;

  const FirebaseFileUploadScreenExample({
    super.key,
    required this.initialNote,
  });

  @override
  State<FirebaseFileUploadScreenExample> createState() =>
      _FirebaseFileUploadScreenExampleState();
}

class _FirebaseFileUploadScreenExampleState
    extends State<FirebaseFileUploadScreenExample> {
  final FirebaseNoteService _noteService = FirebaseNoteService();
  final FirebaseStorageService _storageService = FirebaseStorageService();
  final ImagePicker _imagePicker = ImagePicker();

  late Note _note;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _note = widget.initialNote;
  }

  /// Pick single image from gallery
  Future<void> _pickImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        await _uploadImage(File(pickedFile.path));
      }
    } catch (e) {
      _showErrorDialog('Error picking image: $e');
    }
  }

  /// Capture image from camera
  Future<void> _captureImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        await _uploadImage(File(pickedFile.path));
      }
    } catch (e) {
      _showErrorDialog('Error capturing image: $e');
    }
  }

  /// Upload single image to Firebase Storage
  Future<void> _uploadImage(File imageFile) async {
    if (_isUploading) return;

    setState(() => _isUploading = true);

    try {
      final imageUrl = await _storageService.uploadImage(
        imageFile: imageFile,
        noteId: _note.id,
      );

      // Add image URL to note
      setState(() {
        _note.imagePaths.add(imageUrl);
      });

      // Update note in Firestore
      await _noteService.updateNote(_note);

      _showSuccessMessage('Image uploaded successfully!');
    } catch (e) {
      _showErrorDialog('Error uploading image: $e');
    } finally {
      setState(() => _isUploading = false);
    }
  }

  /// Pick and upload multiple images
  Future<void> _pickMultipleImages() async {
    try {
      final pickedFiles = await _imagePicker.pickMultiImage(
        imageQuality: 85,
      );

      if (pickedFiles.isNotEmpty) {
        final imageFiles = pickedFiles.map((p) => File(p.path)).toList();
        await _uploadMultipleImages(imageFiles);
      }
    } catch (e) {
      _showErrorDialog('Error picking images: $e');
    }
  }

  /// Upload multiple images
  Future<void> _uploadMultipleImages(List<File> imageFiles) async {
    if (_isUploading) return;

    setState(() => _isUploading = true);

    try {
      final imageUrls = await _storageService.uploadImages(
        imageFiles: imageFiles,
        noteId: _note.id,
      );

      // Add image URLs to note
      setState(() {
        _note.imagePaths.addAll(imageUrls);
      });

      // Update note in Firestore
      await _noteService.updateNote(_note);

      _showSuccessMessage(
          'Successfully uploaded ${imageUrls.length} images!');
    } catch (e) {
      _showErrorDialog('Error uploading images: $e');
    } finally {
      setState(() => _isUploading = false);
    }
  }

  /// Pick and upload files
  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
      );

      if (result != null && result.files.isNotEmpty) {
        final files = result.files
            .map((f) => File(f.path!))
            .toList();
        await _uploadFiles(files);
      }
    } catch (e) {
      _showErrorDialog('Error picking files: $e');
    }
  }

  /// Upload multiple files
  Future<void> _uploadFiles(List<File> files) async {
    if (_isUploading) return;

    setState(() => _isUploading = true);

    try {
      final fileUrls = await _storageService.uploadFiles(
        files: files,
        noteId: _note.id,
      );

      // Add file URLs to note
      setState(() {
        _note.filePaths.addAll(fileUrls);
      });

      // Update note in Firestore
      await _noteService.updateNote(_note);

      _showSuccessMessage(
          'Successfully uploaded ${fileUrls.length} files!');
    } catch (e) {
      _showErrorDialog('Error uploading files: $e');
    } finally {
      setState(() => _isUploading = false);
    }
  }

  /// Delete image
  Future<void> _deleteImage(String imageUrl, int index) async {
    try {
      await _storageService.deleteImage(
        noteId: _note.id,
        imageUrl: imageUrl,
      );

      setState(() {
        _note.imagePaths.removeAt(index);
      });

      await _noteService.updateNote(_note);
      _showSuccessMessage('Image deleted!');
    } catch (e) {
      _showErrorDialog('Error deleting image: $e');
    }
  }

  /// Delete file
  Future<void> _deleteFile(String fileUrl, int index) async {
    try {
      await _storageService.deleteFile(
        noteId: _note.id,
        fileUrl: fileUrl,
      );

      setState(() {
        _note.filePaths.removeAt(index);
      });

      await _noteService.updateNote(_note);
      _showSuccessMessage('File deleted!');
    } catch (e) {
      _showErrorDialog('Error deleting file: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Note with Files'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image picker buttons
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Images',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _isUploading ? null : _pickImage,
                          icon: const Icon(Icons.image),
                          label: const Text('Pick Image'),
                        ),
                        ElevatedButton.icon(
                          onPressed: _isUploading ? null : _captureImage,
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Capture'),
                        ),
                        ElevatedButton.icon(
                          onPressed: _isUploading ? null : _pickMultipleImages,
                          icon: const Icon(Icons.collections),
                          label: const Text('Multiple'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Display uploaded images
            if (_note.imagePaths.isNotEmpty) ...[
              const Text(
                'Uploaded Images',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _note.imagePaths.length,
                  itemBuilder: (context, index) {
                    final imageUrl = _note.imagePaths[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              imageUrl,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () =>
                                  _deleteImage(imageUrl, index),
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(4),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],

            // File picker buttons
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Files',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _isUploading ? null : _pickFiles,
                      icon: const Icon(Icons.attach_file),
                      label: const Text('Attach Files'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Display attached files
            if (_note.filePaths.isNotEmpty) ...[
              const Text(
                'Attached Files',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _note.filePaths.length,
                itemBuilder: (context, index) {
                  final fileUrl = _note.filePaths[index];
                  final fileName = fileUrl.split('/').last.split('?').first;

                  return ListTile(
                    leading: const Icon(Icons.file_present),
                    title: Text(fileName),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () =>
                          _deleteFile(fileUrl, index),
                    ),
                    onTap: () {
                      // Open file (implement as needed)
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Opening: $fileName'),
                        ),
                      );
                    },
                  );
                },
              ),
            ],

            const SizedBox(height: 24),

            // Upload status indicator
            if (_isUploading)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text('Uploading...'),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
