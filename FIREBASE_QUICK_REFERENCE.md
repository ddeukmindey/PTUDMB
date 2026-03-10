# 🔥 Firebase Services Quick Reference

## Tổng Quan

Dự án SmartNote đã được tích hợp Firebase với 2 service chính:
- **FirebaseAuthService** - Quản lý user account
- **FirebaseNoteService** - Quản lý ghi chú trên Firestore

---

## 🔐 FirebaseAuthService

### Import
```dart
import 'package:smartnote/services/firebase_auth_service.dart';
```

### Khởi tạo
```dart
final authService = FirebaseAuthService();
```

### Methods

#### 1. Sign Up
```dart
try {
  final credential = await authService.signUp(
    email: 'user@example.com',
    password: 'password123',
  );
  print('User ID: ${credential.user?.uid}');
} catch (e) {
  print('Error: $e');
}
```

#### 2. Sign In
```dart
try {
  final credential = await authService.signIn(
    email: 'user@example.com',
    password: 'password123',
  );
  print('Logged in as: ${credential.user?.email}');
} catch (e) {
  print('Error: $e');
}
```

#### 3. Sign Out
```dart
await authService.signOut();
print('Logged out');
```

#### 4. Reset Password
```dart
try {
  await authService.resetPassword(email: 'user@example.com');
  print('Password reset email sent!');
} catch (e) {
  print('Error: $e');
}
```

#### 5. Update Profile
```dart
try {
  await authService.updateUserProfile(
    displayName: 'John Doe',
    photoURL: 'https://example.com/photo.jpg',
  );
  print('Profile updated!');
} catch (e) {
  print('Error: $e');
}
```

#### 6. Delete Account
```dart
try {
  await authService.deleteAccount();
  print('Account deleted');
} catch (e) {
  print('Error: $e');
}
```

### Getters

#### Get Current User
```dart
User? user = authService.currentUser;
if (user != null) {
  print('User: ${user.email}');
}
```

#### Listen to Auth Changes (Stream)
```dart
authService.authStateChanges.listen((User? user) {
  if (user == null) {
    print('User logged out');
  } else {
    print('User logged in: ${user.email}');
  }
});
```

---

## 📝 FirebaseNoteService

### Import
```dart
import 'package:smartnote/services/firebase_note_service.dart';
import 'package:smartnote/models/note.dart';
```

### Khởi tạo
```dart
final noteService = FirebaseNoteService();
```

### Methods

#### 1. Create Note
```dart
final note = Note(
  id: DateTime.now().toString(),
  title: 'My Note',
  content: 'This is my note',
  timestamp: DateTime.now(),
  color: Colors.blue,
  tags: ['work', 'important'],
  imagePaths: [],
);

try {
  await noteService.createNote(note);
  print('Note created!');
} catch (e) {
  print('Error: $e');
}
```

#### 2. Update Note
```dart
final updatedNote = note.copyWith(
  title: 'Updated Title',
  content: 'Updated content',
);

try {
  await noteService.updateNote(updatedNote);
  print('Note updated!');
} catch (e) {
  print('Error: $e');
}
```

#### 3. Delete Note
```dart
try {
  await noteService.deleteNote('note_id');
  print('Note deleted!');
} catch (e) {
  print('Error: $e');
}
```

#### 4. Get All Notes (Real-time Stream)
```dart
noteService.getNotes().listen((notes) {
  print('Total notes: ${notes.length}');
  for (var note in notes) {
    print('- ${note.title}');
  }
});
```

#### 5. Get Notes in Widget (StreamBuilder)
```dart
StreamBuilder<List<Note>>(
  stream: noteService.getNotes(),
  builder: (context, snapshot) {
    if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    }
    
    if (!snapshot.hasData) {
      return const CircularProgressIndicator();
    }
    
    final notes = snapshot.data ?? [];
    
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(notes[index].title),
          subtitle: Text(notes[index].content),
        );
      },
    );
  },
)
```

#### 6. Search Notes
```dart
try {
  final results = await noteService.searchNotes('keyword');
  print('Found ${results.length} notes');
} catch (e) {
  print('Error: $e');
}
```

#### 7. Get Notes by Tag
```dart
try {
  final tagged = await noteService.getNotesByTag('work');
  print('Notes with tag "work": ${tagged.length}');
} catch (e) {
  print('Error: $e');
}
```

#### 8. Batch Update Notes
```dart
final notesToUpdate = [note1, note2, note3];

try {
  await noteService.batchUpdateNotes(notesToUpdate);
  print('Batch update completed!');
} catch (e) {
  print('Error: $e');
}
```

---

## 🏗️ Architecture Pattern

### Recommended Structure

```
lib/
├── models/
│   └── note.dart
├── services/
│   ├── firebase_auth_service.dart
│   ├── firebase_note_service.dart
│   └── note_storage.dart
├── screens/
│   ├── login_screen.dart
│   ├── home_screen.dart
│   └── note_detail_screen.dart
├── widgets/
│   └── note_card.dart
└── main.dart
```

---

## 💾 Firestore Data Structure

### Users Collection
```
users/
└── {userId}/
    └── notes/
        └── {noteId}
            ├── id: string
            ├── title: string
            ├── content: string
            ├── timestamp: timestamp
            ├── color: number (color code)
            ├── tags: array
            ├── imagePaths: array
            ├── createdAt: timestamp
            └── updatedAt: timestamp
```

---

## 🔒 Error Handling

### Common Error Codes

```dart
// Authentication Errors
'weak-password' → Mật khẩu quá yếu
'email-already-in-use' → Email đã được dùng
'invalid-email' → Email không hợp lệ
'user-not-found' → Không tìm thấy user
'wrong-password' → Mật khẩu sai
'user-disabled' → User bị vô hiệu hóa
'too-many-requests' → Quá nhiều yêu cầu
```

### Error Handling Pattern
```dart
try {
  // Your code
} on FirebaseAuthException catch (e) {
  print('Auth Error: ${e.code}');
  print('Message: ${e.message}');
} on FirebaseException catch (e) {
  print('Firebase Error: ${e.code}');
} catch (e) {
  print('General Error: $e');
}
```

---

## 🧪 Testing

### Mock Services (for testing without Firebase)
```dart
class MockNoteService {
  final List<Note> _notes = [];
  
  Future<void> createNote(Note note) async {
    _notes.add(note);
  }
  
  Stream<List<Note>> getNotes() {
    return Stream.value(_notes);
  }
}
```

---

## ⚡ Performance Tips

1. **Use Streams wisely** - Cache streams to avoid recreating them
2. **Limit query results** - Use `.limit(20)` for pagination
3. **Index fields** - Firestore will suggest indexes for queries
4. **Offline Persistence** - Firebase has offline support by default
5. **Batch Operations** - Use batch updates for multiple documents

---

## 📚 Useful Patterns

### Pattern 1: Auth State Management
```dart
StreamBuilder<User?>(
  stream: authService.authStateChanges,
  builder: (context, snapshot) {
    if (!snapshot.hasData) {
      return LoginScreen();
    }
    return HomeScreen();
  },
)
```

### Pattern 2: Combined Auth + Data
```dart
Stream<List<Note>> getUserNotes() {
  return authService.authStateChanges.switchMap((user) {
    if (user == null) return Stream.value([]);
    return noteService.getNotes();
  });
}
```

### Pattern 3: Pull-to-Refresh
```dart
Future<void> _refreshNotes() async {
  final notes = await noteService.getNotes().first;
  setState(() {
    _notes = notes;
  });
}
```

---

## 🚀 Next Steps

1. ✅ Cấu hình Firebase (xem FIREBASE_SETUP.md)
2. ✅ Thêm authentication screens
3. ✅ Tích hợp Firestore vào existing UI
4. ✅ Implement real-time sync
5. ✅ Add offline support
6. ✅ Deploy to production

---

**Chúc bạn phát triển thành công! 🎉**
