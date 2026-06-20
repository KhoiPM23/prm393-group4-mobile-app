import 'property_entity.dart';

enum BookingStatus { pending, confirmed, paid, cancelled, completed, failed }

class BookingEntity {
  final String id;
  final String userId;
  final String propertyId;
  final PropertyEntity property;
  final DateTime checkIn;
  final DateTime checkOut;
  final int guests;
  final double basePrice;
  final double serviceFee;
  final double tax;
  final double discountAmount;
  final double totalPrice;
  final String? promoCode;
  final BookingStatus status;
  final DateTime updatedAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final String? paymentMethod;
  final String? transactionId;

  const BookingEntity({
    required this.id,
    required this.userId,
    required this.propertyId,
    required this.property,
    required this.checkIn,
    required this.checkOut,
    required this.guests,
    required this.basePrice,
    required this.serviceFee,
    required this.tax,
    required this.discountAmount,
    required this.totalPrice,
    this.promoCode,
    required this.status,
    required this.updatedAt,
    this.cancelledAt,
    this.cancellationReason,
    this.paymentMethod,
    this.transactionId,
  });
}
