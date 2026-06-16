import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_dimensions.dart';
import '../widgets/property_card.dart';
import '../widgets/vibe_bottom_nav_bar.dart';

/// Màn hình Trang chủ VibeLocals
/// Route: /home
/// Source: trang_ch_vibelocals/code.html
/// Design:
///   - Fixed glassmorphic TopAppBar (logo + profile + notifications bell)
///   - Pill search bar + filter button
///   - Horizontal category scroll (Xu hướng, Gần biển, Vùng núi, Độc đáo, Di sản)
///   - Vertical property list (PropertyCard)
///   - Glassmorphic BottomNavBar
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedCategory = 0;
  int _currentNavIndex = 0;
  final _searchController = TextEditingController();

  final List<_Category> _categories = const [
    _Category(icon: Icons.trending_up, label: 'Xu hướng'),
    _Category(icon: Icons.waves_outlined, label: 'Gần biển'),
    _Category(icon: Icons.landscape_outlined, label: 'Vùng núi'),
    _Category(icon: Icons.auto_awesome_outlined, label: 'Độc đáo'),
    _Category(icon: Icons.castle_outlined, label: 'Di sản'),
  ];

  final List<_PropertyItem> _properties = const [
    _PropertyItem(
      title: 'Villa Hội An Heritage',
      location: 'Hội An, Quảng Nam',
      price: '1.500.000đ',
      rating: 4.9,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuATw12wuJSe6lpasx57qMl4WNFVhbK-810mYPf-jqxIoiEuIE_QZh3DWA5eSl6WtusGvi5p_jfwlkczC_pTKPUNEhfjd7ZQdHpdRkFNMQDxUiIEca0HWCLr4dt6T8l1UibN03v19cX7jK_E-GgM-bdRpMTFrar6uwpylIIZuEIf3KKWHlYPTHpImyyehuVIm8Dw1WHPHh0qRcdsdR_49iecMYLwfzRP4zPU8MiLG_gQ3x0RkGiTPaak6GQrqySWq4U44bmcPt8RZlA',
    ),
    _PropertyItem(
      title: 'Azure Coast Retreat',
      location: 'Phú Quốc, Kiên Giang',
      price: '3.200.000đ',
      rating: 4.8,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAsd-kqNeLv2LKAmQT6OvpBvKnpFS7F8fQPnUNCQjKsgQCNIMv0EJfhEEcQ_gWD0qMuZknn5p-trTvzrKOOBSO64NmkI9dnzmGe6SXQ885tJVIZXMffpSmEl-Zmq6wrL5R8hHnztk-HEI0jVVPuv0KQwmG17tWiOnCeZcJ8FQyq7tnC8RcIXY-RlJ746eI86tYlxH39FAkv3RIxBwB2paBm0c2A8quLEaR7cMSa2utDvZYJYygRuDuuNwtwpKCZXVBwZ9WHlPIWMRw',
    ),
    _PropertyItem(
      title: 'Pine Mist Cabin',
      location: 'Đà Lạt, Lâm Đồng',
      price: '1.850.000đ',
      rating: 5.0,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBndx1QwU495BTF-dnU2X9aJOk_kjP-9RwnTFPfndZ1dEfeeCBUzfE9Sdkw65YluLUq7pCVID-yuW2GhidBNBrrBitx5zkooe8anb5W-QEYh8nWtT762KqMZbi5XiEKS5js2BOaBRNBGaKVFbRHFzVx9eRYBXrHfDMAMgNdfONXdncx28A69Ui-KbtY4FdCH6ZHg5mOgzkVQu6bBqbZZ5E0o42bI_yDOBBSltMMsl1kWp4ou4FE3psEAhbcTN8W4NAjT3_aLOQU0lc',
    ),
  ];

  void _onNavTap(int index) {
    setState(() => _currentNavIndex = index);
    switch (index) {
      case 0:
        break; // Already home
      case 1:
        Navigator.of(context).pushNamed('/explore');
        break;
      case 2:
        Navigator.of(context).pushNamed('/profile');
        break;
      case 3:
        Navigator.of(context).pushNamed('/profile');
        break;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Scrollable content
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Top spacer for fixed AppBar
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
              // Search & Filter
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
                  child: _SearchBar(controller: _searchController),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
              // Categories
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 64,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md),
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(width: AppSpacing.xl),
                    itemBuilder: (context, i) {
                      final cat = _categories[i];
                      final isActive = _selectedCategory == i;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedCategory = i),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              cat.icon,
                              color: isActive
                                  ? AppColors.primary
                                  : AppColors.onSurfaceVariant,
                              size: 24,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              cat.label,
                              style: AppTextStyles.labelMd.copyWith(
                                color: isActive
                                    ? AppColors.primary
                                    : AppColors.onSurfaceVariant,
                                fontWeight: isActive
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                            if (isActive)
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                width: 4,
                                height: 4,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
              // Property list
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md),
                sliver: SliverList.separated(
                  itemCount: _properties.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.xxl),
                  itemBuilder: (context, i) {
                    final p = _properties[i];
                    return PropertyCard(
                      title: p.title,
                      location: p.location,
                      priceText: p.price,
                      rating: p.rating,
                      imageUrl: p.imageUrl,
                      onTap: () =>
                          Navigator.of(context).pushNamed('/property-detail'),
                    );
                  },
                ),
              ),
              // Bottom spacer for nav bar
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
          // Glassmorphic Top AppBar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _GlassTopBar(
              onNotificationTap: () =>
                  Navigator.of(context).pushNamed('/notifications'),
            ),
          ),
          // Bottom Nav
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

class _GlassTopBar extends StatelessWidget {
  final VoidCallback? onNotificationTap;

  const _GlassTopBar({this.onNotificationTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.85),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.outlineVariant),
                  color: AppColors.surfaceContainerHigh,
                ),
                child: ClipOval(
                  child: Image.network(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuAyXQVi4kCgu64-9fLx1TbULWLiGDvdv6KK0OLOyLqt4eEq1NyxryQnhF1D8PS4g6pYod5TOO-fj7ANWmmluIv4ADw7WVityaX1KuM289PANHYFFCz55mz9nSmHJtLqcNKCOcvUD-y0afjrJVHy-ev4qzBsKAf0THV1s7VPMkloTJGwiGN6TLcrummkQfOruTdP8lu7xtBPh57Bomhz2u-B3PYtbIDb3MyddDrDZXinW8XURCuHbPY0cvoqpcuIMWuKUuiBUusa2BI',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.person, color: AppColors.outline),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'VibeLocals',
                    style: AppTextStyles.headlineLgMobile.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    'Chào buổi sáng!',
                    style: AppTextStyles.labelMd.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Notifications
              IconButton(
                onPressed: onNotificationTap,
                icon: const Icon(Icons.notifications_outlined,
                    color: AppColors.primary),
                iconSize: 24,
                style: IconButton.styleFrom(
                  minimumSize:
                      const Size(AppTouchTarget.minSize, AppTouchTarget.minSize),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;

  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 16),
            child: Icon(Icons.search, color: AppColors.onSurfaceVariant),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              style: AppTextStyles.bodyMd
                  .copyWith(color: AppColors.onSurface),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm điểm đến...',
                hintStyle: AppTextStyles.bodyMd
                    .copyWith(color: AppColors.outline),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 44,
              height: 44,
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppRadius.xl - 4),
              ),
              child: const Icon(Icons.tune, color: AppColors.onPrimary,
                  size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _Category {
  final IconData icon;
  final String label;
  const _Category({required this.icon, required this.label});
}

class _PropertyItem {
  final String title, location, price, imageUrl;
  final double rating;
  const _PropertyItem({
    required this.title,
    required this.location,
    required this.price,
    required this.rating,
    required this.imageUrl,
  });
}
