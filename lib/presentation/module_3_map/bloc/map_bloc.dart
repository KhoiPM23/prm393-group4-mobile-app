import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/property_entity.dart';
import '../../../domain/repositories/property_repository.dart';
import '../../../domain/entities/booking_entity.dart';
import '../../../domain/repositories/booking_repository.dart';
import 'map_event.dart';
import 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final PropertyRepository _propertyRepository;
  final BookingRepository _bookingRepository;
  
  List<PropertyEntity> _masterList = [];
  List<BookingEntity> _allBookings = [];

  MapBloc({
    required PropertyRepository propertyRepository,
    required BookingRepository bookingRepository,
  })  : _propertyRepository = propertyRepository,
        _bookingRepository = bookingRepository,
        super(MapState.initial()) {
    on<MapInitialized>(_onInitialized);
    on<MapSearchInputChanged>(_onSearchInputChanged);
    on<MapViewportChanged>(_onViewportChanged);
    on<MapLocationChanged>(_onLocationChanged);
    on<MapFilterApplied>(_onFilterApplied);
    on<MapMarkerSelected>(_onMarkerSelected);
    on<MapUserLocationUpdated>(_onUserLocationUpdated);
    on<MapDateRangeSelected>(_onDateRangeSelected);
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

  int _calculateScore(PropertyEntity property, String query) {
    final title = _toUnsignedLower(property.title);
    final district = _toUnsignedLower(property.district);
    final city = _toUnsignedLower(property.city);

    if (city.startsWith(query)) return 5;
    if (district.startsWith(query)) return 4;
    if (title.startsWith(query)) return 3;
    if (city.contains(query)) return 2;
    if (district.contains(query)) return 1;
    return 0;
  }

  Future<void> _onInitialized(
      MapInitialized event, Emitter<MapState> emit) async {
    emit(state.copyWith(status: MapStatus.loading));
    try {
      final propertiesFuture = _propertyRepository.getProperties();
      final bookingsFuture = _bookingRepository.getAllBookings();
      
      final results = await Future.wait([propertiesFuture, bookingsFuture]);
      
      _masterList = results[0] as List<PropertyEntity>;
      _allBookings = results[1] as List<BookingEntity>;
      
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
    String newQuery = state.searchQuery;
    if (event.isGesture && visible.isEmpty) {
      newQuery = 'Khu vực bản đồ';
    }

    emit(state.copyWith(
      visibleProperties: visible,
      searchQuery: newQuery,
    ));
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

  void _onDateRangeSelected(
      MapDateRangeSelected event, Emitter<MapState> emit) {
    final updatedState = state.copyWith(
        checkIn: () => event.checkIn, 
        checkOut: () => event.checkOut,
        selectedProperty: () => null); // Reset selected property
    final filtered = _applyFilteringPipeline(updatedState);
    emit(updatedState.copyWith(
        allProperties: filtered, visibleProperties: filtered));
  }

  bool _isPropertyAvailable(PropertyEntity property, DateTime checkIn, DateTime checkOut) {
    // Lọc ra các booking của property này
    final propertyBookings = _allBookings.where((b) => b.propertyId == property.id).toList();
    
    for (final booking in propertyBookings) {
      // Chỉ quan tâm các booking đã xác nhận hoặc đã thanh toán
      if (booking.status != BookingStatus.confirmed && booking.status != BookingStatus.paid) {
        continue;
      }
      
      // Kiểm tra overlap thời gian
      // Overlap xảy ra khi: checkIn của khách < checkOut của booking VÀ checkOut của khách > checkIn của booking
      final isOverlapping = checkIn.isBefore(booking.checkOut) && checkOut.isAfter(booking.checkIn);
      
      if (isOverlapping) {
        return false; // Hết phòng
      }
    }
    return true; // Có phòng trống
  }

  List<PropertyEntity> _applyFilteringPipeline(MapState targetState) {
    List<PropertyEntity> results = _masterList.where((property) {
      if (targetState.selectedCity != 'Tất cả' && targetState.selectedCity.isNotEmpty &&
          property.city.toLowerCase() != targetState.selectedCity.toLowerCase())
        return false;
      if (targetState.selectedDistrict != 'Tất cả' &&
          property.district.toLowerCase() !=
              targetState.selectedDistrict.toLowerCase()) return false;

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
      
      // Lọc theo ngày (Giả lập)
      if (targetState.checkIn != null && targetState.checkOut != null) {
        if (!_isPropertyAvailable(property, targetState.checkIn!, targetState.checkOut!)) {
          return false;
        }
      }
      
      return true;
    }).toList();

    // 2. Lọc và chấm điểm (Scoring) theo searchQuery
    final rawQuery = targetState.searchQuery;
    if (rawQuery.isNotEmpty && 
        rawQuery != 'Khu vực bản đồ' && 
        rawQuery != 'Mọi nơi') {
      final query = _toUnsignedLower(rawQuery).trim();
      
      // Lọc bỏ những property không khớp
      results = results.where((property) {
        final matchTitle = _toUnsignedLower(property.title).contains(query);
        final matchDistrict = _toUnsignedLower(property.district).contains(query);
        final matchCity = _toUnsignedLower(property.city).contains(query);
        return matchTitle || matchDistrict || matchCity;
      }).toList();

      // Sắp xếp theo mức độ phù hợp
      results.sort((a, b) {
        int scoreA = _calculateScore(a, query);
        int scoreB = _calculateScore(b, query);
        if (scoreA != scoreB) {
          return scoreB.compareTo(scoreA); // Điểm cao hơn xếp trên
        }
        return a.title.compareTo(b.title); // Bằng điểm thì sort alphabet theo tên
      });
    }

    return results;
  }
}
