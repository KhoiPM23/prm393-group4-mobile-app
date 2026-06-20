import '../../domain/entities/booking_entity.dart';
import 'property_model.dart';
import '../datasources/mock_data.dart';

class BookingModel extends BookingEntity {
  const BookingModel({
    required super.id,
    required super.userId,
    required super.propertyId,
    required super.property,
    required super.checkIn,
    required super.checkOut,
    required super.guests,
    required super.basePrice,
    required super.serviceFee,
    required super.tax,
    required super.discountAmount,
    required super.totalPrice,
    super.promoCode,
    required super.status,
    required super.updatedAt,
    super.cancelledAt,
    super.cancellationReason,
    super.paymentMethod,
    super.transactionId,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as String,
      userId: json['userId'] as String? ?? 'user_default',
      propertyId: json['propertyId'] as String? ?? 'prop_default',
      property: PropertyModel.fromJson(json['property'] as Map<String, dynamic>),
      checkIn: DateTime.parse(json['checkIn'] as String),
      checkOut: DateTime.parse(json['checkOut'] as String),
      guests: json['guests'] as int,
      basePrice: (json['basePrice'] as num? ?? (json['totalPrice'] as num)).toDouble(),
      serviceFee: (json['serviceFee'] as num? ?? 0).toDouble(),
      tax: (json['tax'] as num? ?? 0).toDouble(),
      discountAmount: (json['discountAmount'] as num? ?? 0).toDouble(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      promoCode: json['promoCode'] as String?,
      status: _statusFromString(json['status'] as String),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String) 
          : DateTime.now(),
      cancelledAt: json['cancelledAt'] != null ? DateTime.parse(json['cancelledAt'] as String) : null,
      cancellationReason: json['cancellationReason'] as String?,
      paymentMethod: json['paymentMethod'] as String?,
      transactionId: json['transactionId'] as String?,
    );
  }

  static BookingStatus _statusFromString(String status) {
    return BookingStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => BookingStatus.pending,
    );
  }

  static List<BookingModel> mockList() {
    return MockData.getMockBookings().map((e) => BookingModel.fromJson(e)).toList();
  }
}
