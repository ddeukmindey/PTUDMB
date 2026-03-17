# 🔐 Hướng dẫn Chức năng Đăng nhập SmartNote

## 📋 Tổng quan

SmartNote đã được tích hợp **Firebase Authentication** với các tính năng:

### ✅ Tính năng đã có:
- **Đăng ký tài khoản** mới với email/password
- **Đăng nhập** với tài khoản đã có
- **Đặt lại mật khẩu** qua email
- **Tự động kiểm tra trạng thái đăng nhập**
- **Đăng xuất** với xác nhận
- **UI đẹp** với gradient background
- **Xử lý lỗi** chi tiết bằng tiếng Việt

---

## 🚀 Cách sử dụng

### 1. **Khởi chạy ứng dụng**

Khi mở app lần đầu, bạn sẽ thấy màn hình đăng nhập:

```dart
// App tự động kiểm tra trạng thái đăng nhập
// Nếu chưa đăng nhập → Hiển thị LoginScreen
// Nếu đã đăng nhập → Hiển thị HomeScreen
```

### 2. **Đăng ký tài khoản mới**

1. Nhấn **"Chưa có tài khoản? Đăng ký"**
2. Nhập email và mật khẩu (ít nhất 6 ký tự)
3. Nhấn **"Đăng ký"**
4. Hệ thống sẽ gửi xác nhận và chuyển về màn hình đăng nhập

### 3. **Đăng nhập**

1. Nhập email và mật khẩu
2. Nhấn **"Đăng nhập"**
3. Nếu thành công → Chuyển đến màn hình chính
4. Nếu thất bại → Hiển thị lỗi chi tiết

### 4. **Quên mật khẩu**

1. Nhập email vào trường email
2. Nhấn **"Quên mật khẩu?"**
3. Firebase sẽ gửi email đặt lại mật khẩu

### 5. **Đăng xuất**

1. Ở màn hình chính, nhấn icon **logout** (🚪) trên AppBar
2. Xác nhận đăng xuất
3. Trở về màn hình đăng nhập

---

## 📱 Cấu trúc Files

```
lib/
├── screens/
│   └── login_screen.dart          # Màn hình đăng nhập
├── widgets/
│   └── auth_wrapper.dart          # Wrapper kiểm tra auth state
├── services/
│   └── firebase_auth_service.dart # Service xử lý authentication
└── main.dart                      # Cập nhật để sử dụng AuthWrapper
```

---

## 🔧 Firebase Configuration

### Bước 1: Bật Authentication
```
Firebase Console → Authentication → Get Started
```

### Bước 2: Chọn Sign-in method
```
Email/Password → Enable → Save
```

### Bước 3: Cấu hình Firebase Options
```bash
flutterfire configure
# Chọn platforms: Windows, Web, Android, iOS
```

---

## 🎨 UI/UX Features

### Login Screen
- **Gradient background** đẹp mắt
- **Form validation** real-time
- **Loading states** với CircularProgressIndicator
- **Error messages** bằng tiếng Việt
- **Responsive design** cho tất cả màn hình

### Authentication Flow
```
App Start
    ↓
Check Auth State
    ↓
Not Logged In → LoginScreen
    ↓
Login/Signup Success → HomeScreen
    ↓
Logout → LoginScreen
```

---

## 🛡️ Security Features

### Password Requirements
- **Minimum 6 characters**
- **Required field validation**
- **Real-time feedback**

### Error Handling
```dart
// Các lỗi được xử lý:
- 'user-not-found' → "Không tìm thấy tài khoản"
- 'wrong-password' → "Mật khẩu không đúng"
- 'email-already-in-use' → "Email đã được sử dụng"
- 'weak-password' → "Mật khẩu quá yếu"
- 'invalid-email' → "Email không hợp lệ"
```

### Session Management
- **Persistent login** - không cần đăng nhập lại
- **Auto logout** khi token hết hạn
- **Secure token storage** by Firebase

---

## 🔄 Integration với Notes

### Local Storage (Mặc định)
- Notes lưu cục bộ trên thiết bị
- Không cần đăng nhập để sử dụng
- Dữ liệu không sync giữa devices

### Firebase Storage (Khuyến nghị)
- Notes lưu trên Firebase Firestore
- Sync real-time giữa tất cả devices
- Backup tự động
- Chia sẻ notes (tương lai)

### Migration Path
```dart
// Tương lai: Migrate local notes lên Firebase
Future<void> migrateNotesToFirebase() async {
  final localNotes = await _storage.loadNotes();
  for (final note in localNotes) {
    await _firebaseService.createNote(note);
  }
}
```

---

## 🐛 Troubleshooting

### Lỗi: "Email không hợp lệ"
**Nguyên nhân**: Email format sai
**Giải pháp**: Nhập email đúng format (user@domain.com)

### Lỗi: "Mật khẩu quá yếu"
**Nguyên nhân**: Mật khẩu < 6 ký tự
**Giải pháp**: Nhập mật khẩu dài hơn

### Lỗi: "Không tìm thấy tài khoản"
**Nguyên nhân**: Email chưa đăng ký
**Giải pháp**: Đăng ký tài khoản mới hoặc kiểm tra email

### Lỗi: "Quá nhiều yêu cầu"
**Nguyên nhân**: Spam login attempts
**Giải pháp**: Đợi 5-10 phút rồi thử lại

---

## 🚀 Advanced Features (Tương lai)

### Social Login
```dart
// Google Sign-In
await _authService.signInWithGoogle();

// Facebook Sign-In
await _authService.signInWithFacebook();
```

### Multi-Factor Authentication
```dart
// SMS verification
await _authService.enableSMSVerification();
```

### Account Management
```dart
// Update profile
await _authService.updateProfile(displayName: 'New Name');

// Delete account
await _authService.deleteAccount();
```

---

## 📊 Firebase Auth Limits

| Feature | Free Plan | Paid Plan |
|---------|-----------|-----------|
| Monthly Active Users | 50,000 | Unlimited |
| Email/Password Auth | ✅ | ✅ |
| Social Auth | ✅ | ✅ |
| Phone Auth | ❌ | ✅ |
| Custom Auth | ❌ | ✅ |

---

## 🎯 Best Practices

### 1. **User Experience**
- Luôn hiển thị loading states
- Thông báo lỗi rõ ràng bằng tiếng Việt
- Validate input real-time

### 2. **Security**
- Không log sensitive data
- Sử dụng HTTPS cho production
- Enable Firebase Security Rules

### 3. **Performance**
- Lazy load auth state
- Cache user data khi có thể
- Minimize network calls

### 4. **Error Handling**
```dart
try {
  await _authService.signIn(email: email, password: password);
} on FirebaseAuthException catch (e) {
  // Handle specific Firebase errors
} catch (e) {
  // Handle general errors
}
```

---

## 📚 Code Examples

### Check Auth State
```dart
StreamBuilder<User?>(
  stream: FirebaseAuth.instance.authStateChanges(),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      return const HomeScreen();
    }
    return const LoginScreen();
  },
)
```

### Sign Out with Confirmation
```dart
Future<void> signOut() async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Đăng xuất'),
      content: const Text('Bạn có chắc chắn?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false)),
        TextButton(onPressed: () => Navigator.pop(context, true)),
      ],
    ),
  );

  if (confirm == true) {
    await FirebaseAuth.instance.signOut();
  }
}
```

---

## 🎉 Kết luận

Chức năng đăng nhập đã hoàn chỉnh với:

- ✅ **UI/UX đẹp** và responsive
- ✅ **Firebase integration** đầy đủ
- ✅ **Error handling** chi tiết
- ✅ **Security best practices**
- ✅ **Vietnamese localization**
- ✅ **Auto state management**

**Bước tiếp theo**: Cấu hình Firebase và test chức năng! 🚀
