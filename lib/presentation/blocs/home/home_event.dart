abstract class HomeEvent {}

class FetchProperties extends HomeEvent {}

class FetchPropertiesByCategory extends HomeEvent {
  final String category;
  FetchPropertiesByCategory(this.category);
}
