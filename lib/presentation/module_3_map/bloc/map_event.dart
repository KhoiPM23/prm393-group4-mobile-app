import 'package:flutter/foundation.dart';

@immutable
abstract class MapEvent {}

// 1. Khởi tạo bản đồ (Mặc định tải danh sách tại Đà Nẵng)
class MapInitialized extends MapEvent {}

// 2. Thay đổi ô nhập tìm kiếm tên khách sạn
class MapSearchInputChanged extends MapEvent {
  final String query;
  MapSearchInputChanged(this.query);
}

// 3. Thay đổi Vùng nhìn bản đồ (Bounding Box) khi kéo/zoom
class MapViewportChanged extends MapEvent {
  final double minLat;
  final double maxLat;
  final double minLng;
  final double maxLng;

  MapViewportChanged({
    required this.minLat,
    required this.maxLat,
    required this.minLng,
    required this.maxLng,
  });
}

// 4. Thay đổi khu vực hành chính ở Dropdown
class MapLocationChanged extends MapEvent {
  final String city;
  final String district;
  MapLocationChanged({required this.city, required this.district});
}

// 5. Áp dụng bộ lọc nâng cao (Giá, Số sao, Tiện ích)
class MapFilterApplied extends MapEvent {
  final double? minPrice;
  final double? maxPrice;
  final List<String> selectedAmenities;

  MapFilterApplied({
    this.minPrice,
    this.maxPrice,
    required this.selectedAmenities,
  });
}

// 6. Nhấn vào một Ghim giá tiền trên bản đồ
class MapMarkerSelected extends MapEvent {
  final String propertyId;
  MapMarkerSelected(this.propertyId);
}
