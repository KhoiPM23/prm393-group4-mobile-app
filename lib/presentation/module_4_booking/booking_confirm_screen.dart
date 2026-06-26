import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_dimensions.dart';
import '../../domain/entities/property_entity.dart';
import '../../domain/entities/room_entity.dart';
import '../../data/models/property_model.dart';
import '../widgets/vibe_ui_components.dart';

/// Màn hình Xác nhận Đặt phòng VibeLocals
class BookingConfirmScreen extends StatefulWidget {
  const BookingConfirmScreen({super.key});

  @override
  State<BookingConfirmScreen> createState() => _BookingConfirmScreenState();
}

class _BookingConfirmScreenState extends State<BookingConfirmScreen> {
  PropertyEntity? _property;
  RoomEntity? _room;
  DateTime? _checkIn;
  DateTime? _checkOut;
  int _selectedPayment = 0; // 0=MoMo, 1=Bank, 2=QR
  final _promoController = TextEditingController();
  bool _isPromoApplied = false;
  bool _isLoading = false;

  // Current viewing month
  int _viewMonth = DateTime.now().month;
  int _viewYear = DateTime.now().year;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    
    if (args is Map<String, dynamic>) {
      _property = args['property'] as PropertyEntity?;
      _room = args['room'] as RoomEntity?;
    } else if (args is PropertyEntity) {
      _property = args;
    }

    // Fallback để đảm bảo UI không bao giờ bị null
    if (_property == null) {
      try {
        _property = PropertyModel.mockList().first;
        _room = _property?.rooms.first;
      } catch (e) {
        // ...
      }
    }
  }

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  void _selectDate(int day) {
    final date = DateTime(_viewYear, _viewMonth, day);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Chặn chọn ngày trong quá khứ
    if (date.isBefore(today)) return;

    setState(() {
      if (_checkIn == null || (_checkOut != null)) {
        _checkIn = date;
        _checkOut = null;
      } else if (date.isAfter(_checkIn!)) {
        _checkOut = date;
      } else {
        _checkIn = date;
        _checkOut = null;
      }
    });
  }

  bool _isInRange(int day) {
    if (_checkIn == null || _checkOut == null) return false;
    final d = DateTime(_viewYear, _viewMonth, day);
    return d.isAfter(_checkIn!) && d.isBefore(_checkOut!);
  }

  bool _isStart(int day) {
    if (_checkIn == null) return false;
    final d = DateTime(_viewYear, _viewMonth, day);
    return d.year == _checkIn!.year && d.month == _checkIn!.month && d.day == _checkIn!.day;
  }

  bool _isEnd(int day) {
    if (_checkOut == null) return false;
    final d = DateTime(_viewYear, _viewMonth, day);
    return d.year == _checkOut!.year && d.month == _checkOut!.month && d.day == _checkOut!.day;
  }

  bool _isPast(int day) {
    final date = DateTime(_viewYear, _viewMonth, day);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return date.isBefore(today);
  }

  int get _nights {
    if (_checkIn == null || _checkOut == null) return 0;
    return _checkOut!.difference(_checkIn!).inDays;
  }

  // ===== LOGIC TÍNH TOÁN (ĐẢM BẢO DOUBLE) =====
  double get _roomPrice => _room?.pricePerNight ?? _property?.pricePerNight ?? 0.0;
  double get _subtotal => _roomPrice * _nights;
  double get _serviceFee => _subtotal * 0.05; 
  double get _tax => _subtotal * 0.08;
  double get _promoDiscount => _isPromoApplied ? (_subtotal * 0.1) : 0.0;
  double get _total => _subtotal + _serviceFee + _tax - _promoDiscount;

  String _formatVnd(double amount) {
    final formatted = amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
    return '$formattedđ';
  }

  Future<void> _handleConfirm() async {
    if (_property == null) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    setState(() => _isLoading = false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _BookingSuccessDialog(
        propertyName: _room?.title ?? _property!.title,
        onClose: () {
          Navigator.of(context).pop();
          Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_property == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Glassmorphic Top AppBar
          Container(
            color: AppColors.surface.withValues(alpha: 0.9),
            child: SafeArea(
              bottom: false,
              child: Container(
                height: 64,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                decoration: BoxDecoration(
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)],
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back, color: AppColors.primary),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Xác nhận đặt phòng',
                      style: AppTextStyles.titleLg.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SummaryCard(
                  property: _property!,
                  room: _room,
                ),
                  const SizedBox(height: AppSpacing.md),
                  _CalendarSection(
                    month: _viewMonth,
                    year: _viewYear,
                    checkIn: _checkIn,
                    checkOut: _checkOut,
                    onDayTap: _selectDate,
                    isInRange: _isInRange,
                    isStart: _isStart,
                    isEnd: _isEnd,
                    isPast: _isPast,
                    onPrevMonth: () => setState(() {
                      if (_viewMonth == 1) { _viewMonth = 12; _viewYear--; } else { _viewMonth--; }
                    }),
                    onNextMonth: () => setState(() {
                      if (_viewMonth == 12) { _viewMonth = 1; _viewYear++; } else { _viewMonth++; }
                    }),
                    nights: _nights,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _BillingSection(
                    nights: _nights,
                    roomPrice: _roomPrice,
                    serviceFee: _serviceFee,
                    tax: _tax,
                    promoDiscount: _promoDiscount,
                    total: _total,
                    promoController: _promoController,
                    isPromoApplied: _isPromoApplied,
                    onApplyPromo: () {
                      if (_promoController.text.isNotEmpty) setState(() => _isPromoApplied = true);
                    },
                    formatVnd: _formatVnd,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _PaymentMethodSection(
                    selected: _selectedPayment,
                    onChanged: (v) => setState(() => _selectedPayment = v),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          // Fixed CTA
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.9),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0, -4))],
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: VibePrimaryButton(
                  label: 'Xác nhận & Thanh toán',
                  isLoading: _isLoading,
                  trailingIcon: Icons.double_arrow,
                  onPressed: _nights > 0 ? _handleConfirm : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===== SUB-WIDGETS (RESTORED LAYOUT) =====

class _SummaryCard extends StatelessWidget {
  final PropertyEntity property;
  final RoomEntity? room;
  const _SummaryCard({required this.property, this.room});

  @override
  Widget build(BuildContext context) {
    final title = room?.title ?? property.title;
    final location = room != null ? property.title : property.location;
    final imageUrl = room?.imageUrls.isNotEmpty == true 
        ? room!.imageUrls.first 
        : (property.imageUrls.isNotEmpty ? property.imageUrls.first : '');

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4)],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            child: SizedBox(
              width: 88,
              height: 88,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: AppColors.surfaceContainerHigh),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodyLg.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: AppColors.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Expanded(child: Text(location, style: AppTextStyles.labelLg.copyWith(color: AppColors.onSurfaceVariant))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarSection extends StatelessWidget {
  final int month, year, nights;
  final DateTime? checkIn, checkOut;
  final void Function(int) onDayTap;
  final bool Function(int) isInRange, isStart, isEnd, isPast;
  final VoidCallback onPrevMonth, onNextMonth;

  const _CalendarSection({required this.month, required this.year, required this.checkIn, required this.checkOut, required this.onDayTap, required this.isInRange, required this.isStart, required this.isEnd, required this.isPast, required this.onPrevMonth, required this.onNextMonth, required this.nights});

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(year, month, 1).weekday % 7;
    final daysInMonth = DateTime(year, month + 1, 0).day;
    const monthNames = ['', 'Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4', 'Tháng 5', 'Tháng 6', 'Tháng 7', 'Tháng 8', 'Tháng 9', 'Tháng 10', 'Tháng 11', 'Tháng 12'];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text('${monthNames[month]}, $year', style: AppTextStyles.titleLg.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
              const Spacer(),
              _CalNavBtn(icon: Icons.chevron_left, onTap: onPrevMonth),
              const SizedBox(width: 4),
              _CalNavBtn(icon: Icons.chevron_right, onTap: onNextMonth),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(children: ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'].map((d) => Expanded(child: Text(d, textAlign: TextAlign.center, style: AppTextStyles.labelMd.copyWith(color: AppColors.onSurfaceVariant)))).toList()),
          const SizedBox(height: AppSpacing.sm),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, childAspectRatio: 1),
            itemCount: firstDay + daysInMonth,
            itemBuilder: (context, i) {
              if (i < firstDay) return const SizedBox();
              final day = i - firstDay + 1;
              final selected = isStart(day) || isEnd(day);
              final inRange = isInRange(day);
              final past = isPast(day);
              
              return GestureDetector(
                onTap: past ? null : () => onDayTap(day),
                child: Container(
                  decoration: BoxDecoration(
                    color: inRange ? AppColors.primaryFixed : null,
                    borderRadius: isStart(day) ? const BorderRadius.horizontal(left: Radius.circular(AppRadius.full)) : isEnd(day) ? const BorderRadius.horizontal(right: Radius.circular(AppRadius.full)) : null,
                  ),
                  child: Center(
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: selected ? const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle) : null,
                      child: Center(
                        child: Text(
                          '$day', 
                          style: AppTextStyles.bodyMd.copyWith(
                            color: past ? AppColors.outline : (selected ? Colors.white : (inRange ? AppColors.onPrimaryFixed : AppColors.onSurface)), 
                            fontWeight: selected ? FontWeight.w700 : FontWeight.w400
                          )
                        )
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          if (nights > 0) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(color: AppColors.surfaceContainer, borderRadius: BorderRadius.circular(AppRadius.xl)),
              child: Row(children: [
                const Icon(Icons.calendar_today_outlined, color: AppColors.primary, size: 18),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: Text('${checkIn!.day} Th${checkIn!.month} - ${checkOut!.day} Th${checkOut!.month}, $year', style: AppTextStyles.labelLg)),
                Text('$nights đêm', style: AppTextStyles.labelLg.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
              ]),
            ),
          ],
        ],
      ),
    );
  }
}

class _CalNavBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CalNavBtn({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onTap, child: Container(width: 40, height: 40, decoration: const BoxDecoration(color: AppColors.surfaceContainerHigh, shape: BoxShape.circle), child: Icon(icon, size: 22, color: AppColors.onSurface)));
  }
}

class _BillingSection extends StatelessWidget {
  final int nights;
  final double roomPrice, serviceFee, tax, promoDiscount, total;
  final TextEditingController promoController;
  final bool isPromoApplied;
  final VoidCallback onApplyPromo;
  final String Function(double) formatVnd;

  const _BillingSection({required this.nights, required this.roomPrice, required this.serviceFee, required this.tax, required this.promoDiscount, required this.total, required this.promoController, required this.isPromoApplied, required this.onApplyPromo, required this.formatVnd});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Chi tiết thanh toán', style: AppTextStyles.titleLg.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
        const SizedBox(height: AppSpacing.md),
        _BillingRow(label: '${formatVnd(roomPrice)} x $nights đêm', value: formatVnd(roomPrice * nights)),
        _BillingRow(label: 'Phí dịch vụ (5%)', value: formatVnd(serviceFee)),
        _BillingRow(label: 'Thuế VAT (8%)', value: formatVnd(tax)),
        if (isPromoApplied) _BillingRow(label: 'Mã giảm giá', value: '-${formatVnd(promoDiscount)}', isDiscount: true),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: promoController,
                decoration: InputDecoration(
                  hintText: 'Nhập mã ưu đãi',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
                  filled: true, fillColor: AppColors.surfaceContainerLowest,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            GestureDetector(
              onTap: onApplyPromo,
              child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), decoration: BoxDecoration(color: AppColors.secondaryContainer, borderRadius: BorderRadius.circular(AppRadius.xl)), child: Text('Áp dụng', style: AppTextStyles.labelLg.copyWith(color: AppColors.onSecondaryContainer, fontWeight: FontWeight.w700))),
            ),
          ],
        ),
        const Divider(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Tổng thanh toán', style: AppTextStyles.titleLg.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
            Text(formatVnd(nights > 0 ? total : 0.0), style: AppTextStyles.headlineLgMobile.copyWith(color: AppColors.primary, fontWeight: FontWeight.w800)),
          ],
        ),
      ],
    );
  }
}

class _BillingRow extends StatelessWidget {
  final String label, value;
  final bool isDiscount;
  const _BillingRow({required this.label, required this.value, this.isDiscount = false});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
          Text(value, style: AppTextStyles.bodyMd.copyWith(color: isDiscount ? AppColors.error : AppColors.onSurface)),
        ],
      ),
    );
  }
}

class _PaymentMethodSection extends StatelessWidget {
  final int selected;
  final void Function(int) onChanged;
  const _PaymentMethodSection({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final methods = [
      {'name': 'Ví điện tử MoMo', 'icon': Icons.account_balance_wallet_outlined, 'color': Color(0xFFAD1457), 'bg': Color(0xFFFCE4EC)},
      {'name': 'Thẻ ngân hàng', 'icon': Icons.credit_card_outlined, 'color': Color(0xFF1565C0), 'bg': Color(0xFFE3F2FD)},
      {'name': 'Chuyển khoản QR', 'icon': Icons.qr_code_2_outlined, 'color': Color(0xFF2E7D32), 'bg': Color(0xFFE8F5E9)},
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Phương thức thanh toán', style: AppTextStyles.titleLg.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
        const SizedBox(height: AppSpacing.md),
        RadioGroup<int>(
          groupValue: selected,
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
          child: Column(
            children: List.generate(methods.length, (i) {
              final isSelected = selected == i;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GestureDetector(
                  onTap: () => onChanged(i),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.outlineVariant,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: methods[i]['bg'] as Color,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            methods[i]['icon'] as IconData,
                            color: methods[i]['color'] as Color,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            methods[i]['name'] as String,
                            style: AppTextStyles.bodyLg.copyWith(fontWeight: FontWeight.w500),
                          ),
                        ),
                        Radio<int>(value: i, activeColor: AppColors.primary),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _BookingSuccessDialog extends StatelessWidget {
  final String propertyName;
  final VoidCallback onClose;
  const _BookingSuccessDialog({required this.propertyName, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.card)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, size: 72, color: AppColors.tertiary),
            const SizedBox(height: AppSpacing.md),
            Text('Đặt phòng thành công!', style: AppTextStyles.headlineLgMobile, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text('Chuyến đi của bạn tại $propertyName đã được xác nhận.', textAlign: TextAlign.center, style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 24),
            VibePrimaryButton(label: 'Về trang chủ', onPressed: onClose),
          ],
        ),
      ),
    );
  }
}
