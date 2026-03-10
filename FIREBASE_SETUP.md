# 📱 Hướng dẫn Tích hợp Firebase vào SmartNote

## ✅ Kiểm tra Môi trường

### Kết quả Kiểm tra:
- **Flutter**: ✅ 3.38.7 (Stable)
- **Dart**: ✅ 3.10.7
- **Windows**: ✅ Version 11
- **Chrome**: ✅ Sẵn sàng
- **Android**: ❌ Chưa cài (không bắt buộc cho web/windows)
- **Visual Studio**: ✅ Community 2022

## 📦 Dependencies đã thêm

Các package Firebase sau đã được thêm vào `pubspec.yaml`:

```yaml
firebase_core: ^3.10.0        # Core Firebase SDK
cloud_firestore: ^5.3.0       # Cloud Database
firebase_auth: ^5.3.0         # Authentication
firebase_storage: ^12.0.0     # File Storage
```

Tất cả dependencies đã được download và cài đặt thành công.

## 🔧 Cấu hình Firebase

### Bước 1: Tạo Firebase Project
1. Truy cập [Firebase Console](https://console.firebase.google.com/)
2. Click **"Create a new project"**
3. Nhập tên project: `smartnote` (hoặc theo ý bạn)
4. Chấp nhận điều khoản và tạo project
5. Chọn nước (Vietnam nếu có)

### Bước 2: Cấu hình Firestore Database
1. Trong Firebase Console, click **Firestore Database**
2. Click **Create database**
3. Chọn **Start in test mode** (để phát triển)
4. Chọn region: `asia-southeast1` (closest to Vietnam)
5. Click **Create**

### Bước 3: Cấu hình Authentication
1. Vào **Authentication** menu
2. Click **Get Started**
3. Chọn **Email/Password** provider
4. Enable email/password authentication
5. Click **Save**

### Bước 4: Cấu hình Storage (Optional)
1. Vào **Storage** menu
2. Click **Get Started**
3. Chọn region: `asia-southeast1`
4. Click **Done**

### Bước 5: Lấy Cấu hình Firebase

#### Option A: Sử dụng FlutterFire CLI (Recommended)
```powershell
# Thêm FlutterFire vào PATH
$env:PATH += ";C:\Users\DUC MINH\AppData\Local\Pub\Cache\bin"

# Chạy cấu hình
flutterfire configure
```

Lệnh này sẽ:
- Yêu cầu bạn chọn platforms (Windows, Web, Android, iOS, macOS)
- Tạo file `firebase_options.dart` tự động
- Cập nhật native configuration files

#### Option B: Cấu hình Manual
Nếu FlutterFire không hoạt động:
1. Vào Firebase Console → **Project Settings**
2. Thêm app cho từng platform:
   - Web
   - Windows (Desktop)
3. Copy credentials vào `lib/firebase_options.dart`

File `firebase_options.dart` đã được tạo ở `lib/firebase_options.dart` - bạn cần điền các giá trị từ Firebase Console.

## 📝 Các File đã Tạo

### 1. `lib/firebase_options.dart`
- Chứa Firebase configuration cho tất cả platforms
- **Cần phải điền các giá trị từ Firebase Console**

### 2. `lib/services/firebase_auth_service.dart`
- Quản lý Authentication
- Methods:
  - `signUp()` - Đăng ký tài khoản mới
  - `signIn()` - Đăng nhập
  - `signOut()` - Đăng xuất
  - `resetPassword()` - Đặt lại mật khẩu
  - `updateUserProfile()` - Cập nhật thông tin user
  - `deleteAccount()` - Xóa tài khoản

### 3. `lib/services/firebase_note_service.dart`
- Quản lý Notes trên Firestore
- Methods:
  - `createNote()` - Tạo ghi chú mới
  - `updateNote()` - Cập nhật ghi chú
  - `deleteNote()` - Xóa ghi chú
  - `getNotes()` - Lấy tất cả ghi chú (real-time)
  - `searchNotes()` - Tìm kiếm ghi chú
  - `getNotesByTag()` - Lấy ghi chú theo tag
  - `batchUpdateNotes()` - Cập nhật nhiều ghi chú

## 🚀 Cách Sử dụng Firebase Services

### Ví dụ 1: Đăng ký người dùng
```dart
final authService = FirebaseAuthService();

try {
  await authService.signUp(
    email: 'user@example.com',
    password: 'password123',
  );
  print('Đăng ký thành công!');
} catch (e) {
  print('Lỗi: $e');
}
```

### Ví dụ 2: Tạo ghi chú
```dart
final noteService = FirebaseNoteService();

final newNote = Note(
  id: DateTime.now().toString(),
  title: 'Ghi chú mới',
  content: 'Nội dung...',
  timestamp: DateTime.now(),
  color: Colors.blue,
  tags: ['work', 'important'],
  imagePaths: [],
);

await noteService.createNote(newNote);
```

### Ví dụ 3: Lắng nghe thay đổi ghi chú (real-time)
```dart
final noteService = FirebaseNoteService();

final notesStream = noteService.getNotes();

notesStream.listen((notes) {
  print('Số ghi chú: ${notes.length}');
  // Cập nhật UI
});
```

## 🔐 Security Rules (Firestore)

Sau khi cấu hình, đặt Security Rules như sau:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/notes/{noteId} {
      allow read, write: if request.auth.uid == userId;
    }
  }
}
```

Điều này đảm bảo:
- Mỗi user chỉ có thể đọc/ghi ghi chú của chính họ
- Dữ liệu an toàn

## 📋 Các Bước Tiếp Theo

1. **Cấu hình Firebase** - Chạy `flutterfire configure`
2. **Cập nhật Note Model** - Thêm `toJson()` và `fromJson()` nếu chưa có
3. **Tích hợp Services** - Sử dụng `FirebaseAuthService` và `FirebaseNoteService` trong UI
4. **Test trên Web** - Chạy `flutter run -d chrome`
5. **Deploy** - Firebase Hosting hoặc nơi khác

## ⚠️ Lưu Ý Quan Trọng

1. **Bảo mật Credentials**: Không commit file chứa credentials vào Git
2. **Test Mode Database**: Firestore database hiện ở chế độ test - cần cấu hình Security Rules trước khi deploy
3. **Android/iOS**: Cần cấu hình Google Services thêm nếu muốn hỗ trợ mobile
4. **Environment Variables**: Có thể lưu credentials trong environment variables

## 🆘 Troubleshooting

### Lỗi: "app.firebaseapp.com: Temporary Redirect"
- Kiểm tra credentials trong `firebase_options.dart`
- Xác nhận Firebase project settings

### Lỗi: "User is not authenticated"
- Kiểm tra Authentication rules
- Đảm bảo user đã đăng nhập trước khi truy cập Firestore

### Lỗi: "Missing credentials"
- Chảy lại `flutterfire configure`
- Hoặc copy credentials từ Firebase Console manually

## 📚 Tài Liệu Tham Khảo

- [Firebase Official Docs](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev)
- [Cloud Firestore Guide](https://cloud.google.com/firestore/docs)
- [Firebase Authentication](https://firebase.google.com/docs/auth)

---

**Môi trường đã sẵn sàng! Hãy bắt đầu cấu hình Firebase ngay.**
