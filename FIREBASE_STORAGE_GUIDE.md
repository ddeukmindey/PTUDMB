# 📸 Firebase Storage - Hướng dẫn Upload File và Ảnh

## 📋 Tổng quan

SmartNote vẫn hỗ trợ **100%** việc đính kèm file và ảnh vào ghi chú, với hai cách:

### 1️⃣ **Local Storage** (Local)
- Lưu file/ảnh cục bộ trên thiết bị
- Không cần internet để xem
- Sử dụng `NoteStorage` class

### 2️⃣ **Firebase Storage** (Cloud)
- Lưu file/ảnh trên đám mây Firebase
- Sync giữa các thiết bị
- Không bị mất khi xóa app
- Sử dụng `FirebaseStorageService` class

---

## 🚀 Cách Sử dụng Firebase Storage

### Step 1: Import Services

```dart
import 'package:smartnote/services/firebase_storage_service.dart';
import 'package:smartnote/services/firebase_note_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io' show File;
```

### Step 2: Khởi tạo Services

```dart
final storageService = FirebaseStorageService();
final noteService = FirebaseNoteService();
final imagePicker = ImagePicker();
```

---

## 📸 Upload Ảnh

### Upload 1 ảnh từ Gallery

```dart
Future<void> pickAndUploadImage() async {
  final pickedFile = await imagePicker.pickImage(
    source: ImageSource.gallery,
    imageQuality: 85,
  );
  
  if (pickedFile != null) {
    final imageFile = File(pickedFile.path);
    
    // Upload to Firebase Storage
    final imageUrl = await storageService.uploadImage(
      imageFile: imageFile,
      noteId: note.id,
    );
    
    // Add URL to note
    note.imagePaths.add(imageUrl);
    
    // Save to Firestore
    await noteService.updateNote(note);
    
    print('Image uploaded: $imageUrl');
  }
}
```

### Chụp ảnh từ Camera

```dart
Future<void> captureImage() async {
  final pickedFile = await imagePicker.pickImage(
    source: ImageSource.camera,
    imageQuality: 85,
  );
  
  if (pickedFile != null) {
    final imageFile = File(pickedFile.path);
    final imageUrl = await storageService.uploadImage(
      imageFile: imageFile,
      noteId: note.id,
    );
    
    note.imagePaths.add(imageUrl);
    await noteService.updateNote(note);
  }
}
```

### Upload Nhiều ảnh

```dart
Future<void> pickMultipleImages() async {
  final pickedFiles = await imagePicker.pickMultiImage(
    imageQuality: 85,
  );
  
  if (pickedFiles.isNotEmpty) {
    final imageFiles = pickedFiles.map((p) => File(p.path)).toList();
    
    // Upload all images
    final imageUrls = await storageService.uploadImages(
      imageFiles: imageFiles,
      noteId: note.id,
    );
    
    note.imagePaths.addAll(imageUrls);
    await noteService.updateNote(note);
    
    print('Uploaded ${imageUrls.length} images');
  }
}
```

### Hiển thị ảnh đã upload

```dart
// In a ListView or GridView
ListView.builder(
  itemCount: note.imagePaths.length,
  itemBuilder: (context, index) {
    final imageUrl = note.imagePaths[index];
    
    return Image.network(
      imageUrl,
      width: 200,
      height: 200,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const CircularProgressIndicator();
      },
      errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.error);
      },
    );
  },
)
```

### Xóa ảnh

```dart
Future<void> deleteImage(String imageUrl) async {
  // Delete from Firebase Storage
  await storageService.deleteImage(
    noteId: note.id,
    imageUrl: imageUrl,
  );
  
  // Remove from note
  note.imagePaths.remove(imageUrl);
  
  // Update Firestore
  await noteService.updateNote(note);
}
```

---

## 📁 Upload Files

### Upload 1 file

```dart
Future<void> pickAndUploadFile() async {
  final result = await FilePicker.platform.pickFiles();
  
  if (result != null) {
    final file = File(result.files.single.path!);
    final fileName = result.files.single.name;
    
    // Upload to Firebase Storage
    final fileUrl = await storageService.uploadFile(
      file: file,
      noteId: note.id,
      fileName: fileName,
    );
    
    // Add URL to note
    note.filePaths.add(fileUrl);
    
    // Save to Firestore
    await noteService.updateNote(note);
  }
}
```

### Upload Nhiều files

```dart
Future<void> pickMultipleFiles() async {
  final result = await FilePicker.platform.pickFiles(
    allowMultiple: true,
  );
  
  if (result != null && result.files.isNotEmpty) {
    final files = result.files
        .map((f) => File(f.path!))
        .toList();
    
    // Upload all files
    final fileUrls = await storageService.uploadFiles(
      files: files,
      noteId: note.id,
    );
    
    note.filePaths.addAll(fileUrls);
    await noteService.updateNote(note);
  }
}
```

### Hiển thị danh sách file

```dart
ListView.builder(
  itemCount: note.filePaths.length,
  itemBuilder: (context, index) {
    final fileUrl = note.filePaths[index];
    final fileName = fileUrl.split('/').last;
    
    return ListTile(
      leading: const Icon(Icons.file_present),
      title: Text(fileName),
      onTap: () {
        // Mở file (có thể dùng url_launcher)
        // launchUrl(Uri.parse(fileUrl));
      },
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () => deleteFile(fileUrl),
      ),
    );
  },
)
```

### Xóa file

```dart
Future<void> deleteFile(String fileUrl) async {
  // Delete from Firebase Storage
  await storageService.deleteFile(
    noteId: note.id,
    fileUrl: fileUrl,
  );
  
  // Remove from note
  note.filePaths.remove(fileUrl);
  
  // Update Firestore
  await noteService.updateNote(note);
}
```

---

## 🌐 Firestore Structure

```
users/{userId}/
  notes/{noteId}/
    - title: string
    - content: string
    - imagePaths: [
        "https://firebaseStorage.../image1.jpg",
        "https://firebaseStorage.../image2.jpg"
      ]
    - filePaths: [
        "https://firebaseStorage.../document.pdf",
        "https://firebaseStorage.../report.xlsx"
      ]
    - updatedAt: timestamp
```

---

## 📊 Firebase Storage Structure

```
users/{userId}/notes/
  {noteId}/
    images/
      1234567890_image.jpg
      1234567891_image.jpg
    files/
      1234567890_document.pdf
      1234567891_presentation.pptx
```

---

## ⚙️ Cấu hình Firebase Storage

### 1. Bật Firebase Storage
```
Firebase Console → Storage → Get Started
```

### 2. Set Security Rules

**Test Mode** (Development):
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /users/{userId}/{allPaths=**} {
      allow read, write: if request.auth.uid == userId;
    }
  }
}
```

**Production Mode**:
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Only allow authenticated users
    match /users/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // Limit file size (10MB)
      allow write: if request.resource.size <= 10 * 1024 * 1024;
      
      // Only allow image files in images folder
      match /images/{fileName} {
        allow write: if request.resource.contentType.matches('image/.*');
      }
    }
  }
}
```

---

## 🎯 FirebaseStorageService Methods

| Method | Mô tả |
|--------|-------|
| `uploadImage()` | Upload 1 ảnh |
| `uploadFile()` | Upload 1 file |
| `uploadImages()` | Upload nhiều ảnh |
| `uploadFiles()` | Upload nhiều files |
| `deleteImage()` | Xóa 1 ảnh |
| `deleteFile()` | Xóa 1 file |
| `deleteNoteAttachments()` | Xóa tất cả file của ghi chú |
| `getFileSize()` | Lấy kích thước file |

---

## 💡 Tips

### Tối ưu hóa ảnh trước upload

```dart
// Compress image quality
final pickedFile = await imagePicker.pickImage(
  source: ImageSource.gallery,
  imageQuality: 70,  // 0-100, lower = smaller file
);
```

### Xử lý Upload với Progress

```dart
// Firebase Storage hỗ trợ tracking upload progress
final task = _storageInstance
    .ref('path/to/file')
    .putFile(file);

task.snapshotEvents.listen((event) {
  double progress = event.bytesTransferred / event.totalBytes;
  print('Upload progress: ${(progress * 100).toStringAsFixed(1)}%');
});

await task;
```

### Limit Upload Size
```dart
const maxFileSize = 10 * 1024 * 1024; // 10MB

if (file.lengthSync() > maxFileSize) {
  print('File too large!');
  return;
}
```

### Batch Upload
```dart
Future<List<String>> uploadMultipleWithProgress({
  required List<File> files,
  required String noteId,
  required Function(double) onProgress,
}) async {
  final urls = <String>[];
  
  for (int i = 0; i < files.length; i++) {
    await uploadFile(files[i], noteId);
    onProgress((i + 1) / files.length);
  }
  
  return urls;
}
```

---

## 🔐 Bảo mật

### File bị lộ công khai?

```javascript
// Chỉ cho phép users xem file của mình
match /users/{userId}/{allPaths=**} {
  allow read: if request.auth.uid == userId;
}
```

### Giới hạn loại file

```javascript
match /files/{fileName} {
  // Chỉ PDF, Excel, Word
  allow write: if request.resource.contentType in [
    'application/pdf',
    'application/vnd.ms-excel',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
  ];
}
```

---

## 📚 Examples

Xem ví dụ đầy đủ tại: [firebase_file_upload_example.dart](../examples/firebase_file_upload_example.dart)

Ví dụ chi tiết các tính năng:
- ✅ Pick từ gallery
- ✅ Capture từ camera
- ✅ Pick nhiều ảnh/files
- ✅ Hiển thị uploaded files
- ✅ Xóa files
- ✅ Error handling

---

## ❓ FAQ

**Q: Nếu internet mất, ảnh có mất không?**
A: Không nếu bạn lưu local. Firebase cũng có offline persistence nhưng lưu cache tạm thời.

**Q: Tôi có thể set metadata cho file không?**
A: Có, Firebase Storage cho phép lưu metadata (mimeType, custom metadata, etc).

**Q: Chi phí upload bao nhiêu?**
A: Firebase Storage có free tier 5GB/month. Download chịu phí (~$0.12/GB).

**Q: Tôi có thể share link file với người khác không?**
A: Có, nhưng cần cấu hình Security Rules cho phép. Default chỉ user upload mới xem được.

---

**Vậy là SmartNote vẫn có đầy đủ tính năng upload file/ảnh!** 🚀
