import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_text_styles.dart';
import '../../domain/entities/booking_entity.dart';

class BookingDetailHostScreen extends StatelessWidget {
  final BookingEntity booking;

  const BookingDetailHostScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Chi tiết đặt phòng'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailCard(children: [
              _DetailRow(label: 'Mã booking', value: '#${booking.id}', isBold: true),
              _DetailRow(label: 'Trạng thái', value: booking.status.name.toUpperCase()),
              _DetailRow(label: 'Khách sạn', value: booking.property.title),
              _DetailRow(label: 'Ngày nhận phòng', value: '${booking.checkIn.day}/${booking.checkIn.month}/${booking.checkIn.year}'),
              _DetailRow(label: 'Ngày trả phòng', value: '${booking.checkOut.day}/${booking.checkOut.month}/${booking.checkOut.year}'),
              _DetailRow(label: 'Số lượng khách', value: '${booking.guests} người'),
              _DetailRow(label: 'Tổng tiền', value: '${booking.totalPrice.toStringAsFixed(0)}đ'),
              _DetailRow(label: 'Phương thức', value: booking.paymentMethod ?? 'Chưa xác định'),
            ]),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Quay lại'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final List<Widget> children;
  const _DetailCard({required this.children});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)],
      ),
      child: Column(children: children),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label, value;
  final bool isBold;
  const _DetailRow({required this.label, required this.value, this.isBold = false});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
