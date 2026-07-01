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
  final double? minRating;
  final List<String> selectedAmenities;
  final DateTime? checkIn;
  final DateTime? checkOut;
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
    this.minRating,
    required this.selectedAmenities,
    this.checkIn,
    this.checkOut,
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
      selectedCity: 'Tất cả',
      selectedDistrict: 'Tất cả',
      minPrice: null,
      maxPrice: null,
      minRating: null,
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
    double? Function()? minRating,
    List<String>? selectedAmenities,
    DateTime? Function()? checkIn,
    DateTime? Function()? checkOut,
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
      minRating: minRating != null ? minRating() : this.minRating,
      selectedAmenities: selectedAmenities ?? this.selectedAmenities,
      checkIn: checkIn != null ? checkIn() : this.checkIn,
      checkOut: checkOut != null ? checkOut() : this.checkOut,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      userLocation: userLocation != null ? userLocation() : this.userLocation,
    );
  }

  int get activeFiltersCount {
    int count = 0;
    if ((minPrice != null && minPrice! > 0) || (maxPrice != null && maxPrice! < 10000000)) count++;
    if (minRating != null) count++;
    count += selectedAmenities.length;
    return count;
  }
}
