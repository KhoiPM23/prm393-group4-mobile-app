import 'room_entity.dart';

class PropertyEntity {
  final String id;
  final String title;
  final String location;
  final double pricePerNight;
  final double rating;
  final int reviewsCount;
  final String hostId;
  final String hostName;
  final String hostAvatar;
  final List<String> imageUrls;
  final List<String> amenities;
  final String description;
  final List<RoomEntity> rooms; // MỚI: Danh sách phòng

  final List<String> categories; // Thêm trường danh mục
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
    required this.hostId,
    required this.hostName,
    required this.hostAvatar,
    required this.imageUrls,
    required this.amenities,
    required this.description,
    required this.rooms,
    required this.categories,
    required this.latitude,
    required this.longitude,
    required this.city,
    required this.district,
  });
}
