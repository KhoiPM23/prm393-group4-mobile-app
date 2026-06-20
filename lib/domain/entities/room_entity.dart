class RoomEntity {
  final String id;
  final String title;
  final String type; // Single, Double, Suite, Villa, etc.
  final double pricePerNight;
  final List<String> amenities;
  final List<String> imageUrls;
  final String description;

  const RoomEntity({
    required this.id,
    required this.title,
    required this.type,
    required this.pricePerNight,
    required this.amenities,
    required this.imageUrls,
    required this.description,
  });
}
