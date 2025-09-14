# Tổng quan Hệ thống Quản trị Phần mềm (Super Admin - Dành cho Dev)

## 1. Mục đích

Đây là tài liệu kỹ thuật dành cho đội ngũ phát triển, mô tả tổng quan về kiến trúc, công nghệ và các thành phần chính của Hệ thống Quản trị Phần mềm (Super Admin Panel). Trang quản trị này **không** dành cho người dùng cuối (phòng khám) mà phục vụ cho việc quản lý, giám sát và cấu hình toàn bộ nền tảng Vet Biotics.

## 2. Công nghệ và Kiến trúc

*   **Nền tảng Frontend:** **Flutter Web**
    *   **Lý do:** Tái sử dụng tối đa code base và component từ ứng dụng chính (dành cho phòng khám). Quản lý đồng bộ phiên bản và tính năng dễ dàng hơn.
*   **Nền tảng Backend:** **Firebase (BaaS - Backend as a Service)**
    *   **Firebase Authentication:** Xử lý đăng nhập, phân quyền cho super-admin.
    *   **Firestore:** Lưu trữ dữ liệu cấu hình, logs, thông tin quản lý các phòng khám.
    *   **Firebase Cloud Functions:** Thực thi các tác vụ backend logic, xử lý các sự kiện trigger trong hệ thống (ví dụ: tạo phòng khám mới, xử lý vi phạm).
    *   **Firebase Storage:** Lưu trữ các tài sản dùng chung của hệ thống.
*   **Kiến trúc Code (Đề xuất):** **Clean Architecture**
    *   **Lý do:** Phân tách rõ ràng các lớp (Presentation, Domain, Data), giúp code dễ bảo trì, dễ kiểm thử và không bị phụ thuộc chặt chẽ vào framework hay nền tảng.
    *   **Tổ chức module:** Chia project thành các feature module (ví dụ: `clinic_management`, `user_management`, `system_monitoring`).

## 3. Các Module chính của Trang Quản trị

Đây là các tính năng dành riêng cho Super Admin để quản lý toàn bộ nền tảng.

*   **Dashboard (Bảng điều khiển trung tâm):**
    *   Hiển thị các số liệu thống kê tổng quan: Tổng số phòng khám đăng ký, tổng số người dùng, số lượng bệnh án được tạo trong ngày/tháng, trạng thái hệ thống (system health).
    *   Cảnh báo về các lỗi nghiêm trọng hoặc hoạt động bất thường.

*   **Quản lý Phòng khám (Clinic/Tenant Management):**
    *   Xem danh sách tất cả các phòng khám đang sử dụng dịch vụ.
    *   Tạo mới, kích hoạt, vô hiệu hóa tài khoản của một phòng khám.
    *   Xem thông tin chi tiết của từng phòng khám (số lượng bác sĩ, số lượng thú cưng, dung lượng dữ liệu đã sử dụng).
    *   Cấu hình gói dịch vụ (plan/subscription) cho từng phòng khám.

*   **Quản lý Người dùng Toàn cục (Global User Management):**
    *   Xem và tìm kiếm tất cả người dùng trên mọi phòng khám.
    *   Reset mật khẩu hoặc thực hiện các thao tác hỗ trợ người dùng khi cần thiết.

*   **Quản lý Dữ liệu Mẫu (Master Data Management):**
    *   Quản lý danh sách các giống loài (breeds/species) mặc định.
    *   Quản lý danh mục thuốc và hoạt chất dùng chung.
    *   Quản lý các mẫu (template) mặc định cho toàn hệ thống.

*   **Giám sát và Ghi log (Monitoring & Logging):**
    *   Xem log hoạt động của hệ thống, log lỗi từ API, Cloud Functions.
    *   Theo dõi hiệu suất của Firestore, thời gian phản hồi của API.

*   **Hệ thống Cấu hình (System Configuration):**
    *   Quản lý các cờ tính năng (feature flags) để bật/tắt tính năng cho toàn hệ thống hoặc cho một nhóm phòng khám.
    *   Cấu hình nội dung email, SMS template cho các thông báo hệ thống.
    *   Quản lý các tích hợp của bên thứ ba (cổng thanh toán, dịch vụ gửi SMS).

## 4. Quy trình phát triển (Workflow)

*   **Quản lý mã nguồn:** Git (sử dụng Git Flow: `main`, `develop`, `feature/`, `hotfix/`).
*   **Convention:** Tuân thủ theo [Effective Dart](https://dart.dev/guides/language/effective-dart) và các quy tắc lint được định nghĩa trong `analysis_options.yaml`.
*   **Kiểm thử (Testing):**
    *   **Unit Tests:** Cho các business logic ở tầng Domain (usecases).
    *   **Widget Tests:** Cho các thành phần UI.
    *   **Integration Tests:** Cho các flow hoàn chỉnh.

## 5. Hướng dẫn Cài đặt cho Dev mới

1.  **Cài đặt Flutter:** Đảm bảo đã cài Flutter SDK phiên bản `x.x.x`.
2.  **Clone ays án:** `git clone [repository-url]`
3.  **Cấu hình Firebase:**
    *   Tải file `firebase_options.dart` (hoặc tương tự) từ Firebase project của dev team.
    *   Đặt vào đúng vị trí trong thư mục `lib`.
4.  **Tải dependencies:** `flutter pub get`
5.  **Chạy ứng dụng (Web):** `flutter run -d chrome`

---

*Tài liệu này sẽ được cập nhật liên tục cùng với quá trình phát triển của dự án.*