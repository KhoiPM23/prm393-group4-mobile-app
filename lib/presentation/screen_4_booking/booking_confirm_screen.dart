import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_dimensions.dart';
import '../widgets/vibe_ui_components.dart';

/// Màn hình Xác nhận Đặt phòng VibeLocals
/// Route: /booking
/// Source: x_c_nh_n_t_ph_ng_vibelocals/code.html
/// Design:
///   - Glassmorphic AppBar (back + title "Xác nhận đặt phòng")
///   - Summary card (room thumbnail + name + location)
///   - Interactive Calendar date picker (tháng 6/2026)
///   - Billing details (price breakdown, promo code input, total)
///   - Payment method radio selector (MoMo, Ngân hàng, QR)
///   - Fixed bottom CTA "Xác nhận & Thanh toán"
class BookingConfirmScreen extends StatefulWidget {
  const BookingConfirmScreen({super.key});

  @override
  State<BookingConfirmScreen> createState() =>
      _BookingConfirmScreenState();
}

class _BookingConfirmScreenState extends State<BookingConfirmScreen> {
  DateTime? _checkIn;
  DateTime? _checkOut;
  int _selectedPayment = 0; // 0=MoMo, 1=Bank, 2=QR
  final _promoController = TextEditingController();
  bool _isPromoApplied = false;
  bool _isLoading = false;

  // Current viewing month
  int _viewMonth = 6; // June
  int _viewYear = 2026;

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  void _selectDate(int day) {
    final date = DateTime(_viewYear, _viewMonth, day);
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
    return DateTime(_viewYear, _viewMonth, day) == _checkIn;
  }

  bool _isEnd(int day) {
    if (_checkOut == null) return false;
    return DateTime(_viewYear, _viewMonth, day) == _checkOut;
  }

  int get _nights {
    if (_checkIn == null || _checkOut == null) return 0;
    return _checkOut!.difference(_checkIn!).inDays;
  }

  double get _roomPrice => 1800000;
  double get _serviceFee => 100000;
  double get _promoDiscount => _isPromoApplied ? 180000 : 0;
  double get _total =>
      (_roomPrice * _nights) + _serviceFee - _promoDiscount;

  String _formatVnd(double amount) {
    final formatted = amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
    return '$formattedđ';
  }

  Future<void> _handleConfirm() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _isLoading = false);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _BookingSuccessDialog(
        onClose: () {
          Navigator.of(context).pop();
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/home', (_) => false);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Top AppBar
          Container(
            color: AppColors.surface.withValues(alpha: 0.9),
            child: SafeArea(
              bottom: false,
              child: Container(
                height: 64,
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back,
                          color: AppColors.primary),
                      style: IconButton.styleFrom(
                        minimumSize: const Size(
                            AppTouchTarget.minSize,
                            AppTouchTarget.minSize),
                      ),
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
                  // Summary Card
                  _SummaryCard(),
                  const SizedBox(height: AppSpacing.md),
                  // Calendar Section
                  _CalendarSection(
                    month: _viewMonth,
                    year: _viewYear,
                    checkIn: _checkIn,
                    checkOut: _checkOut,
                    onDayTap: _selectDate,
                    isInRange: _isInRange,
                    isStart: _isStart,
                    isEnd: _isEnd,
                    onPrevMonth: () {
                      setState(() {
                        if (_viewMonth == 1) {
                          _viewMonth = 12;
                          _viewYear--;
                        } else {
                          _viewMonth--;
                        }
                      });
                    },
                    onNextMonth: () {
                      setState(() {
                        if (_viewMonth == 12) {
                          _viewMonth = 1;
                          _viewYear++;
                        } else {
                          _viewMonth++;
                        }
                      });
                    },
                    nights: _nights,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Billing Details
                  _BillingSection(
                    nights: _nights,
                    roomPrice: _roomPrice,
                    serviceFee: _serviceFee,
                    promoDiscount: _promoDiscount,
                    total: _total,
                    promoController: _promoController,
                    isPromoApplied: _isPromoApplied,
                    onApplyPromo: () {
                      if (_promoController.text.isNotEmpty) {
                        setState(() => _isPromoApplied = true);
                      }
                    },
                    formatVnd: _formatVnd,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Payment Method
                  _PaymentMethodSection(
                    selected: _selectedPayment,
                    onChanged: (v) =>
                        setState(() => _selectedPayment = v),
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
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: VibePrimaryButton(
                  label: 'Xác nhận & Thanh toán',
                  isLoading: _isLoading,
                  trailingIcon: Icons.double_arrow,
                  onPressed:
                      _nights > 0 ? _handleConfirm : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===== SUB-WIDGETS =====

class _SummaryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            child: SizedBox(
              width: 88,
              height: 88,
              child: Image.network(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuBdI9YKJp8xOzG1QeRhnSWDHvyHD5fIL6DoN3rrun6OuYzBZ1ABj9c7n0szgnKu9ZNB45GiPuWQmfNnFKp1PqbBWbWB5OMJRpGk1dFUbeE-uKXJiK10y8MMN1gWZGMsIZ11lJBNet2J-MnwqdvnSPlAZZxtmbt0BPyW47JYid-dgpbGUzmFNUwACMbCXM58nws-WAa6S6WvfPnqiJENxG5SvfirzJDCw2jWsUZIDZjHSAJ9ppLi98joTx0uBY6LSfsqKMJJT9_5S24',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.surfaceContainerHigh,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Phòng Suite Deluxe',
                  style: AppTextStyles.bodyLg.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 14,
                        color: AppColors.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Villa Hội An Heritage',
                        style: AppTextStyles.labelLg.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
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
  final bool Function(int) isInRange, isStart, isEnd;
  final VoidCallback onPrevMonth, onNextMonth;

  const _CalendarSection({
    required this.month,
    required this.year,
    required this.checkIn,
    required this.checkOut,
    required this.onDayTap,
    required this.isInRange,
    required this.isStart,
    required this.isEnd,
    required this.onPrevMonth,
    required this.onNextMonth,
    required this.nights,
  });

  static const _monthNames = [
    '', 'Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4',
    'Tháng 5', 'Tháng 6', 'Tháng 7', 'Tháng 8',
    'Tháng 9', 'Tháng 10', 'Tháng 11', 'Tháng 12',
  ];
  static const _weekdays = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(year, month, 1).weekday % 7;
    final daysInMonth = DateTime(year, month + 1, 0).day;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        children: [
          // Month navigation
          Row(
            children: [
              Text(
                '${_monthNames[month]}, $year',
                style: AppTextStyles.titleLg.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              _CalNavBtn(
                  icon: Icons.chevron_left, onTap: onPrevMonth),
              const SizedBox(width: 4),
              _CalNavBtn(
                  icon: Icons.chevron_right, onTap: onNextMonth),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Weekday headers
          Row(
            children: _weekdays
                .map((d) => Expanded(
                      child: Text(
                        d,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.labelMd.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: AppSpacing.sm),
          // Days grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemCount: firstDay + daysInMonth,
            itemBuilder: (context, i) {
              if (i < firstDay) return const SizedBox();
              final day = i - firstDay + 1;
              final inRange = isInRange(day);
              final start = isStart(day);
              final end = isEnd(day);
              final selected = start || end;
              return GestureDetector(
                onTap: () => onDayTap(day),
                child: Container(
                  decoration: BoxDecoration(
                    color: inRange
                        ? AppColors.primaryFixed
                        : null,
                    borderRadius: BorderRadius.only(
                      topLeft: start
                          ? const Radius.circular(AppRadius.full)
                          : Radius.zero,
                      bottomLeft: start
                          ? const Radius.circular(AppRadius.full)
                          : Radius.zero,
                      topRight: end
                          ? const Radius.circular(AppRadius.full)
                          : Radius.zero,
                      bottomRight: end
                          ? const Radius.circular(AppRadius.full)
                          : Radius.zero,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: selected
                          ? const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            )
                          : null,
                      child: Center(
                        child: Text(
                          '$day',
                          style: AppTextStyles.bodyMd.copyWith(
                            color: selected
                                ? Colors.white
                                : inRange
                                    ? AppColors.onPrimaryFixed
                                    : AppColors.onSurface,
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w400,
                          ),
                        ),
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
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined,
                      color: AppColors.primary, size: 18),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      '${checkIn!.day} Th${checkIn!.month} - ${checkOut!.day} Th${checkOut!.month}, $year',
                      style: AppTextStyles.labelLg.copyWith(
                        color: AppColors.onSurface,
                      ),
                    ),
                  ),
                  Text(
                    '$nights đêm',
                    style: AppTextStyles.labelLg.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: AppTouchTarget.minSize,
        height: AppTouchTarget.minSize,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Icon(icon, size: 22, color: AppColors.onSurface),
      ),
    );
  }
}

class _BillingSection extends StatelessWidget {
  final int nights;
  final double roomPrice, serviceFee, promoDiscount, total;
  final TextEditingController promoController;
  final bool isPromoApplied;
  final VoidCallback onApplyPromo;
  final String Function(double) formatVnd;

  const _BillingSection({
    required this.nights,
    required this.roomPrice,
    required this.serviceFee,
    required this.promoDiscount,
    required this.total,
    required this.promoController,
    required this.isPromoApplied,
    required this.onApplyPromo,
    required this.formatVnd,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chi tiết thanh toán',
          style: AppTextStyles.titleLg.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _BillingRow(
          label:
              '${formatVnd(roomPrice)} x $nights đêm',
          value: formatVnd(roomPrice * nights),
        ),
        const SizedBox(height: AppSpacing.sm),
        _BillingRow(
            label: 'Phí dịch vụ',
            value: formatVnd(serviceFee)),
        if (isPromoApplied) ...[
          const SizedBox(height: AppSpacing.sm),
          _BillingRow(
            label: 'Mã giảm giá',
            value: '-${formatVnd(promoDiscount)}',
            isDiscount: true,
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        // Promo Code
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: promoController,
                style: AppTextStyles.bodyMd,
                decoration: InputDecoration(
                  hintText: 'Nhập mã ưu đãi',
                  hintStyle: AppTextStyles.bodyMd
                      .copyWith(color: AppColors.outline),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppRadius.xl),
                    borderSide: const BorderSide(
                        color: AppColors.outlineVariant),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppRadius.xl),
                    borderSide: const BorderSide(
                        color: AppColors.outlineVariant),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppRadius.xl),
                    borderSide: const BorderSide(
                        color: AppColors.primary, width: 2),
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceContainerLowest,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            GestureDetector(
              onTap: onApplyPromo,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer,
                  borderRadius:
                      BorderRadius.circular(AppRadius.xl),
                ),
                child: Text(
                  'Áp dụng',
                  style: AppTextStyles.labelLg.copyWith(
                    color: AppColors.onSecondaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
        const Divider(
            height: 32,
            color: AppColors.outlineVariant,
            thickness: 0.5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Tổng thanh toán',
              style: AppTextStyles.titleLg.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              formatVnd(nights > 0 ? total : 0),
              style: AppTextStyles.headlineLgMobile.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BillingRow extends StatelessWidget {
  final String label, value;
  final bool isDiscount;
  const _BillingRow(
      {required this.label, required this.value, this.isDiscount = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: AppTextStyles.bodyMd
                .copyWith(color: AppColors.onSurfaceVariant)),
        Text(
          value,
          style: AppTextStyles.bodyMd.copyWith(
            color: isDiscount
                ? AppColors.onTertiaryContainer
                : AppColors.onSurface,
          ),
        ),
      ],
    );
  }
}

class _PaymentMethodSection extends StatelessWidget {
  final int selected;
  final void Function(int) onChanged;

  const _PaymentMethodSection(
      {required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final methods = [
      _PaymentMethod(
          label: 'Ví điện tử MoMo',
          icon: Icons.account_balance_wallet_outlined,
          bgColor: const Color(0xFFFCE4EC),
          iconColor: const Color(0xFFAD1457)),
      _PaymentMethod(
          label: 'Thẻ ngân hàng Nội địa',
          icon: Icons.credit_card_outlined,
          bgColor: const Color(0xFFE3F2FD),
          iconColor: const Color(0xFF1565C0)),
      _PaymentMethod(
          label: 'Chuyển khoản QR',
          icon: Icons.qr_code_2_outlined,
          bgColor: const Color(0xFFE8F5E9),
          iconColor: const Color(0xFF2E7D32)),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phương thức thanh toán',
          style: AppTextStyles.titleLg.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        RadioGroup<int>(
          groupValue: selected,
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: methods.asMap().entries.map((entry) {
              final i = entry.key;
              final m = entry.value;
              final isSelected = selected == i;
              return Padding(
                padding:
                    const EdgeInsets.only(bottom: AppSpacing.sm),
                child: GestureDetector(
                  onTap: () => onChanged(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.outlineVariant,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: m.bgColor,
                            borderRadius:
                                BorderRadius.circular(AppRadius.md),
                          ),
                          child: Icon(m.icon,
                              color: m.iconColor, size: 22),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            m.label,
                            style: AppTextStyles.bodyLg.copyWith(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Radio<int>(
                          value: i,
                          activeColor: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _PaymentMethod {
  final String label;
  final IconData icon;
  final Color bgColor, iconColor;
  const _PaymentMethod({
    required this.label,
    required this.icon,
    required this.bgColor,
    required this.iconColor,
  });
}

class _BookingSuccessDialog extends StatelessWidget {
  final VoidCallback onClose;
  const _BookingSuccessDialog({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.tertiaryFixed,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check,
                  size: 40, color: AppColors.onTertiaryFixed),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Đặt phòng thành công!',
              style: AppTextStyles.headlineLgMobile.copyWith(
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Chuyến đi của bạn tại Villa Hội An Heritage đã được xác nhận. Hẹn gặp bạn tại Hội An!',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            VibePrimaryButton(
              label: 'Về trang chủ',
              onPressed: onClose,
            ),
          ],
        ),
      ),
    );
  }
}
