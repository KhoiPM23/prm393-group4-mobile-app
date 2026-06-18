import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_text_styles.dart';
import '../widgets/vibe_cards.dart';
import '../widgets/vibe_ui_components.dart';

/// Màn hình Chi tiết Địa điểm VibeLocals
/// Route: /property-detail
/// Source: chi_ti_t_a_i_m_vibelocals/code.html
/// Design:
///   - Full-height hero image with gradient overlay
///   - Overlay back + favorite buttons
///   - Property info card (rounded-[32px]) overlapping image
///   - Host section with Chat Now button
///   - Room list (RoomCard)
///   - Amenity chips
///   - Fixed footer (price + Đặt ngay CTA)
class PropertyDetailScreen extends StatefulWidget {
  const PropertyDetailScreen({super.key});

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  bool _isFavorite = true;
  late ScrollController _scrollController;
  bool _showNavBg = false;

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
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ===== MAIN SCROLL CONTENT =====
          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ===== FIX: GỘP HERO VÀ CARD VÀO MỘT SLIVER DUY NHẤT =====
              SliverToBoxAdapter(
                child: Stack(
                  clipBehavior: Clip
                      .none, // Cho phép các phần tử con trồi ra ngoài thoải mái
                  children: [
                    // Phần hình nền có khoảng đệm phía dưới để đẩy layout
                    Padding(
                      padding: const EdgeInsets.only(bottom: 40.0),
                      child: _HeroSection(
                        imageUrl:
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuCBkRgELSDZK6S_BspKR_p3xyP69vhJoH2QFvGIMDLE26xbdiQZ_GBbm5dhYSHaUpbKYxo6VZgexri3WnP4crxXBe92ZUYCH8Hkj2vlUlJKkFVgB2zG6VugzynNJpT_4Aq5kU_bKskMLUYLLQCwNAQK1JOBhq2urIdCzeMWgbMcMR23maG4ETUtyygscSyvl-gjigOJ0pUS1_3VVw_Rgmunpo4JSUUDGpsIQRVGl23A9ucg_8hfsL9w7Lt22VesZzareiDvqROQ41s',
                      ),
                    ),
                    // Thẻ thông tin được neo chặt ở đáy Stack, đè lên ảnh chuẩn 100%
                    Positioned(
                      bottom: 0,
                      left: AppSpacing.md,
                      right: AppSpacing.md,
                      child: _PropertyInfoCard(
                        onChatTap: () =>
                            Navigator.of(context).pushNamed('/chat'),
                      ),
                    ),
                  ],
                ),
              ),

              // Room List Section (Giữ nguyên phần phía dưới)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md, AppSpacing.lg, AppSpacing.md, 0),
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
                      _RoomList(),
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
                        children: const [
                          VibeChip(
                              label: 'Hồ bơi vô cực',
                              icon: Icons.pool_outlined),
                          VibeChip(
                              label: 'Nhà hàng Á - Âu',
                              icon: Icons.restaurant_outlined),
                          VibeChip(
                              label: 'Spa & Massage', icon: Icons.spa_outlined),
                          VibeChip(
                              label: 'Cho thuê xe đạp',
                              icon: Icons.directions_bike_outlined),
                          VibeChip(
                              label: 'Xe đưa đón sân bay',
                              icon: Icons.airport_shuttle_outlined),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Bottom spacer for fixed footer
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
                      // Back button
                      _OverlayButton(
                        icon: Icons.arrow_back,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      // Favorite button
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
              onBookTap: () => Navigator.of(context).pushNamed('/booking'),
            ),
          ),
        ],
      ),
    );
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
  final VoidCallback? onChatTap;
  const _PropertyInfoCard({this.onChatTap});

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
          // Name + Rating
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Villa Hội An Heritage',
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
                          'Hội An, Quảng Nam',
                          style: AppTextStyles.bodyMd.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Star rating
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
                      '4.9',
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
          // Host info
          Row(
            children: [
              ClipOval(
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: Image.network(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuC1epfAd2ZM_Jo90tYfC8G_WiOz1X6lqrZkRKUX6EHhfrzjRzqUyetYLCChtSTPNecQEULMFKOFGNQ9vug9RTHfU35P28aBB1TQhQj4bnoajtgVTRugeGsto0pXS5f3b9IKzhyFzfAACzP_7SGSx3VtOZnnJ5DvHIC9Avh8O2o_uXeoE3KtQhXKybhkr8dCNN85itcF9MgS1fkfmSBeGDxYZS4obhDIi_cCvS5A0kvF08yVNEZiw_yhWa-CsKhlAcHLhg_WVB5luWg',
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
                    'Minh Khôi',
                    style: AppTextStyles.titleLg.copyWith(
                      color: AppColors.onSurface,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Chat now button - min 48x touch target
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
  @override
  Widget build(BuildContext context) {
    final rooms = [
      _RoomData(
        name: 'Phòng Suite Deluxe',
        price: '1.800.000đ',
        bed: 'King',
        area: '45m²',
        amenity: 'Free Wifi',
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuBg6tRza7A8KGiNyFdKi4zvT8fDDxv_XsMjnNABCkNKk9a_CjFR_ABvSva8PQ7t2ziuEGBJpCn9Qe786Gzfe-XL0QfBfuJJHoBgd-ii0deyra5BXgFX5rHf2iYR-Co4YjjH-OQtg-nASjzFfZbXrjkAvtUVE-C-TPAk8-dWJ36yia_7w23YxgD8-du7BxBg9s34qRy3I4nHPr2GDEaQLkjMvJzqbjZHqQwJ08On4aPY8ASRO47bxrA3dNxHTFHfD_FT_jSFCKV5thQ',
      ),
      _RoomData(
        name: 'Phòng Double Premium',
        price: '1.500.000đ',
        bed: 'Double',
        area: '35m²',
        amenity: 'AC',
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuAyikkowLJbEUMBfpEPpkOSvX9Gb6cigJnnFf4ageqTa6rbp7w8cf1BlnSj0tM4amzR2xPihtTJ_YMIkOO9cak5l4ElB8dTVshoXvxcbB8anIpdwD9Ey46KA1n7Qv7f67YjdnjydnBpS4mjsecqAsZRSqRXGuT8uzvNU15XNldJT6J1O7U19G2SrEyyI6UEYSwp83o0jWe1sw8lP5rFdeWveaE27fea0Ok5YARzLpDqBET1433i_NWWBhKE8oN-t4seSZUCWhKUhRE',
      ),
      _RoomData(
        name: 'Phòng Single Standard',
        price: '1.200.000đ',
        bed: 'Single',
        area: '25m²',
        amenity: 'Mini Bar',
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuCKryG78Ksz61bbvQfOf-BQu_FlIJAcm8f3jwilrBlGcS77oCeWd5FjEPOXbO-bfBEZIe2i7NQhiFR7t-P1ERwyW0mkII3Tgzqj8E7SEbzg9knroHjGX-Z4G0pzfYsbLQt7muZmphKxfxSQ325Vja7nnV9podcg3N8-KmS5lFWcFS4CoFNB7VUJIjBmZavQBxD_OOJNQU1b9bpZBR2VuiQgX8qEkvYn9Tcv--zEIlcaNttoHzslj3CYnJiSPwIXp1P5iz67N2ALZVs',
      ),
    ];
    return Column(
      children: rooms
          .map((r) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: RoomCard(
                  name: r.name,
                  priceText: r.price,
                  imageUrl: r.imageUrl,
                  bedType: r.bed,
                  area: r.area,
                  amenity: r.amenity,
                ),
              ))
          .toList(),
    );
  }
}

class _BookingFooter extends StatelessWidget {
  final VoidCallback? onBookTap;
  const _BookingFooter({this.onBookTap});

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
                          text: '1.500.000đ',
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

class _RoomData {
  final String name, price, bed, area, amenity, imageUrl;
  const _RoomData({
    required this.name,
    required this.price,
    required this.bed,
    required this.area,
    required this.amenity,
    required this.imageUrl,
  });
}
