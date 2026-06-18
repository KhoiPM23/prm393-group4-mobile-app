import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_text_styles.dart';
import '../widgets/vibe_bottom_nav_bar.dart';

/// Màn hình Bản đồ Khám phá VibeLocals
/// Route: /explore
/// Source: b_n_kh_m_ph_vibelocals/code.html
/// Design:
///   - Fullscreen map background (simulated với placeholder container)
///   - Floating glassmorphic search bar (top)
///   - Price marker bubbles on map (active = primary, inactive = white)
///   - Floating bottom property preview card
///   - Bottom nav bar
class ExploreMapScreen extends StatefulWidget {
  const ExploreMapScreen({super.key});

  @override
  State<ExploreMapScreen> createState() => _ExploreMapScreenState();
}

class _ExploreMapScreenState extends State<ExploreMapScreen>
    with TickerProviderStateMixin {
  int _activeMarker = 0;
  int _currentNavIndex = 1;
  late AnimationController _cardSlideController;
  late Animation<Offset> _cardSlideAnimation;

  final List<_MarkerData> _markers = const [
    _MarkerData(price: '1.5M', top: 0.55, left: 0.45),
    _MarkerData(price: '1.8M', top: 0.35, left: 0.65),
    _MarkerData(price: '1.2M', top: 0.42, left: 0.25),
    _MarkerData(price: '2.1M', top: 0.68, left: 0.72),
  ];

  @override
  void initState() {
    super.initState();
    _cardSlideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
    _cardSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _cardSlideController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _cardSlideController.dispose();
    super.dispose();
  }

  void _onMarkerTap(int index) {
    setState(() => _activeMarker = index);
    // Animate card
    _cardSlideController.reset();
    _cardSlideController.forward();
  }

  void _onNavTap(int index) {
    setState(() => _currentNavIndex = index);
    if (index == 0) Navigator.of(context).pushReplacementNamed('/home');
    if (index == 2) Navigator.of(context).pushReplacementNamed('/profile');
    if (index == 3) Navigator.of(context).pushReplacementNamed('/profile');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ===== FULLSCREEN MAP PLACEHOLDER =====
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFE5E3DF),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.network(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuC8AngP5xRzXNExEtaqKr9q-V22itFxEU1uaIbhIN8ZuQsMQUQ8dVzyVjSU5DkXzt31ZvcqugLMIfVOVMGqAsjOFUowXNf3x8hOfLDAjigcmEsnonZGpAYMTrGRKc-R-TYiGUfG_If4lqYbIcOs08A3RZ5C6xadz5Pnx0d3SsjiCGnl6ZgDel-Pging1FjxLsq2i_sKLqQYTfjA-BTmqQtsWElC4-SKf3U_lRUZDfaLg5el7O_x8TdDOk14XPoOKrMM6EXubD74_tM',
                      fit: BoxFit.cover,
                      color: Colors.black.withValues(alpha: 0.05),
                      colorBlendMode: BlendMode.darken,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFFD9D9D5),
                        child: GridPaper(
                          color: Colors.grey.withValues(alpha: 0.2),
                          divisions: 1,
                          subdivisions: 5,
                          child: const SizedBox.expand(),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            AppColors.surface.withValues(alpha: 0.4),
                          ],
                        ),
                      ),
                    ),
                  ),
                  ..._markers.asMap().entries.map((entry) {
                    final i = entry.key;
                    final m = entry.value;
                    final isActive = _activeMarker == i;
                    return Positioned(
                      top: m.top * size.height,
                      left: m.left * size.width,
                      child: GestureDetector(
                        onTap: () => _onMarkerTap(i),
                        child: _PriceMarker(
                          price: m.price,
                          isActive: isActive,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // ===== FIX: BỌC POSITIONED CHO TOP SEARCH BAR =====
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: _FloatingSearchBar(
                  onBackTap: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ),

          // ===== BOTTOM PREVIEW CARD =====
          Positioned(
            bottom: 100,
            left: AppSpacing.md,
            right: AppSpacing.md,
            child: SlideTransition(
              position: _cardSlideAnimation,
              child: _PropertyPreviewCard(
                title: 'Villa Hội An Heritage',
                sublocation: 'Thanh Hà, Hội An • 2.5km',
                price: '1.500.000đ',
                rating: 4.9,
                imageUrl:
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuCeas4xUA1wD69EdZRiGqXpKWY7roQxwxdXo_j2ghla7oArNU_o5W9IzUynEzBcaydsCztOfQzzlovSq-qfxOu2BPDJOfm3kmC0Dg8ZXHbmCmOEUectfZqZ7-op802gBvwRgluB8eeE38HFmXaLxDUYRwUrVoxmeeCKiCHgexe1BdmAJoFLIy8J9Q9NPLu4bMJnN4e1Czm0wiXPRo_5k6VpK4LvxBR5ez9mmwdVA2NMLwQWJIBxn7_Qg0Hwm5fd7J2Bh-fmGTnIn6k',
                onViewDetail: () =>
                    Navigator.of(context).pushNamed('/property-detail'),
              ),
            ),
          ),

          // ===== BOTTOM NAV =====
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: VibeBottomNavBar(
              currentIndex: _currentNavIndex,
              onTap: _onNavTap,
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceMarker extends StatelessWidget {
  final String price;
  final bool isActive;

  const _PriceMarker({required this.price, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.full),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isActive ? 0.25 : 0.12),
            blurRadius: isActive ? 12 : 6,
            offset: const Offset(0, 3),
          ),
        ],
        border: isActive
            ? null
            : Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Text(
        price,
        style: AppTextStyles.labelLg.copyWith(
          color: isActive ? AppColors.onPrimary : AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _FloatingSearchBar extends StatelessWidget {
  final VoidCallback? onBackTap;

  const _FloatingSearchBar({this.onBackTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(AppRadius.full),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBackTap,
            icon:
                const Icon(Icons.arrow_back, color: AppColors.onSurfaceVariant),
            iconSize: 22,
            style: IconButton.styleFrom(
              minimumSize:
                  const Size(AppTouchTarget.minSize, AppTouchTarget.minSize),
            ),
          ),
          Expanded(
            child: Text(
              'Tìm homestay quanh đây...',
              style: AppTextStyles.labelLg.copyWith(
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
              ),
            ),
          ),
          Container(
            width: 1,
            height: 24,
            color: AppColors.outlineVariant,
            margin: const EdgeInsets.symmetric(horizontal: 4),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.format_list_bulleted,
                color: AppColors.primary),
            iconSize: 22,
            style: IconButton.styleFrom(
              minimumSize:
                  const Size(AppTouchTarget.minSize, AppTouchTarget.minSize),
            ),
          ),
        ],
      ),
    );
  }
}

class _PropertyPreviewCard extends StatelessWidget {
  final String title, sublocation, price, imageUrl;
  final double rating;
  final VoidCallback? onViewDetail;

  const _PropertyPreviewCard({
    required this.title,
    required this.sublocation,
    required this.price,
    required this.rating,
    required this.imageUrl,
    this.onViewDetail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border:
            Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            child: SizedBox(
              width: 96,
              height: 96,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.surfaceContainerHigh,
                  child: const Icon(Icons.villa_outlined,
                      color: AppColors.outline),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppTextStyles.titleLg.copyWith(
                          color: AppColors.onSurface,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryContainer,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star,
                              size: 12, color: AppColors.onSecondaryContainer),
                          const SizedBox(width: 2),
                          Text(
                            rating.toString(),
                            style: AppTextStyles.labelMd.copyWith(
                              color: AppColors.onSecondaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  sublocation,
                  style: AppTextStyles.labelMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Từ',
                          style: AppTextStyles.labelMd.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: price,
                                style: AppTextStyles.titleLg.copyWith(
                                  color: AppColors.primary,
                                  fontSize: 16,
                                ),
                              ),
                              TextSpan(
                                text: '/đêm',
                                style: AppTextStyles.labelMd.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: onViewDetail,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                        ),
                        minimumSize: const Size(96, 40),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        elevation: 2,
                      ),
                      child: Text(
                        'Xem chi tiết',
                        style: AppTextStyles.labelLg.copyWith(
                          color: AppColors.onPrimary,
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

class _MarkerData {
  final String price;
  final double top, left;
  const _MarkerData(
      {required this.price, required this.top, required this.left});
}
