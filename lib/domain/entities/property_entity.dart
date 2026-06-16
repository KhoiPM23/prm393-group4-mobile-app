class PropertyEntity {
  final String id;
  final String title;
  final String location;
  final double pricePerNight;
  final double rating;
  final int reviewsCount;
  final String hostName;
  final String hostAvatar;
  final List<String> imageUrls;
  final List<String> amenities;
  final String description;

  const PropertyEntity({
    required this.id,
    required this.title,
    required this.location,
    required this.pricePerNight,
    required this.rating,
    required this.reviewsCount,
    required this.hostName,
    required this.hostAvatar,
    required this.imageUrls,
    required this.amenities,
    required this.description,
  });
}
