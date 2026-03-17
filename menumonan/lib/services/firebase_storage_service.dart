// Firebase Storage Service cho upload/download files and images
import 'dart:io' show File;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageService {
  final FirebaseStorage _storageInstance = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser?.uid ?? 'anonymous';

  /// Upload image file to Firebase Storage
  /// Returns download URL of the uploaded image
  Future<String> uploadImage({
    required File imageFile,
    required String noteId,
  }) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_image.jpg';
      final storageRef = _storageInstance
          .ref()
          .child('users')
          .child(_userId)
          .child('notes')
          .child(noteId)
          .child('images')
          .child(fileName);

      await storageRef.putFile(imageFile);
      final downloadUrl = await storageRef.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      rethrow;
    }
  }

  /// Upload file to Firebase Storage
  /// Returns download URL of the uploaded file
  Future<String> uploadFile({
    required File file,
    required String noteId,
    required String fileName,
  }) async {
    try {
      final uniqueFileName = '${DateTime.now().millisecondsSinceEpoch}_$fileName';
      final storageRef = _storageInstance
          .ref()
          .child('users')
          .child(_userId)
          .child('notes')
          .child(noteId)
          .child('files')
          .child(uniqueFileName);

      await storageRef.putFile(file);
      final downloadUrl = await storageRef.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading file: $e');
      rethrow;
    }
  }

  /// Upload multiple images to Firebase Storage
  /// Returns list of download URLs
  Future<List<String>> uploadImages({
    required List<File> imageFiles,
    required String noteId,
  }) async {
    try {
      final List<String> downloadUrls = [];

      for (var imageFile in imageFiles) {
        final url = await uploadImage(
          imageFile: imageFile,
          noteId: noteId,
        );
        downloadUrls.add(url);
      }

      return downloadUrls;
    } catch (e) {
      print('Error uploading images: $e');
      rethrow;
    }
  }

  /// Upload multiple files to Firebase Storage
  /// Returns list of download URLs
  Future<List<String>> uploadFiles({
    required List<File> files,
    required String noteId,
  }) async {
    try {
      final List<String> downloadUrls = [];

      for (var file in files) {
        final fileName = file.path.split('/').last;
        final url = await uploadFile(
          file: file,
          noteId: noteId,
          fileName: fileName,
        );
        downloadUrls.add(url);
      }

      return downloadUrls;
    } catch (e) {
      print('Error uploading files: $e');
      rethrow;
    }
  }

  /// Delete image from Firebase Storage
  Future<void> deleteImage({
    required String noteId,
    required String imageUrl,
  }) async {
    try {
      final ref = _storageInstance.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      print('Error deleting image: $e');
      rethrow;
    }
  }

  /// Delete file from Firebase Storage
  Future<void> deleteFile({
    required String noteId,
    required String fileUrl,
  }) async {
    try {
      final ref = _storageInstance.refFromURL(fileUrl);
      await ref.delete();
    } catch (e) {
      print('Error deleting file: $e');
      rethrow;
    }
  }

  /// Delete all files attached to a note
  Future<void> deleteNoteAttachments(String noteId) async {
    try {
      final storageRef = _storageInstance
          .ref()
          .child('users')
          .child(_userId)
          .child('notes')
          .child(noteId);

      // Delete all files in this folder
      await storageRef.delete();
    } catch (e) {
      print('Error deleting note attachments: $e');
      rethrow;
    }
  }

  /// Get file size (in bytes)
  Future<int> getFileSize(String fileUrl) async {
    try {
      final ref = _storageInstance.refFromURL(fileUrl);
      final metadata = await ref.getMetadata();
      return metadata.size ?? 0;
    } catch (e) {
      print('Error getting file size: $e');
      return 0;
    }
  }
}
