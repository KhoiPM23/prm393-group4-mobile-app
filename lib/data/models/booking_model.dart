import '../../domain/entities/booking_entity.dart';
import 'property_model.dart';
import '../datasources/mock_data.dart';

class BookingModel extends BookingEntity {
  const BookingModel({
    required super.id,
    required super.property,
    required super.checkIn,
    required super.checkOut,
    required super.guests,
    required super.totalPrice,
    required super.status,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as String,
      property: PropertyModel.fromJson(json['property'] as Map<String, dynamic>),
      checkIn: DateTime.parse(json['checkIn'] as String),
      checkOut: DateTime.parse(json['checkOut'] as String),
      guests: json['guests'] as int,
      totalPrice: (json['totalPrice'] as num).toDouble(),
      status: json['status'] as String,
    );
  }

  static List<BookingModel> mockList() {
    return MockData.getMockBookings().map((e) => BookingModel.fromJson(e)).toList();
  }
}
