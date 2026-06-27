import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_dimensions.dart';
import '../../domain/entities/property_entity.dart';
import '../../domain/entities/room_entity.dart';
import '../../data/models/property_model.dart';
import '../../data/repositories/payos_repository.dart';
import '../widgets/vibe_ui_components.dart';
import 'dart:async';
import 'package:app_links/app_links.dart'; // Thêm import này

/// Màn hình Xác nhận Đặt phòng VibeLocals
class BookingConfirmScreen extends StatefulWidget {
  const BookingConfirmScreen({super.key});

  @override
  State<BookingConfirmScreen> createState() => _BookingConfirmScreenState();
}

class _BookingConfirmScreenState extends State<BookingConfirmScreen> with WidgetsBindingObserver {
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;
  PropertyEntity? _property;
  RoomEntity? _room;
  DateTime? _checkIn;
  DateTime? _checkOut;
  int _selectedPayment = 0; // 0=MoMo, 1=Bank, 2=QR
  final _promoController = TextEditingController();
  bool _isPromoApplied = false;
  bool _isLoading = false;
  bool _isWaitingForPayment = false; // MỚI: Chỉ xử lý link nếu đang chờ thanh toán
  int? _currentOrderCode; // Lưu mã đơn hàng hiện tại để tự động kiểm tra

  final _payOSRepository = PayOSRepository();

  // Current viewing month
  int _viewMonth = DateTime.now().month;
  int _viewYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    // Đăng ký theo dõi trạng thái sống của App
    WidgetsBinding.instance.addObserver(this);
    // Khởi tạo lắng nghe Deep Link
    _initDeepLinkListener();
  }

  @override
  void dispose() {
    // Hủy theo dõi trạng thái App
    WidgetsBinding.instance.removeObserver(this);
    // Hủy lắng nghe Deep Link khi thoát màn hình
    _linkSubscription?.cancel();
    _promoController.dispose();
    super.dispose();
  }

  // TỰ ĐỘNG KIỂM TRA KHI QUAY LẠI APP
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _isWaitingForPayment && _currentOrderCode != null) {
      debugPrint('Lifecycle: Quay lại App. Tự động kiểm tra đơn hàng $_currentOrderCode');
      _checkPaymentStatus(_currentOrderCode!);
    }
  }

  void _initDeepLinkListener() {
    _appLinks = AppLinks();
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) async {
      if (!_isWaitingForPayment) return;

      debugPrint('DeepLink: Nhận được link quay lại: $uri');
      if (uri.host == 'payment-success' && _currentOrderCode != null) {
        _checkPaymentStatus(_currentOrderCode!);
      }
    });
  }

  // HÀM XÁC THỰC CHUNG (Dùng cho cả DeepLink và Lifecycle)
  Future<void> _checkPaymentStatus(int orderCode) async {
    // Tránh kiểm tra nếu đang loading
    if (_isLoading) return;

    if (mounted) {
      setState(() => _isLoading = true);
      // Thông báo cho người dùng biết app đang tự động kiểm tra
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đang xác thực giao dịch...'),
          duration: Duration(seconds: 1),
        ),
      );
    }

    final status = await _payOSRepository.verifyPayment(orderCode);
    if (mounted) setState(() => _isLoading = false);

    if (status == 'PAID') {
      setState(() {
        _isWaitingForPayment = false;
        _currentOrderCode = null;
      });
      _handlePaymentReturn();
    } else if (status == 'CANCELLED') {
      setState(() {
        _isWaitingForPayment = false;
        _currentOrderCode = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Bạn đã hủy thanh toán. Vui lòng thử lại.')),
        );
      }
    } else {
      // Trường hợp PENDING hoặc trạng thái khác
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Thanh toán đang chờ xử lý (Trạng thái: $status)'),
            action: SnackBarAction(
              label: 'Thử lại',
              onPressed: () => _checkPaymentStatus(orderCode),
            ),
          ),
        );
      }
      debugPrint('Trạng thái hiện tại: $status. Tiếp tục chờ...');
    }
  }

  void _handlePaymentReturn() {
    // Tự động hiện Dialog thành công khi quay lại từ trình duyệt
    if (!mounted) return;

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

    final orderCode = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    // Lưu lại để dùng khi App được mở lại
    _currentOrderCode = orderCode;

    // Bật trạng thái chờ trước khi mở PayOS
    setState(() {
      _isLoading = true;
      _isWaitingForPayment = true;
    });

    final success = await _payOSRepository.createPayment(
      orderCode: orderCode,
      amount: _total,
      description: 'Thanh toan ${_room?.title ?? _property!.title}',
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;

      // Nếu không mở được PayOS thì hủy trạng thái chờ
      if (!success) {
        _isWaitingForPayment = false;
        _currentOrderCode = null;
      }
    });

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lỗi khởi tạo thanh toán. Vui lòng thử lại.'),
        ),
      );
    }
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
      {
        'name': 'Thanh toán qua PayOS',
        'icon': Icons.account_balance_wallet_outlined,
        'color': const Color(0xFFAD1457),
        'bg': const Color(0xFFFCE4EC)
      },
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Phương thức thanh toán',
            style: AppTextStyles.titleLg
                .copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
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
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.outlineVariant,
                            width: isSelected ? 2 : 1)),
                    child: Row(children: [
                      Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                              color: methods[i]['bg'] as Color,
                              borderRadius: BorderRadius.circular(8)),
                          child: Icon(methods[i]['icon'] as IconData,
                              color: methods[i]['color'] as Color, size: 22)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Text(methods[i]['name'] as String,
                              style: AppTextStyles.bodyLg
                                  .copyWith(fontWeight: FontWeight.w500))),
                      Radio<int>(value: i, activeColor: AppColors.primary),
                    ]),
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
