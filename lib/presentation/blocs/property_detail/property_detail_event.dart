abstract class PropertyDetailEvent {}

class PropertyDetailLoadRequested extends PropertyDetailEvent {
  final String propertyId;

  PropertyDetailLoadRequested({required this.propertyId});
}
