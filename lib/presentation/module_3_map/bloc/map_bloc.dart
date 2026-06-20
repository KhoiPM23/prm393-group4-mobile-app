import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/property_entity.dart';
import '../../../domain/repositories/property_repository.dart';
import 'map_event.dart';
import 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final PropertyRepository _propertyRepository;
  List<PropertyEntity> _masterList =
      []; // Lưu danh sách gốc từ DB để làm mốc lọc

  MapBloc({required PropertyRepository propertyRepository})
      : _propertyRepository = propertyRepository,
        super(MapState.initial()) {
    on<MapInitialized>(_onInitialized);
    on<MapSearchInputChanged>(_onSearchInputChanged);
    on<MapViewportChanged>(_onViewportChanged);
    on<MapLocationChanged>(_onLocationChanged);
    on<MapFilterApplied>(_onFilterApplied);
    on<MapMarkerSelected>(_onMarkerSelected);
  }

  Future<void> _onInitialized(
      MapInitialized event, Emitter<MapState> emit) async {
    emit(state.copyWith(status: MapStatus.loading));
    try {
      final result = await _propertyRepository.getProperties();
      _masterList = result;

      final filtered = _applyFilteringPipeline(state);
      emit(state.copyWith(
        status: MapStatus.loaded,
        allProperties: filtered,
        visibleProperties:
            filtered, // Mặc định khi chưa kéo map thì hiển thị hết
      ));
    } catch (e) {
      emit(state.copyWith(
          status: MapStatus.error, errorMessage: () => e.toString()));
    }
  }

  void _onSearchInputChanged(
      MapSearchInputChanged event, Emitter<MapState> emit) {
    final updatedState = state.copyWith(searchQuery: event.query);
    final filtered = _applyFilteringPipeline(updatedState);
    emit(updatedState.copyWith(
        allProperties: filtered, visibleProperties: filtered));
  }

  void _onLocationChanged(MapLocationChanged event, Emitter<MapState> emit) {
    final updatedState = state.copyWith(
      selectedCity: event.city,
      selectedDistrict: event.district,
    );
    final filtered = _applyFilteringPipeline(updatedState);
    emit(updatedState.copyWith(
        allProperties: filtered,
        visibleProperties: filtered,
        selectedProperty: () => null));
  }

  void _onFilterApplied(MapFilterApplied event, Emitter<MapState> emit) {
    final updatedState = state.copyWith(
      minPrice: () => event.minPrice,
      maxPrice: () => event.maxPrice,
      selectedAmenities: event.selectedAmenities,
    );
    final filtered = _applyFilteringPipeline(updatedState);
    emit(updatedState.copyWith(
        allProperties: filtered, visibleProperties: filtered));
  }

  void _onViewportChanged(MapViewportChanged event, Emitter<MapState> emit) {
    // Thuật toán Spatial Boundary Check (Lọc phần tử nằm trong khung màn hình)
    final visible = state.allProperties.where((p) {
      return p.latitude >= event.minLat &&
          p.latitude <= event.maxLat &&
          p.longitude >= event.minLng &&
          p.longitude <= event.maxLng;
    }).toList();

    emit(state.copyWith(visibleProperties: visible));
  }

  void _onMarkerSelected(MapMarkerSelected event, Emitter<MapState> emit) {
    final selected = state.allProperties.firstWhere(
      (p) => p.id == event.propertyId,
      orElse: () => state.allProperties.first,
    );
    emit(state.copyWith(selectedProperty: () => selected));
  }

  // ===== PIPELINE LỌC ĐA TIÊU CHÍ (SCALABLE ARCHITECTURE) =====
  List<PropertyEntity> _applyFilteringPipeline(MapState targetState) {
    return _masterList.where((property) {
      // Pipe 1: Lọc theo thành phố
      if (property.city.toLowerCase() !=
          targetState.selectedCity.toLowerCase()) {
        return false;
      }

      // Pipe 2: Lọc theo quận huyện (nếu chọn cụ thể)
      if (targetState.selectedDistrict != 'Tất cả' &&
          property.district.toLowerCase() !=
              targetState.selectedDistrict.toLowerCase()) {
        {
          return false;
        }
      }

      // Pipe 3: Lọc theo tên từ khóa nhập vào
      if (targetState.searchQuery.isNotEmpty &&
          !property.title
              .toLowerCase()
              .contains(targetState.searchQuery.toLowerCase())) {
        {
          return false;
        }
      }

      // Pipe 4: Lọc theo khoảng giá
      if (targetState.minPrice != null &&
          property.pricePerNight < targetState.minPrice!) {
        return false;
      }
      if (targetState.maxPrice != null &&
          property.pricePerNight > targetState.maxPrice!) {
        return false;
      }

      // Pipe 5: Lọc theo danh sách tiện ích tích hợp
      if (targetState.selectedAmenities.isNotEmpty) {
        final hasAll = targetState.selectedAmenities
            .every((a) => property.amenities.contains(a));
        if (!hasAll) {
          return false;
        }
      }

      return true;
    }).toList();
  }
}
