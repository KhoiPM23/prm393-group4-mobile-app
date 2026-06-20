import '../../domain/entities/room_entity.dart';

class RoomModel extends RoomEntity {
  const RoomModel({
    required super.id,
    required super.title,
    required super.type,
    required super.pricePerNight,
    required super.amenities,
    required super.imageUrls,
    required super.description,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'] as String,
      title: json['title'] as String,
      type: json['type'] as String,
      pricePerNight: (json['pricePerNight'] as num).toDouble(),
      amenities: List<String>.from(json['amenities'] as List),
      imageUrls: List<String>.from(json['imageUrls'] as List),
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'pricePerNight': pricePerNight,
      'amenities': amenities,
      'imageUrls': imageUrls,
      'description': description,
    };
  }
}
