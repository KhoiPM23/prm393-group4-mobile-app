import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/property_entity.dart';
import '../../../domain/repositories/property_repository.dart';
import 'map_event.dart';
import 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final PropertyRepository _propertyRepository;
  List<PropertyEntity> _masterList = [];

  MapBloc({required PropertyRepository propertyRepository})
      : _propertyRepository = propertyRepository,
        super(MapState.initial()) {
    on<MapInitialized>(_onInitialized);
    on<MapSearchInputChanged>(_onSearchInputChanged);
    on<MapViewportChanged>(_onViewportChanged);
    on<MapLocationChanged>(_onLocationChanged);
    on<MapFilterApplied>(_onFilterApplied);
    on<MapMarkerSelected>(_onMarkerSelected);
    on<MapUserLocationUpdated>(_onUserLocationUpdated);
  }

  String _toUnsignedLower(String text) {
    var str = text.toLowerCase();
    str = str.replaceAll(RegExp(r'[àáạảãâầấậẩẫăằắặẳẵ]'), 'a');
    str = str.replaceAll(RegExp(r'[èéẹẻẽêềếệểễ]'), 'e');
    str = str.replaceAll(RegExp(r'[ìíịỉĩ]'), 'i');
    str = str.replaceAll(RegExp(r'[òóọỏõôồốộổỗơờớợởỡ]'), 'o');
    str = str.replaceAll(RegExp(r'[ùúụủũưừứựửữ]'), 'u');
    str = str.replaceAll(RegExp(r'[ỳýỵỷỹ]'), 'y');
    str = str.replaceAll(RegExp(r'[đ]'), 'd');
    return str;
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
          visibleProperties: filtered));
    } catch (e) {
      emit(state.copyWith(
          status: MapStatus.error, errorMessage: () => e.toString()));
    }
  }

  void _onSearchInputChanged(
      MapSearchInputChanged event, Emitter<MapState> emit) {
    final updatedState =
        state.copyWith(searchQuery: event.query, selectedProperty: () => null);
    final filtered = _applyFilteringPipeline(updatedState);
    emit(updatedState.copyWith(
        allProperties: filtered, visibleProperties: filtered));
  }

  void _onLocationChanged(MapLocationChanged event, Emitter<MapState> emit) {
    final updatedState = state.copyWith(
        selectedCity: event.city,
        selectedDistrict: event.district,
        selectedProperty: () => null);
    final filtered = _applyFilteringPipeline(updatedState);
    emit(updatedState.copyWith(
        allProperties: filtered, visibleProperties: filtered));
  }

  void _onFilterApplied(MapFilterApplied event, Emitter<MapState> emit) {
    final updatedState = state.copyWith(
        minPrice: () => event.minPrice,
        maxPrice: () => event.maxPrice,
        minRating: () => event.minRating,
        selectedAmenities: event.selectedAmenities);
    final filtered = _applyFilteringPipeline(updatedState);
    emit(updatedState.copyWith(
        allProperties: filtered, visibleProperties: filtered));
  }

  void _onViewportChanged(MapViewportChanged event, Emitter<MapState> emit) {
    final visible = state.allProperties.where((p) {
      return p.latitude >= event.minLat &&
          p.latitude <= event.maxLat &&
          p.longitude >= event.minLng &&
          p.longitude <= event.maxLng;
    }).toList();
    emit(state.copyWith(visibleProperties: visible));
  }

  void _onMarkerSelected(MapMarkerSelected event, Emitter<MapState> emit) {
    PropertyEntity? selected;
    for (final p in state.allProperties) {
      if (p.id == event.propertyId) {
        selected = p;
        break;
      }
    }
    emit(state.copyWith(selectedProperty: () => selected));
  }

  void _onUserLocationUpdated(
      MapUserLocationUpdated event, Emitter<MapState> emit) {
    emit(state.copyWith(userLocation: () => event.location));
  }

  List<PropertyEntity> _applyFilteringPipeline(MapState targetState) {
    return _masterList.where((property) {
      if (property.city.toLowerCase() != targetState.selectedCity.toLowerCase())
        return false;
      if (targetState.selectedDistrict != 'Tất cả' &&
          property.district.toLowerCase() !=
              targetState.selectedDistrict.toLowerCase()) return false;

      if (targetState.searchQuery.isNotEmpty) {
        final query = _toUnsignedLower(targetState.searchQuery).trim();
        final matchTitle = _toUnsignedLower(property.title).contains(query);
        final matchDistrict =
            _toUnsignedLower(property.district).contains(query);
        final matchCity = _toUnsignedLower(property.city).contains(query);
        if (!matchTitle && !matchDistrict && !matchCity) return false;
      }

      if (targetState.minPrice != null &&
          property.pricePerNight < targetState.minPrice!) return false;
      if (targetState.maxPrice != null &&
          property.pricePerNight > targetState.maxPrice!) return false;
      if (targetState.minRating != null &&
          property.rating < targetState.minRating!) return false;
      if (targetState.selectedAmenities.isNotEmpty) {
        final hasAll = targetState.selectedAmenities
            .every((a) => property.amenities.contains(a));
        if (!hasAll) return false;
      }
      return true;
    }).toList();
  }
}
