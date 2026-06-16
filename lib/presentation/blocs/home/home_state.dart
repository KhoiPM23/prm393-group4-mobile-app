import '../../../../domain/entities/property_entity.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<PropertyEntity> properties;
  
  HomeLoaded({required this.properties});
}

class HomeFailure extends HomeState {
  final String error;

  HomeFailure({required this.error});
}
