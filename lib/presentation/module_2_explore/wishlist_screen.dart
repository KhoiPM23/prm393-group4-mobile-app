import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_text_styles.dart';
import '../../domain/entities/property_entity.dart';
import '../../domain/entities/wishlist_album_entity.dart';
import '../../domain/repositories/wishlist_repository.dart';
import '../widgets/property_card.dart';
import '../widgets/vibe_bottom_nav_bar.dart';
import 'cubit/wishlist_cubit.dart';

/// Màn hình Yêu thích — hiển thị các album và danh sách chỗ nghỉ đã lưu.
/// Route: /wishlist
class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  int _currentNavIndex = 1;

  void _onNavTap(int index) {
    setState(() => _currentNavIndex = index);
    switch (index) {
      case 0:
        Navigator.of(context).pushReplacementNamed('/home');
        break;
      case 1:
        break; // Already here
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  child: Text(
                    'Yêu thích',
                    style: AppTextStyles.headlineLgMobile.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
              _AlbumListSliver(
                onAlbumTap: (album) {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => _AlbumDetailScreen(album: album),
                  ));
                },
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
          // Top bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
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
                      Text(
                        'VibeLocals',
                        style: AppTextStyles.headlineLgMobile.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Bottom nav
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

// ─── Album list sliver ────────────────────────────────────────

class _AlbumListSliver extends StatefulWidget {
  final ValueChanged<WishlistAlbumEntity> onAlbumTap;
  const _AlbumListSliver({required this.onAlbumTap});

  @override
  State<_AlbumListSliver> createState() => _AlbumListSliverState();
}

class _AlbumListSliverState extends State<_AlbumListSliver> {
  List<WishlistAlbumEntity>? _albums;
  // albumId → URL ảnh preview của property được lưu gần nhất
  final Map<int, String?> _previewImages = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAlbums();
  }

  Future<void> _loadAlbums() async {
    final repo = context.read<WishlistRepository>();
    final albums = await repo.getAlbums();

    // Lấy ảnh preview cho từng album (property được lưu gần nhất)
    final Map<int, String?> previews = {};
    for (final album in albums) {
      final properties = await repo.getPropertiesInAlbum(album.id);
      previews[album.id] = properties.isNotEmpty && properties.first.imageUrls.isNotEmpty
          ? properties.first.imageUrls.first
          : null;
    }

    if (mounted) {
      setState(() {
        _albums = albums;
        _previewImages.addAll(previews);
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xxl),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    final albums = _albums ?? [];
    if (albums.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Center(
            child: Text(
              'Chưa có album yêu thích nào.',
              style: AppTextStyles.bodyLg
                  .copyWith(color: AppColors.onSurfaceVariant),
            ),
          ),
        ),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      sliver: SliverList.separated(
        itemCount: albums.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, i) {
          final album = albums[i];
          return _AlbumTile(
            album: album,
            previewImageUrl: _previewImages[album.id],
            onTap: () => widget.onAlbumTap(album),
          );
        },
      ),
    );
  }
}

// ─── Album tile ───────────────────────────────────────────────

class _AlbumTile extends StatelessWidget {
  final WishlistAlbumEntity album;
  final String? previewImageUrl;
  final VoidCallback onTap;

  const _AlbumTile({
    required this.album,
    required this.onTap,
    this.previewImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Preview image hoặc icon mặc định
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: SizedBox(
                width: 72,
                height: 72,
                child: previewImageUrl != null
                    ? Image.network(
                        previewImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _PlaceholderIcon(album: album),
                      )
                    : _PlaceholderIcon(album: album),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    album.isDefault ? 'Đã lưu' : album.name,
                    style: AppTextStyles.titleLg.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    previewImageUrl != null
                        ? 'Chạm để xem danh sách'
                        : 'Chưa có chỗ nghỉ nào',
                    style: AppTextStyles.labelMd.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                color: AppColors.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderIcon extends StatelessWidget {
  final WishlistAlbumEntity album;
  const _PlaceholderIcon({required this.album});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.secondaryContainer,
      child: Icon(
        album.isDefault
            ? Icons.favorite
            : Icons.collections_bookmark_outlined,
        color: AppColors.onSecondaryContainer,
        size: 32,
      ),
    );
  }
}

// ─── Album detail screen ──────────────────────────────────────

class _AlbumDetailScreen extends StatefulWidget {
  final WishlistAlbumEntity album;
  const _AlbumDetailScreen({required this.album});

  @override
  State<_AlbumDetailScreen> createState() => _AlbumDetailScreenState();
}

class _AlbumDetailScreenState extends State<_AlbumDetailScreen> {
  List<PropertyEntity>? _properties;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProperties();
  }

  Future<void> _loadProperties() async {
    final repo = context.read<WishlistRepository>();
    final props = await repo.getPropertiesInAlbum(widget.album.id);
    if (mounted) setState(() { _properties = props; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final albumName = widget.album.isDefault ? 'Đã lưu' : widget.album.name;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.onSurface),
        title: Text(albumName,
            style:
                AppTextStyles.titleLg.copyWith(color: AppColors.primary)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _buildList(context),
    );
  }

  Widget _buildList(BuildContext context) {
    final properties = _properties ?? [];
    if (properties.isEmpty) {
      return Center(
        child: Text(
          'Album này chưa có chỗ nghỉ nào.',
          style: AppTextStyles.bodyLg
              .copyWith(color: AppColors.onSurfaceVariant),
        ),
      );
    }
    return BlocBuilder<WishlistCubit, Set<String>>(
      builder: (context, favoriteIds) {
        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: properties.length,
          separatorBuilder: (_, __) =>
              const SizedBox(height: AppSpacing.lg),
          itemBuilder: (context, i) {
            final p = properties[i];
            final formattedPrice =
                '${p.pricePerNight.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}đ';
            return PropertyCard(
              title: p.title,
              location: p.location,
              priceText: formattedPrice,
              rating: p.rating,
              imageUrl:
                  p.imageUrls.isNotEmpty ? p.imageUrls.first : '',
              isFavorite: favoriteIds.contains(p.id),
              onFavoriteToggle: () => context
                  .read<WishlistCubit>()
                  .toggleFavorite(p.id),
              onTap: () => Navigator.of(context)
                  .pushNamed('/property-detail', arguments: p),
            );
          },
        );
      },
    );
  }
}
