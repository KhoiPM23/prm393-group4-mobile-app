import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/repositories/property_repository.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final PropertyRepository propertyRepository;

  HomeBloc({required this.propertyRepository}) : super(HomeInitial()) {
    on<FetchProperties>(_onFetchProperties);
    on<FetchPropertiesByCategory>(_onFetchPropertiesByCategory);
  }
  
  Future<void> _onFetchProperties(
    FetchProperties event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());
    try {
      final properties = await propertyRepository.getFeaturedProperties();
      emit(HomeLoaded(properties: properties));
    } catch (e) {
      emit(HomeFailure(error: e.toString()));
    }
  }

  Future<void> _onFetchPropertiesByCategory(
    FetchPropertiesByCategory event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());
    try {
      // Dùng hàm searchProperties với query rỗng, truyền vào category
      final properties = await propertyRepository.searchProperties('', event.category);
      emit(HomeLoaded(properties: properties));
    } catch (e) {
      emit(HomeFailure(error: e.toString()));
    }
  }
}
