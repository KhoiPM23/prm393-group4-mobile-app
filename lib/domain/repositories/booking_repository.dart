import '../entities/booking_entity.dart';

abstract class BookingRepository {
  Future<List<BookingEntity>> getMyBookings();
  Future<BookingEntity> createBooking(BookingEntity booking);
  Future<void> cancelBooking(String bookingId);
}
