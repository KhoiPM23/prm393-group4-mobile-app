abstract class PropertyDetailState {}

class PropertyDetailInitial extends PropertyDetailState {}

class PropertyDetailLoading extends PropertyDetailState {}

class PropertyDetailLoaded extends PropertyDetailState {
  // Add property data
}

class PropertyDetailFailure extends PropertyDetailState {
  final String error;

  PropertyDetailFailure({required this.error});
}
