import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/repositories/property_repository.dart';
import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final PropertyRepository propertyRepository;

  SearchBloc({required this.propertyRepository}) : super(SearchInitial()) {
    on<SearchPropertiesRequested>(_onSearchPropertiesRequested);
  }

  Future<void> _onSearchPropertiesRequested(
    SearchPropertiesRequested event,
    Emitter<SearchState> emit,
  ) async {
    emit(SearchLoading());
    try {
      final properties = await propertyRepository.searchProperties(
          event.query, event.category);
      emit(SearchLoaded(properties: properties));
    } catch (e) {
      emit(SearchFailure(error: e.toString()));
    }
  }
}
