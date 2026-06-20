# Hướng dẫn Phát triển Dự án (Development Guide)

## 1. Kiến trúc dự án (Architecture)
Chúng ta tuân thủ kiến trúc phân tầng để đảm bảo tính bất đồng bộ (Clean Layered Architecture):
- **UI (Presentation):** Chỉ hiển thị, không chứa logic nghiệp vụ.
- **State Management:** BLoC/Provider (Quản lý trạng thái màn hình).
- **Domain Layer:** Chứa Entities (Thực thể) và Repository Interfaces (Cái khung để gọi dữ liệu).
- **Data Layer:** Hiện thực hóa Repository, xử lý Mock Data hoặc gọi API Firebase.

*Luồng dữ liệu:* `UI -> State Management -> Domain (Interface) -> Data (Implementation)`

## 2. Quy tắc Git (Git Guidelines)
Mọi thay đổi phải đi qua nhánh riêng trước khi merge vào `develop`.
- **Cú pháp nhánh:** `feature/function/name`
    - Ví dụ: `feature/auth-login/khoi` (Khôi làm chức năng đăng nhập)
    - Ví dụ: `feature/chat-realtime/manh` (Mạnh làm chức năng chat)
- **Quy tắc Pull Request (PR):**
    - PR phải có mô tả ngắn gọn về các file đã sửa.
    - Tuyệt đối không merge khi chưa có ít nhất 1 người khác (hoặc Lead) review.
    - Sau khi review, squash commit (nếu cần) trước khi merge.

## 3. Cấu trúc cây thư mục (Folder Structure)
- `lib/presentation/`: Chứa các màn hình (screens) và widget.
- `lib/data/`: Chứa các repositories và data sources.
- `lib/domain/`: Chứa các entities.
- `lib/core/`: Chứa theme, hằng số (constants), và utils.

## 4. Quy ước Commit (Commit Convention)
Áp dụng chuẩn `Conventional Commits` để dễ dàng tra cứu lịch sử:
- `feat: [tên-tính-năng]` : Thêm tính năng mới (VD: `feat: login-screen`).
- `fix: [tên-lỗi]` : Sửa lỗi (VD: `fix: map-marker-alignment`).
- `docs: [nội-dung]` : Thay đổi tài liệu.
- `refactor: [nội-dung]` : Thay đổi code không làm ảnh hưởng tính năng.

## 5. Setup môi trường (Environment Setup)
Để tránh lỗi build khác phiên bản, mọi thành viên bắt buộc phải chạy:
1. `flutter clean`
2. `flutter pub get`
3. Đảm bảo file `.env` (nếu có cấu hình Firebase) được copy từ bản mẫu `env.example`.

## 6. Lệnh Git ưu tiên
- Luôn pull mới nhất trước khi làm việc: `git pull origin develop`
- Luôn rebase để giữ history sạch: `git fetch origin` sau đó `git rebase origin/develop`