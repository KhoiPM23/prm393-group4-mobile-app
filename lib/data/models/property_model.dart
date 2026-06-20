import '../../domain/entities/property_entity.dart';
import '../datasources/mock_data.dart';
import 'room_model.dart';

class PropertyModel extends PropertyEntity {
  const PropertyModel({
    required super.id,
    required super.title,
    required super.location,
    required super.pricePerNight,
    required super.rating,
    required super.reviewsCount,
    required super.hostName,
    required super.hostAvatar,
    required super.imageUrls,
    required super.amenities,
    required super.description,
    required super.rooms,
    required super.latitude,
    required super.longitude,
    required super.city,
    required super.district,
  });

  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    return PropertyModel(
      id: json['id'] as String,
      title: json['title'] as String,
      location: json['location'] as String,
      pricePerNight: (json['pricePerNight'] as num).toDouble(),
      rating: (json['rating'] as num).toDouble(),
      reviewsCount: json['reviewsCount'] as int,
      hostName: json['hostName'] as String,
      hostAvatar: json['hostAvatar'] as String,
      imageUrls: List<String>.from(json['imageUrls']),
      amenities: List<String>.from(json['amenities']),
      description: json['description'] as String,
      rooms: json['rooms'] != null
          ? (json['rooms'] as List)
              .map((r) => RoomModel.fromJson(r as Map<String, dynamic>))
              .toList()
          : [],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      city: json['city'] as String,
      district: json['district'] as String,
    );
  }

  static List<PropertyModel> mockList() {
    return MockData.getMockProperties()
        .map((e) => PropertyModel.fromJson(e))
        .toList();
  }
}
