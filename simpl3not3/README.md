# Smart Note - Thân Đức Minh - 2351060467

Dự án ứng dụng ghi chú (Smart Note) sử dụng Flutter và SharedPreferences để lưu trữ dữ liệu offline (Local Storage).

## Cấu trúc thư mục và nhiệm vụ các file

Dưới đây là cấu trúc các file trong thư mục `lib/` và nhiệm vụ cụ thể của từng file để đáp ứng các yêu cầu kiểm thử và nghiệp vụ của ứng dụng:

### 1. `lib/main.dart`
- **Nội dung:** Chứa hàm `main()` khởi chạy ứng dụng và widget gốc (root widget) `MyApp`.
- **Nhiệm vụ:** 
  - Đảm bảo các bindings của Flutter được khởi tạo trước khi chạy app (nếu cần thiết cho SharedPreferences).
  - Thiết lập giao diện tổng thể (ThemeData), định nghĩa màu sắc và font chữ mặc định.
  - Định tuyến (Routing) màn hình khởi tạo đầu tiên là Màn hình chính (Home Screen).

### 2. `lib/models/note_model.dart`
- **Nội dung:** Cấu trúc dữ liệu đại diện cho một đối tượng Ghi chú (Note).
- **Nhiệm vụ:**
  - Khai báo các thuộc tính cần thiết: `id` (dùng để định danh duy nhất), `title` (tiêu đề), `content` (nội dung), `updatedAt` (thời gian tạo/chỉnh sửa).
  - Chứa các phương thức **JSON Serialization** (`fromJson` và `toJson`) giúp chuyển đổi qua lại giữa đối tượng Dart và Map thuần tuý trước khi chuyển thành chuỗi JSON lưu xuống máy.

### 3. `lib/services/shared_prefs_service.dart`
- **Nội dung:** Lớp dịch vụ (Service layer) chuyên chịu trách nhiệm giao tiếp với bộ nhớ `SharedPreferences`.
- **Nhiệm vụ:**
  - Đọc chuỗi JSON từ thiết bị và parse thành danh sách `List<Note>`.
  - Cập nhật danh sách ghi chú (Thêm mới, Cập nhật, Xóa) và đóng gói mã hóa (`jsonEncode`) trả về chuỗi JSON để ghi đè xuống bộ nhớ vĩnh viễn.
  - Đảm bảo dữ liệu được duy trì đúng trạng thái ngay cả khi Kill App hoặc khởi động lại máy ảo.

### 4. `lib/screens/home_screen.dart`
- **Nội dung:** Giao diện màn hình chính hiển thị ngay sau khi mở app.
- **Nhiệm vụ:**
  - Cấu hình AppBar theo đúng định danh bắt buộc: "Smart Note - Thân Đức Minh - 2351060467".
  - Tích hợp thanh tìm kiếm **Search Bar** để lọc kết quả ghi chú real-time ngay trên giao diện.
  - Đọc trạng thái dữ liệu: Nếu trống thì hiển thị giao diện ảnh minh họa & chữ "Bạn chưa có ghi chú nào...".
  - Xử lý Render danh sách theo định dạng lưới 2 cột sử dụng layout sole (Masonry / Staggered Grid Layout).
  - Xử lý thao tác **Swipe to delete** (vuốt để xóa) kết hợp gọi hộp thoại nhắc nhở "Bạn có chắc chắn muốn xóa ghi chú này không?".
  - Chứa Floating Action Button (FAB) điều hướng sang màn hình soạn thảo.
  - Quản lý State bất đồng bộ: Khi người dùng trở về từ màn hình thêm/sửa, tự động refresh mảng danh sách mới nhất.

### 5. `lib/screens/edit_note_screen.dart`
- **Nội dung:** Giao diện (Màn hình chi tiết) soạn thảo ghi chú.
- **Nhiệm vụ:**
  - Hiển thị giao diện soạn thảo tối giản, bỏ đi các border của ô nhập liệu (`TextField`).
  - Hỗ trợ nhập liệu TextBox đa dòng, có khả năng linh hoạt giãn nở theo nội dung.
  - **Luồng xử lý Auto-save (Trọng tâm):** Bắt sự kiện vòng đời (Lifecycle) hoặc nút Back (mũi tên / vuốt màn hình) thông qua `WillPopScope` hoặc cơ chế Router để lấy toàn bộ dữ liệu hiện tại, tự động gán thời gian, gọi lớp Service mã hoá và lưu lại vào Storage một cách ngầm định, tuyệt đối không sử dụng nút "Lưu".

### 6. `lib/widgets/note_card.dart`
- **Nội dung:** Custom Widget (Component tái sử dụng) định dạng cho một Item (Thẻ ghi chú) trong danh sách lưới.
- **Nhiệm vụ:**
  - Nhận đầu vào là một đối tượng `Note`.
  - Xử lý việc vẽ giao diện (UI) cái thẻ bo góc tròn, và đổ bóng nền nhẹ.
  - Cấu hình hiển thị Text: In đậm tiêu đề (tối đa 1 dòng kèm `TextOverflow.ellipsis`), Nội dung mờ nhạt (tối đa 3 dòng kèm `TextOverflow.ellipsis`), Thời gian theo đúng format `dd/MM/yyyy HH:mm` góc dưới cùng.
