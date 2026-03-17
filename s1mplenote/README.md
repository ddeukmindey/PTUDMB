# Smart Note App

Ứng dụng ghi chú thông minh (Smart Note) được xây dựng bằng Flutter, sử dụng `shared_preferences` để lưu trữ dữ liệu offline (Local Storage).

## Cấu trúc thư mục và nội dung các file chính

Dưới đây là mô tả chi tiết về các file mã nguồn chính trong thư mục `lib/`:

### 1. `lib/main.dart`
- **Vai trò:** Là điểm bắt đầu (entry point) của ứng dụng.
- **Nội dung:** Khởi tạo `SmartNoteApp` (kế thừa từ `StatelessWidget`), thiết lập Material Theme cơ bản cho toàn bộ app và chỉ định màn hình đầu tiên hiển thị là `HomeScreen`.

### 2. `lib/models/note.dart`
- **Vai trò:** Định nghĩa cấu trúc dữ liệu cho một Ghi chú.
- **Nội dung:** 
  - Lớp `Note` chứa các trường thông tin: `id` (định danh duy nhất), `title` (tiêu đề), `content` (nội dung), `createdAt` (thời gian tạo), `updatedAt` (thời gian cập nhật).
  - Cung cấp các phương thức `toJson()` và `factory Note.fromJson()` để đóng gói/mở gói dữ liệu phục vụ cho việc lưu trữ dưới dạng chuỗi JSON.
  - Hàm `copyWith()` hỗ trợ tạo ra bản sao của đối tượng Note với một vài thông tin được thay đổi.

### 3. `lib/services/storage_service.dart`
- **Vai trò:** Tầng dịch vụ (Service Layer) chuyên xử lý logic giao tiếp với bộ nhớ trong của thiết bị.
- **Nội dung:**
  - Sử dụng package `shared_preferences` để đọc/ghi dữ liệu vĩnh viễn (Offline).
  - Cung cấp các phương thức bất đồng bộ (Future) thao tác với List các đối tượng `Note`:
    - `getNotes()`: Đọc chuỗi JSON từ bộ nhớ, giải mã (decode) thành danh sách các object `Note`.
    - `saveNotes(List<Note>)`: Chuyển đổi danh sách `Note` thành JSON (encode) và lưu vào bộ nhớ.
    - `addOrUpdateNote(Note)`: Thêm một Note mới vào đầu danh sách hoặc cập nhật Note hiện tại nếu đã tồn tại `id`.
    - `deleteNote(String id)`: Tìm và xóa một Note khỏi bộ nhớ theo `id`.

### 4. `lib/screens/home_screen.dart`
- **Vai trò:** Màn hình chính (Trang chủ) hiển thị danh sách tất cả các ghi chú.
- **Nội dung:**
  - **AppBar:** Chứa tiêu đề ứng dụng "Smart Note - Thân Đức Minh - 2351060467".
  - **Search Bar:** Thanh tìm kiếm cho phép lọc danh sách ghi chú theo Tiêu đề ngay tức thời (real-time).
  - **Note Grid:** Sử dụng `MasonryGridView.count` (dạng lưới 2 cột) để hiển thị các Note dưới dạng các thẻ (Card) có chiều cao linh hoạt tự điều chỉnh theo nội dung văn bản.
  - **Vuốt để xóa (Swipe to Delete):** Bọc từng Note Card bởi widget `Dismissible`. Khi vuốt sẽ hiện background đỏ hình thùng rác và luôn hiển thị Hộp thoại xác nhận (Dialog) trước khi gọi hàm xóa ở `storage_service`.
  - **Floating Action Button (FAB):** Nút dấu cộng `+` ở góc dưới để điều hướng sang màn hình thêm mới thẻ ghi chú.
  - **Empty State:** Hiển thị khung thông báo thân thiện khi không có dữ liệu nào trong máy.

### 5. `lib/screens/edit_screen.dart`
- **Vai trò:** Màn hình Tạo mới và Chỉnh sửa nội dung ghi chú.
- **Nội dung:**
  - Giao diện tối giản giống một tờ giấy trắng (Borderless TextFields), tự động giãn dòng khi văn bản dài ra.
  - **Tính năng Auto-save:** Không có nút "Lưu". Màn hình được bọc bởi widget `PopScope` để bắt sự kiện người dùng bấm Back (hoặc vuốt viền máy). Khi có sự kiện Back sẽ lập tức gọi hàm khởi tạo/cập nhật `Note` rồi chuyển qua cho `StorageService` lưu trữ, sau đó mới cho phép pop ra ngoài trang chủ.
