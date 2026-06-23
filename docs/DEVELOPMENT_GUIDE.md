# Hướng dẫn Phát triển Dự án (Development Guide)

## 1. Kiến trúc dự án (Architecture)
Chúng ta tuân thủ kiến trúc phân tầng để đảm bảo tính bất đồng bộ (Clean Layered Architecture):
- **UI (Presentation):** Chỉ hiển thị, không chứa logic nghiệp vụ.
- **State Management:** BLoC/Provider (Quản lý trạng thái màn hình).
- **Domain Layer:** Chứa Entities (Thực thể) và Repository Interfaces (Cái khung để gọi dữ liệu).
- **Data Layer:** Hiện thực hóa Repository, xử lý Mock Data hoặc gọi API Firebase.

*Luồng dữ liệu:* `UI -> State Management -> Domain (Interface) -> Data (Implementation)`

## 2. Quy tắc Git (Git Guidelines)

**BẢN CHẤT LUỒNG GIT MỚI:**
- `develop` (Baseline chính): Phải sạch 100% làm baseline chuẩn cho cả đội pull về.
- `test/integration-merge` (chỗ tự test): Vùng Sandbox lắp ráp. Nơi ae tự mang code ra va chạm, tự sửa conflict và tự test chéo với nhau. Team Lead không gánh toàn bộ việc fix conflict và test hộ ae như trước nữa.
- `main` (Bàn giao): Chỉ dùng chốt sản phẩm cuối kỳ để chấm điểm. Nhánh này Lead tự quản lý và đẩy, ae không đụng vào.

**3 BƯỚC LÀM VIỆC CỦA AE:**
1. **Code:** Ae vẫn triển khai bình thường trên nhánh `feature/<module_x_...>/<tên-màn-hình>/<tên-người-làm>` của mình.
   - *Ví dụ:* `feature/module_1_auth/login/manh`
   - *Ví dụ:* `feature/module_4_booking/confirm/hoang`
2. **Tự Ráp & Tự Sửa (80-90%):** Làm xong, ae tự merge nhánh feature của mình vào `test/integration-merge`. Người vào sau tự chịu trách nhiệm fix conflict với người vào trước và tự chạy test luồng phối hợp ổn định 80-90% trực tiếp trên nhánh này.
3. **Chốt hạ (100%):** Chạy chung ngon lành ổn định -> Ae tạo PR từ **chính nhánh feature đó** vào `develop`. Lead chỉ check tổng lần cuối và duyệt để khóa baseline sạch.

**TÓM LẠI:** Ae tự merge vào nhánh `test/integration-merge` trước -> tự fix conflict với người đi trước + tự test luồng chạy chung -> chạy ổn định thì mới PR nhánh feature vào `develop` để Lead duyệt chốt baseline.
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