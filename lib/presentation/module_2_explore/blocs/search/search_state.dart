import '../../../../domain/entities/property_entity.dart';

abstract class SearchState {}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final List<PropertyEntity> properties;

  SearchLoaded({required this.properties});
}

class SearchFailure extends SearchState {
  final String error;

  SearchFailure({required this.error});
}
