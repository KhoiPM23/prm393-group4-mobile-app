import 'property_entity.dart';

class BookingEntity {
  final String id;
  final PropertyEntity property;
  final DateTime checkIn;
  final DateTime checkOut;
  final int guests;
  final double totalPrice;
  final String status; // e.g., 'Upcoming', 'Completed', 'Cancelled'

  const BookingEntity({
    required this.id,
    required this.property,
    required this.checkIn,
    required this.checkOut,
    required this.guests,
    required this.totalPrice,
    required this.status,
  });
}
