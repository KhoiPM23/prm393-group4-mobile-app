import '../../domain/entities/booking_entity.dart';
import '../../domain/repositories/booking_repository.dart';
import '../models/booking_model.dart';

class MockBookingRepository implements BookingRepository {
  @override
  Future<List<BookingEntity>> getMyBookings() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return BookingModel.mockList();
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
