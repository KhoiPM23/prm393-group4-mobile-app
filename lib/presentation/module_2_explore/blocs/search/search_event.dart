abstract class SearchEvent {}

class SearchPropertiesRequested extends SearchEvent {
  final String query;
  final String category;

  SearchPropertiesRequested({required this.query, this.category = ''});
}
