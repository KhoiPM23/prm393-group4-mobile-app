import 'package:latlong2/latlong.dart';

import '../../../domain/entities/property_entity.dart';

enum MapStatus { initial, loading, loaded, error }

class MapState {
  final MapStatus status;
  final List<PropertyEntity> allProperties; // Danh sách đã lọc theo tiêu chí
  final List<PropertyEntity>
      visibleProperties; // Danh sách nằm gọn trong màn hình máy khách
  final PropertyEntity?
      selectedProperty; // Khách sạn đang được chọn hiển thị ở card đáy

  // Lưu giữ trạng thái bộ lọc hiện hành
  final String searchQuery;
  final String selectedCity;
  final String selectedDistrict;
  final double? minPrice;
  final double? maxPrice;
  final List<String> selectedAmenities;
  final String? errorMessage;

  final LatLng? userLocation;

  MapState({
    required this.status,
    required this.allProperties,
    required this.visibleProperties,
    this.selectedProperty,
    required this.searchQuery,
    required this.selectedCity,
    required this.selectedDistrict,
    this.minPrice,
    this.maxPrice,
    required this.selectedAmenities,
    this.errorMessage,
    this.userLocation,
  });

  factory MapState.initial() {
    return MapState(
      status: MapStatus.initial,
      allProperties: [],
      visibleProperties: [],
      selectedProperty: null,
      searchQuery: '',
      selectedCity: 'Đà Nẵng',
      selectedDistrict: 'Tất cả',
      minPrice: null,
      maxPrice: null,
      selectedAmenities: [],
    );
  }

  MapState copyWith({
    MapStatus? status,
    List<PropertyEntity>? allProperties,
    List<PropertyEntity>? visibleProperties,
    PropertyEntity? Function()? selectedProperty, // Hỗ trợ reset về null
    String? searchQuery,
    String? selectedCity,
    String? selectedDistrict,
    double? Function()? minPrice,
    double? Function()? maxPrice,
    List<String>? selectedAmenities,
    String? Function()? errorMessage,
    LatLng? Function()? userLocation,
  }) {
    return MapState(
      status: status ?? this.status,
      allProperties: allProperties ?? this.allProperties,
      visibleProperties: visibleProperties ?? this.visibleProperties,
      selectedProperty:
          selectedProperty != null ? selectedProperty() : this.selectedProperty,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCity: selectedCity ?? this.selectedCity,
      selectedDistrict: selectedDistrict ?? this.selectedDistrict,
      minPrice: minPrice != null ? minPrice() : this.minPrice,
      maxPrice: maxPrice != null ? maxPrice() : this.maxPrice,
      selectedAmenities: selectedAmenities ?? this.selectedAmenities,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      userLocation: userLocation != null ? userLocation() : this.userLocation,
    );
  }
}
