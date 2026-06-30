import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_dimensions.dart';
import '../widgets/property_card.dart';
import '../widgets/vibe_bottom_nav_bar.dart';
import '../blocs/home/home_bloc.dart';
import '../blocs/home/home_event.dart';
import '../blocs/home/home_state.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_state.dart';
import '../../data/repositories/mock_property_repository.dart';
import 'cubit/wishlist_cubit.dart';

/// Màn hình Trang chủ VibeLocals
/// Route: /home
/// Design:
///   - Fixed glassmorphic TopAppBar (logo + profile + notifications bell)
///   - Pill search bar → mở bản đồ (/explore)
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

  void _onNavTap(int index) {
    if (_currentNavIndex == index) return;
    setState(() => _currentNavIndex = index);
    switch (index) {
      case 0:
        break; // Home
      case 1:
        Navigator.of(context).pushNamed('/wishlist');
        break;
      case 2:
        Navigator.of(context).pushNamed('/explore-intro');
        break;
      case 3:
        Navigator.of(context).pushNamed('/chat');
        break;
      case 4:
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
    return BlocProvider(
      create: (context) => HomeBloc(
        propertyRepository: MockPropertyRepository(),
      )..add(FetchProperties()),
      child: Builder(
        builder: (context) {
          return Scaffold(
        backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Scrollable content
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Top spacer for fixed AppBar
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
              // Search & Filter
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
                  child: _SearchBar(
                    controller: _searchController,
                    onTap: () => Navigator.of(context).pushNamed('/explore-intro'),
                    onSubmitted: (_) => Navigator.of(context).pushNamed('/explore-intro'),
                    onFilterTap: () => Navigator.of(context).pushNamed('/explore-intro'),
                  ),
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
                        onTap: () {
                          if (_selectedCategory == i) return;
                          setState(() => _selectedCategory = i);
                          context.read<HomeBloc>().add(FetchPropertiesByCategory(cat.label));
                        },
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
              // Property list managed by BLoC
              BlocBuilder<HomeBloc, HomeState>(
                builder: (context, state) {
                  if (state is HomeLoading) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.xxl),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    );
                  } else if (state is HomeFailure) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.xxl),
                        child: Center(child: Text('Lỗi: ${state.error}')),
                      ),
                    );
                  } else if (state is HomeLoaded) {
                    final properties = state.properties;
                    return SliverPadding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md),
                      sliver: SliverList.separated(
                        itemCount: properties.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppSpacing.xxl),
                        itemBuilder: (context, i) {
                          final p = properties[i];
                          final formattedPrice = '${p.pricePerNight.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}đ';

                          return BlocBuilder<WishlistCubit, Set<String>>(
                            builder: (context, favoriteIds) => PropertyCard(
                              title: p.title,
                              location: p.location,
                              priceText: formattedPrice,
                              rating: p.rating,
                              imageUrl: p.imageUrls.isNotEmpty ? p.imageUrls.first : '',
                              isFavorite: favoriteIds.contains(p.id),
                              onFavoriteToggle: () =>
                                  context.read<WishlistCubit>().toggleFavorite(p.id),
                              onTap: () =>
                                  Navigator.of(context).pushNamed('/property-detail', arguments: p),
                            ),
                          );
                        },
                      ),
                    );
                  }
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                },
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
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                String? avatarUrl;
                String name = 'Khách';
                if (state is Authenticated) {
                  avatarUrl = state.user.avatarUrl;
                  name = state.user.name;
                }
                return _GlassTopBar(
                  avatarUrl: avatarUrl,
                  userName: name,
                  onNotificationTap: () =>
                      Navigator.of(context).pushNamed('/notifications'),
                );
              },
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
      ),
    );
  }
}

class _GlassTopBar extends StatelessWidget {
  final VoidCallback? onNotificationTap;
  final String? avatarUrl;
  final String userName;

  const _GlassTopBar({
    this.onNotificationTap,
    this.avatarUrl,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
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
                  child: avatarUrl != null && avatarUrl!.isNotEmpty
                      ? Image.network(
                          avatarUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                              Icons.person,
                              color: AppColors.outline),
                        )
                      : const Icon(Icons.person, color: AppColors.outline),
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
                    'Chào $userName!',
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
  final VoidCallback? onFilterTap;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;

  const _SearchBar({
    required this.controller,
    this.onFilterTap,
    this.onSubmitted,
    this.onTap,
  });

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
            child: GestureDetector(
              onTap: onTap,
              child: AbsorbPointer(
                absorbing: onTap != null,
                child: TextField(
                  controller: controller,
                  onSubmitted: onSubmitted,
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
            ),
          ),
          GestureDetector(
            onTap: onFilterTap,
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
