import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_text_styles.dart';
import '../../domain/entities/property_entity.dart';
import '../../data/models/property_model.dart';
import '../widgets/vibe_cards.dart';
import '../widgets/vibe_ui_components.dart';

import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_state.dart';
import '../../data/repositories/firebase_message_repository.dart';

/// Màn hình Chi tiết Địa điểm VibeLocals
/// Route: /property-detail
class PropertyDetailScreen extends StatefulWidget {
  const PropertyDetailScreen({super.key});

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  bool _isFavorite = true;
  late ScrollController _scrollController;
  bool _showNavBg = false;
  PropertyEntity? _property;
  int _selectedRoomIndex = 0; // Theo dõi phòng đang chọn

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      final showBg = _scrollController.offset > 280;
      if (showBg != _showNavBg) {
        setState(() => _showNavBg = showBg);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Lấy dữ liệu từ Arguments truyền vào
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is PropertyEntity) {
      _property = args;
    } else {
      // Fallback: Tự lấy dữ liệu mẫu đầu tiên để test nếu chưa có truyền từ Home
      _property = PropertyModel.mockList().first;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _handleChat(BuildContext context, PropertyEntity p) async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập để chat với chủ nhà.')),
      );
      Navigator.of(context).pushNamed('/login');
      return;
    }

    final currentUser = authState.user;
    if (currentUser.id == p.hostId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn không thể chat với chính mình.')),
      );
      return;
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final messageRepo = FirebaseMessageRepository();
      final roomId = await messageRepo.getOrCreateChatRoom(
        currentUser.id,
        p.hostId,
        user1Name: currentUser.name,
        user2Name: p.hostName,
        user1Avatar: currentUser.avatarUrl,
        user2Avatar: p.hostAvatar,
        extraMetadata: {
          'propertyTitle': p.title,
          'propertyImage': p.imageUrls.isNotEmpty ? p.imageUrls.first : '',
        },
      );

      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading
        Navigator.of(context).pushNamed('/chat', arguments: {
          'roomId': roomId,
          'otherUserId': p.hostId,
          'otherUserName': p.hostName,
          'otherUserAvatar': p.hostAvatar,
        });
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_property == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final p = _property!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ===== MAIN SCROLL CONTENT =====
          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 40.0),
                      child: _HeroSection(
                        imageUrl: p.imageUrls.isNotEmpty ? p.imageUrls.first : '',
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: AppSpacing.md,
                      right: AppSpacing.md,
                      child: _PropertyInfoCard(
                        property: p,
                        onChatTap: () => _handleChat(context, p),
                      ),
                    ),
                  ],
                ),
              ),

              // Property Description
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md, AppSpacing.lg, AppSpacing.md, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Giới thiệu',
                        style: AppTextStyles.headlineLgMobile.copyWith(
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        p.description,
                        style: AppTextStyles.bodyMd.copyWith(
                          color: AppColors.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Room List Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md, AppSpacing.xxl, AppSpacing.md, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 4, bottom: AppSpacing.md),
                        child: Text(
                          'Danh sách phòng',
                          style: AppTextStyles.headlineLgMobile.copyWith(
                            color: AppColors.onSurface,
                          ),
                        ),
                      ),
                      _RoomList(
                        rooms: p.rooms,
                        selectedIndex: _selectedRoomIndex,
                        onRoomSelected: (index) =>
                            setState(() => _selectedRoomIndex = index),
                      ),
                    ],
                  ),
                ),
              ),
              // Amenities section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md, AppSpacing.xxl, AppSpacing.md, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 4, bottom: AppSpacing.md),
                        child: Text(
                          'Tiện ích nổi bật',
                          style: AppTextStyles.headlineLgMobile.copyWith(
                            color: AppColors.onSurface,
                          ),
                        ),
                      ),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: p.amenities.map((a) => VibeChip(
                          label: a,
                          icon: _getAmenityIcon(a),
                        )).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),

          // ===== OVERLAY TOP NAV =====
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              color: _showNavBg
                  ? AppColors.surface.withValues(alpha: 0.85)
                  : Colors.transparent,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _OverlayButton(
                        icon: Icons.arrow_back,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      _OverlayButton(
                        icon: _isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        iconColor:
                            _isFavorite ? AppColors.error : AppColors.onSurface,
                        onTap: () => setState(() => _isFavorite = !_isFavorite),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ===== FIXED BOTTOM ACTION BAR =====
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _BookingFooter(
              price: p.rooms.isNotEmpty 
                ? p.rooms[_selectedRoomIndex].pricePerNight 
                : p.pricePerNight,
              onBookTap: () {
                final selectedRoom = p.rooms.isNotEmpty ? p.rooms[_selectedRoomIndex] : null;
                Navigator.of(context).pushNamed(
                  '/booking', 
                  arguments: {
                    'property': p,
                    'room': selectedRoom,
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _getAmenityIcon(String name) {
    switch (name.toLowerCase()) {
      case 'wifi': return Icons.wifi;
      case 'hồ bơi': return Icons.pool;
      case 'máy lạnh': return Icons.ac_unit;
      case 'bếp': return Icons.kitchen;
      case 'ăn sáng': return Icons.restaurant;
      default: return Icons.check_circle_outline;
    }
  }
}

class _HeroSection extends StatelessWidget {
  final String imageUrl;
  const _HeroSection({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 360,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: AppColors.surfaceContainerHigh,
              child: const Icon(Icons.villa_rounded,
                  size: 80, color: AppColors.outline),
            ),
          ),
          // Hero gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.2, 0.8, 1.0],
                colors: [
                  Color(0x4D000000),
                  Colors.transparent,
                  Colors.transparent,
                  Color(0xFFF8F9FA),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OverlayButton extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final VoidCallback? onTap;

  const _OverlayButton({required this.icon, this.iconColor, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: AppTouchTarget.minSize,
        height: AppTouchTarget.minSize,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.85),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: iconColor ?? AppColors.onSurface,
          size: 22,
        ),
      ),
    );
  }
}

class _PropertyInfoCard extends StatelessWidget {
  final PropertyEntity property;
  final VoidCallback? onChatTap;
  const _PropertyInfoCard({required this.property, this.onChatTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(32),
        border:
            Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      property.title,
                      style: AppTextStyles.headlineLgMobile.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 16, color: AppColors.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(
                          property.location,
                          style: AppTextStyles.bodyMd.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.secondaryFixed,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary.withValues(alpha: 0.2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star,
                        size: 16, color: AppColors.onSecondaryFixed),
                    const SizedBox(width: 4),
                    Text(
                      property.rating.toString(),
                      style: AppTextStyles.labelLg.copyWith(
                        color: AppColors.onSecondaryFixed,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(
              height: 32, color: AppColors.outlineVariant, thickness: 0.5),
          Row(
            children: [
              ClipOval(
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: Image.network(
                    property.hostAvatar,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const CircleAvatar(
                      backgroundColor: AppColors.surfaceContainerHigh,
                      child: Icon(Icons.person, color: AppColors.outline),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chủ nhà',
                    style: AppTextStyles.labelMd.copyWith(
                      color: AppColors.outline,
                    ),
                  ),
                  Text(
                    property.hostName,
                    style: AppTextStyles.titleLg.copyWith(
                      color: AppColors.onSurface,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: onChatTap,
                icon: const Icon(Icons.chat_outlined, size: 18),
                label: const Text('Chat Now'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.outlineVariant),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  minimumSize: const Size(96, AppTouchTarget.minSize),
                  textStyle: AppTextStyles.labelLg,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoomList extends StatelessWidget {
  final List<dynamic> rooms; // RoomEntity
  final int selectedIndex;
  final Function(int) onRoomSelected;

  const _RoomList({
    required this.rooms,
    required this.selectedIndex,
    required this.onRoomSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (rooms.isEmpty) {
      return const Center(child: Text('Khách sạn hiện chưa có thông tin phòng.'));
    }

    return Column(
      children: List.generate(rooms.length, (i) {
        final r = rooms[i];
        final isSelected = selectedIndex == i;
        // Format VND
        final formattedPrice = '${r.pricePerNight.toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (m) => "${m[1]}.")}đ';

        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Container(
            decoration: isSelected ? BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(color: AppColors.primary, width: 2),
            ) : null,
            child: RoomCard(
              name: r.title,
              priceText: formattedPrice,
              imageUrl: r.imageUrls.isNotEmpty ? r.imageUrls.first : '',
              bedType: r.type,
              area: '35m²', // Giả định diện tích nếu Entity chưa có
              amenity: r.amenities.isNotEmpty ? r.amenities.first : 'Wifi',
              onTap: () => onRoomSelected(i),
            ),
          ),
        );
      }),
    );
  }
}

class _BookingFooter extends StatelessWidget {
  final double price;
  final VoidCallback? onBookTap;
  const _BookingFooter({required this.price, this.onBookTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.9),
        border: Border(
          top: BorderSide(
              color: AppColors.outlineVariant.withValues(alpha: 0.2)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Giá phòng từ',
                    style: AppTextStyles.labelMd
                        .copyWith(color: AppColors.outline),
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${price.toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (m) => "${m[1]}.")}đ',
                          style: AppTextStyles.headlineLgMobile
                              .copyWith(color: AppColors.primary),
                        ),
                        TextSpan(
                          text: '/đêm',
                          style: AppTextStyles.bodyMd.copyWith(
                            color: AppColors.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: ElevatedButton(
                  onPressed: onBookTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                    ),
                    elevation: 4,
                  ),
                  child: Text(
                    'Đặt ngay',
                    style: AppTextStyles.labelLg.copyWith(
                      color: AppColors.onPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
