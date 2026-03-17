# Cấu trúc dự án Menu Món Ăn (Menu App)

Sau khi dọn dẹp và phân chia lại logic hệ thống, dự án hiện chỉ bao gồm chức năng Menu Món Ăn. Dưới đây là danh sách và nội dung (nhiệm vụ) của từng file `.dart` trong hệ thống:

## 1. `lib/main.dart`
- **Nhiệm vụ:** File khởi chạy gốc (Entry point) của toàn bộ ứng dụng.
- **Nội dung:** Chứa hàm `main()` khởi tạo `runApp()` vào widget `MyApp`. Thiết lập toàn bộ cấu hình Theme (giao diện cốt lõi Material 3, màu sắc gốc) và chỉ định màn hình đầu tiên được tải lên ngay khi mở app là `HomeScreen`.

## 2. `lib/screens/home_screen.dart`
- **Nhiệm vụ:** Giao diện trung tâm chính (UI) hiển thị danh sách các món ăn.
- **Nội dung:** 
  - Khởi tạo thanh điều hướng (Tab Bar) phân nhóm món ăn (Khai vị, Món chính, Đồ uống, Tráng miệng).
  - Gọi đến lớp `ApiService` để lấy dữ liệu mạng `_loadFoods()`.
  - Quản lý trạng thái thông báo chờ (Loading Indicator) cũng như báo Lỗi (Error Message) nếu mất mạng.
  - Phân luồng dữ liệu (Filter) hiển thị danh sách món ăn dưới dạng thẻ lưới (Grid View) gọi từ component `FoodCard`.

## 3. `lib/models/food_model.dart`
- **Nhiệm vụ:** Định nghĩa cấu trúc dữ liệu mô hình thực thể món ăn (Data Model).
- **Nội dung:** Cung cấp thuộc tính cho một đối tượng Món ăn (Food) cần có gì, bao gồm: `id`, tên (`name`), ảnh (`imageUrl`), giá bán (`price`), danh mục (`category`). Trong này còn chứa phương thức `Food.fromJson` dùng bóc tách (parse) dữ liệu JSON tải từ internet để đúc thành một Object trong ngôn ngữ Dart (bao gồm cả chức năng gắn ngẫu nhiên giá tiền cho món).

## 4. `lib/widgets/food_card.dart`
- **Nhiệm vụ:** Một Component (cấu kiện giao diện lập trình sẵn) tái sử dụng để hiển thị dạng thẻ món.
- **Nội dung:** Thiết kế cấu trúc UI của riêng một thẻ (`Card`) bo góc. Component này nhận đầu vào là đối tượng `Food` sau đó tiến hành dựng khung ảnh (Image.network), chèn tên món, biểu tượng icon và làm đẹp phần Text số tiền. File này được tách rời để `home_screen.dart` chỉ việc tái sử dụng liên tục cho từng đối tượng thức ăn mà code không bị dài dòng.

## 5. `lib/services/api_service.dart`
- **Nhiệm vụ:** Dịch vụ (Service) chuyên biệt phụ trách việc giao tiếp mạng với Server API.
- **Nội dung:** Khai báo Endpoint URL tới máy chủ `themealdb.com`. Chạy hàm bất đồng bộ `fetchFoods()` gọi gói package trợ lực `http` kéo toàn bộ dữ liệu thuần Text về máy. Xử lý logic đọc và chuyển mã (decode JSON), sau đó nhét các món này vào List các Object `Food` đồng thời chia ngẫu nhiên chúng ra 4 chuyên mục để cung cấp lại cho `HomeScreen` một mảng dữ liệu sạch đẹp nhất. Mọi lỗi về timeout, rớt mạng đều sẽ được chặn (catch) ở đây.
