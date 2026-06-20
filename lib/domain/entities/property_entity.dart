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

  // ===== THÀNH PHẦN MỞ RỘNG CHO MODULE MAP =====
  final double latitude; // Kinh độ để chấm ghim bản đồ
  final double longitude; // Vĩ độ để chấm ghim bản đồ
  final String city; // Thành phố (Mặc định: Đà Nẵng)
  final String district; // Quận/Phường hỗ trợ bộ lọc thông minh

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
    required this.latitude,
    required this.longitude,
    required this.city,
    required this.district,
  });
}
