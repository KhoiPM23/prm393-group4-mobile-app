import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/models/booking_model.dart';
import '../../domain/entities/booking_entity.dart';
import 'booking_detail_host_screen.dart';

class BookingScheduleScreen extends StatefulWidget {
  const BookingScheduleScreen({super.key});

  @override
  State<BookingScheduleScreen> createState() => _BookingScheduleScreenState();
}

class _BookingScheduleScreenState extends State<BookingScheduleScreen> {
  String _searchQuery = '';
  List<BookingEntity> _allBookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _allBookings = BookingModel.mockList();
      _isLoading = false;
    });
  }

  List<BookingEntity> get _filteredBookings {
    return _allBookings.where((b) {
      // Vì đã xóa guestName, ta dùng ID hoặc thông tin khách sạn để tìm kiếm
      final matchesSearch = b.id.contains(_searchQuery) || 
                            b.property.title.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final bookings = _filteredBookings;
    
    // Thống kê đơn giản dựa trên status gốc
    final pendingCount = bookings.where((b) => b.status == BookingStatus.pending).length;
    final confirmedCount = bookings.where((b) => b.status == BookingStatus.confirmed).length;
    final completedCount = bookings.where((b) => b.status == BookingStatus.completed).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Lịch đặt phòng'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: Column(
        children: [
          _HeaderSection(onSearchChanged: (v) => setState(() => _searchQuery = v)),
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        _StatSmall(label: 'Chờ duyệt', value: '$pendingCount', color: Colors.orange),
                        const SizedBox(width: 10),
                        _StatSmall(label: 'Sắp đến', value: '$confirmedCount', color: Colors.blue),
                        const SizedBox(width: 10),
                        _StatSmall(label: 'Hoàn tất', value: '$completedCount', color: Colors.green),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  sliver: SliverList.separated(
                    itemCount: bookings.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) => _BookingCardSimple(booking: bookings[index]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatSmall extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatSmall({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
        child: Column(children: [
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18)),
          Text(label, style: TextStyle(color: color, fontSize: 10)),
        ]),
      ),
    );
  }
}

class _BookingCardSimple extends StatelessWidget {
  final BookingEntity booking;
  const _BookingCardSimple({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Mã: ${booking.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
              _StatusBadge(status: booking.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(booking.property.title, style: AppTextStyles.bodyMd),
          Text('${booking.checkIn.day}/${booking.checkIn.month} - ${booking.checkOut.day}/${booking.checkOut.month}', style: AppTextStyles.labelMd),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookingDetailHostScreen(booking: booking))),
                child: const Text('Xem chi tiết'),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final BookingStatus status;
  const _StatusBadge({required this.status});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
      child: Text(status.name.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  final Function(String) onSearchChanged;
  const _HeaderSection({required this.onSearchChanged});
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: TextField(
        onChanged: onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Tìm theo mã đặt phòng...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }
}
