import '../../domain/entities/booking_entity.dart';
import '../../domain/repositories/booking_repository.dart';
import '../models/booking_model.dart';
import '../models/property_model.dart';

class MockBookingRepository implements BookingRepository {
  @override
  Future<List<BookingEntity>> getMyBookings() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return BookingModel.mockList();
  }

  @override
  Future<List<BookingEntity>> getAllBookings() async {
    await Future.delayed(const Duration(milliseconds: 600));
    final properties = PropertyModel.mockList();
    final List<BookingEntity> bookings = [];
    final now = DateTime.now();
    
    // Tạo khoảng 15 booking giả ngẫu nhiên trong 30 ngày tới
    for (int i = 0; i < 15; i++) {
      final property = properties[i % properties.length];
      // Random ngày checkIn từ 0 đến 30 ngày tới
      final startDay = i * 2; // Ví dụ: 0, 2, 4, 6...
      final checkIn = now.add(Duration(days: startDay));
      final checkOut = checkIn.add(const Duration(days: 2)); // Đặt 2 ngày
      
      bookings.add(
        BookingModel(
          id: 'b_mock_$i',
          orderCode: 20000 + i,
          userId: 'u_mock',
          propertyId: property.id,
          property: property,
          checkIn: checkIn,
          checkOut: checkOut,
          guests: 2,
          basePrice: property.pricePerNight * 2,
          serviceFee: 100000.0,
          tax: 150000.0,
          discountAmount: 0.0,
          totalPrice: property.pricePerNight * 2 + 250000.0,
          status: BookingStatus.confirmed, // Trạng thái hợp lệ
          updatedAt: now,
        ),
      );
    }
    
    // Thêm các mock data tĩnh có sẵn
    bookings.addAll(BookingModel.mockList());
    return bookings;
  }

  @override
  Future<BookingEntity> createBooking(BookingEntity booking) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return booking; // Mock return
  }

  @override
  Future<void> cancelBooking(String bookingId) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
