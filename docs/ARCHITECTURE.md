# Kiến trúc hệ thống (System Architecture)

## 1. Clean Layered Architecture
Dự án áp dụng mô hình phân tầng để đảm bảo tính bất đồng bộ, dễ test và giảm thiểu conflict khi 5 thành viên cùng phát triển.

- **Presentation Layer (UI & State Management):** - Sử dụng Flutter Widgets, BLoC pattern.
    - Chịu trách nhiệm hiển thị và bắt sự kiện người dùng (Event).
- **Domain Layer (Business Rules):** - Chứa Entities (Thực thể kinh doanh như Property, Room, Booking).
    - Chứa Repository Interfaces (Hợp đồng dữ liệu, không quan tâm tới cách lấy dữ liệu).
- **Data Layer (Implementation):** - Hiện thực hóa các Repository.
    - Xử lý Data Sources (Firebase Firestore, Local Mock Data).

## 2. Luồng dữ liệu (Data Flow)
`UI Event` -> `BLoC` -> `Repository Interface` -> `Data Implementation` -> `Firebase/Mock Source`

## 3. Database Schema (Nghiệp vụ cốt lõi)
- **Property (1) -> Room (N):** Một khu lưu trú có thể chứa nhiều loại phòng.
- **Booking:** Liên kết `RoomID` và `UserID` để lưu lịch sử đặt phòng.
- **Logic:** Mọi tính toán tiền bạc/giảm giá được xử lý tại `Repository` hoặc `Domain Service` để đảm bảo tính thống nhất dữ liệu.

## 4. Công nghệ chủ chốt
- **State Management:** BLoC (để chia tách Event/State rõ ràng).
- **Async Handling:** Sử dụng `Stream` cho Chat và `Future` cho tác vụ đơn lẻ.
- **Design Pattern:** Factory Constructor (JSON Parsing), Repository Pattern.