import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_text_styles.dart';
import '../../domain/entities/property_entity.dart';
import '../widgets/vibe_bottom_nav_bar.dart';
import 'bloc/map_bloc.dart';
import 'bloc/map_event.dart';
import 'bloc/map_state.dart';

/// Màn hình Bản đồ Khám phá VibeLocals thực tế tích hợp BLoC Engine & Tấm nền trượt
class ExploreMapScreen extends StatefulWidget {
  const ExploreMapScreen({super.key});

  @override
  State<ExploreMapScreen> createState() => _ExploreMapScreenState();
}

class _ExploreMapScreenState extends State<ExploreMapScreen>
    with TickerProviderStateMixin {
  int _currentNavIndex = 1;
  late AnimationController _cardSlideController;
  late Animation<Offset> _cardSlideAnimation;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _cardSlideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _cardSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _cardSlideController, curve: Curves.easeOutCubic),
    );

    context.read<MapBloc>().add(MapInitialized());
  }

  @override
  void dispose() {
    _cardSlideController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  /// Thuật toán dịch chuyển góc nhìn camera mượt mà (Smooth Map Translation)
  void _animatedMapMove(LatLng destLocation, double destZoom) {
    final camera = _mapController.camera;
    final latTween = Tween<double>(
        begin: camera.center.latitude, end: destLocation.latitude);
    final lngTween = Tween<double>(
        begin: camera.center.longitude, end: destLocation.longitude);
    final zoomTween = Tween<double>(begin: camera.zoom, end: destZoom);

    final animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    final animation = CurvedAnimation(
        parent: animationController, curve: Curves.fastOutSlowIn);

    animationController.addListener(() {
      _mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
      );
    });

    animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        animationController.dispose();
      }
    });

    animationController.forward();
  }

  void _onMarkerTap(PropertyEntity property) {
    context.read<MapBloc>().add(MapMarkerSelected(property.id));
    // Dịch chuyển ghim được chọn vào tâm bản đồ phóng phóng cận cảnh (Zoom 15.5)
    _animatedMapMove(LatLng(property.latitude, property.longitude), 15.5);
    _cardSlideController.reset();
    _cardSlideController.forward();
  }

  void _onNavTap(int index) {
    setState(() => _currentNavIndex = index);
    if (index == 0) Navigator.of(context).pushReplacementNamed('/home');
    if (index == 2 || index == 3)
      Navigator.of(context).pushReplacementNamed('/profile');
  }

  void _updateViewportBounds() {
    final bounds = _mapController.camera.visibleBounds;
    context.read<MapBloc>().add(
          MapViewportChanged(
            minLat: bounds.southWest.latitude,
            maxLat: bounds.northEast.latitude,
            minLng: bounds.southWest.longitude,
            maxLng: bounds.northEast.longitude,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocListener<MapBloc, MapState>(
        listenWhen: (previous, current) =>
            previous.selectedProperty != current.selectedProperty,
        listener: (context, state) {
          if (state.selectedProperty != null) {
            _cardSlideController.forward();
          } else {
            _cardSlideController.reverse();
          }
        },
        child: BlocBuilder<MapBloc, MapState>(
          builder: (context, state) {
            return Stack(
              children: [
                // ===== 1. LAYER CORE MAP ENGINE =====
                Positioned.fill(
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: const LatLng(16.055, 108.235),
                      initialZoom: 13.5,
                      minZoom: 11,
                      maxZoom: 18,
                      onMapReady: _updateViewportBounds,
                      onPositionChanged: (position, hasGesture) {
                        if (hasGesture) _updateViewportBounds();
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.vibelocals.app',
                      ),
                      MarkerLayer(
                        markers: state.visibleProperties.map((property) {
                          final isActive =
                              state.selectedProperty?.id == property.id;
                          final shortPrice =
                              '${(property.pricePerNight / 1000000).toStringAsFixed(1)}M';

                          return Marker(
                            point:
                                LatLng(property.latitude, property.longitude),
                            width: 70,
                            height: 40,
                            alignment: Alignment.center,
                            child: GestureDetector(
                              onTap: () => _onMarkerTap(property),
                              child: _PriceMarker(
                                price: shortPrice,
                                isActive: isActive,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                // ===== 2. FLOATING TOP SEARCH BAR =====
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

                // ===== 3. FLOATING ACTIVE PREVIEW CARD (Hiển thị ngay trên vạch sheet) =====

                // ===== 4. CỬA SỔ KẾT QUẢ ĐỘNG CÔ LẬP (GOOGLE MAPS STYLE) =====
                Positioned.fill(
                  child: DraggableScrollableSheet(
                    initialChildSize:
                        0.22, // Đẩy cao vạch sheet lên 0.22 để vượt qua Bottom Nav Bar
                    minChildSize: 0.22,
                    maxChildSize: 0.75,
                    snap: true,
                    snapSizes: const [0.22, 0.75],
                    builder: (context, scrollController) {
                      final isSelected = state.selectedProperty != null;

                      return Container(
                        // Chống xuyên thấu: Đệm bottom padding đúng bằng chiều cao của VibeBottomNavBar
                        padding: const EdgeInsets.only(bottom: 75),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(AppRadius.card),
                            topRight: Radius.circular(AppRadius.card),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 16,
                              offset: const Offset(0, -4),
                            ),
                          ],
                        ),
                        child: CustomScrollView(
                          controller: scrollController,
                          slivers: [
                            // Thanh nắm kéo & Tiêu đề trạng thái đồng bộ tức thì
                            SliverToBoxAdapter(
                              child: Column(
                                children: [
                                  const SizedBox(height: AppSpacing.sm),
                                  Container(
                                    width: 36,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: AppColors.outlineVariant,
                                      borderRadius:
                                          BorderRadius.circular(AppRadius.full),
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  Text(
                                    isSelected
                                        ? 'Tìm thấy 1 chỗ ở được ghim'
                                        : 'Tìm thấy ${state.visibleProperties.length} chỗ ở trong vùng này',
                                    style: AppTextStyles.labelLg.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                ],
                              ),
                            ),

                            // CHẾ ĐỘ ĐỘC QUYỀN: Nếu đã ghim địa điểm, CHỈ hiển thị duy nhất card đó + nút Dẫn đường
                            if (isSelected)
                              SliverPadding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md),
                                sliver: SliverToBoxAdapter(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _PropertyPreviewCard(
                                        title: state.selectedProperty!.title,
                                        sublocation:
                                            '${state.selectedProperty!.district}, Đà Nẵng',
                                        price:
                                            '${state.selectedProperty!.pricePerNight.toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (m) => "${m[1]}.")}đ',
                                        rating: state.selectedProperty!.rating,
                                        imageUrl: state.selectedProperty!
                                                .imageUrls.isNotEmpty
                                            ? state.selectedProperty!.imageUrls
                                                .first
                                            : '',
                                        onViewDetail: () =>
                                            Navigator.of(context).pushNamed(
                                          '/property-detail',
                                          arguments: state.selectedProperty,
                                        ),
                                      ),
                                      const SizedBox(height: AppSpacing.md),

                                      // Nút Dẫn đường thông minh tích hợp Deep Link tiện ích
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          // Sẽ kết nối Deep Link Google Maps ở giai đoạn sau
                                        },
                                        icon: const Icon(Icons.directions,
                                            color: AppColors.onPrimary),
                                        label: Text(
                                          'Dẫn đường từ vị trí hiện tại',
                                          style: AppTextStyles.labelLg.copyWith(
                                              color: AppColors.onPrimary),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.tertiary,
                                          minimumSize:
                                              const Size(double.infinity, 48),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                AppRadius.xl),
                                          ),
                                          elevation: 2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              // CHẾ ĐỘ DANH SÁCH: Nếu chưa chọn ghim, hiển thị toàn bộ homestay trong vùng nhìn
                              SliverPadding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md),
                                sliver: SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                      final property =
                                          state.visibleProperties[index];
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                            bottom: AppSpacing.md),
                                        child: GestureDetector(
                                          onTap: () {
                                            _animatedMapMove(
                                                LatLng(property.latitude,
                                                    property.longitude),
                                                16.0);
                                            context.read<MapBloc>().add(
                                                MapMarkerSelected(property.id));
                                          },
                                          child: _PropertyPreviewCard(
                                            title: property.title,
                                            sublocation:
                                                '${property.district}, Đà Nẵng',
                                            price:
                                                '${property.pricePerNight.toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (m) => "${m[1]}.")}đ',
                                            rating: property.rating,
                                            imageUrl:
                                                property.imageUrls.isNotEmpty
                                                    ? property.imageUrls.first
                                                    : '',
                                            onViewDetail: () =>
                                                Navigator.of(context).pushNamed(
                                              '/property-detail',
                                              arguments: property,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    childCount: state.visibleProperties.length,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // ===== 5. BOTTOM NAVIGATION BAR =====
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
            );
          },
        ),
      ),
    );
  }
}

// ===== CÁC SUB-WIDGETS GIỮ NGUYÊN BẢN CẤU TRÚC DESIGN SYSTEM =====

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
      child: Center(
        child: Text(
          price,
          style: AppTextStyles.labelLg.copyWith(
            color: isActive ? AppColors.onPrimary : AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _FloatingSearchBar extends StatefulWidget {
  final VoidCallback? onBackTap;
  const _FloatingSearchBar({this.onBackTap});

  @override
  State<_FloatingSearchBar> createState() => _FloatingSearchBarState();
}

class _FloatingSearchBarState extends State<_FloatingSearchBar> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    // Đồng bộ ngược chuỗi tìm kiếm hiện hành từ Bloc lên ô nhập khi re-render
    final currentQuery = context.read<MapBloc>().state.searchQuery;
    _searchController = TextEditingController(text: currentQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
            onPressed: widget.onBackTap,
            icon:
                const Icon(Icons.arrow_back, color: AppColors.onSurfaceVariant),
            iconSize: 22,
            style: IconButton.styleFrom(
              minimumSize:
                  const Size(AppTouchTarget.minSize, AppTouchTarget.minSize),
            ),
          ),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                // Đấu nối trực tiếp vào pipeline xử lý lọc của MapBloc
                context.read<MapBloc>().add(MapSearchInputChanged(value));
                setState(() {});
              },
              decoration: InputDecoration(
                hintText: 'Tìm homestay quanh đây...',
                hintStyle: AppTextStyles.labelLg.copyWith(
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              style: AppTextStyles.labelLg.copyWith(color: AppColors.onSurface),
            ),
          ),
          // Nút xóa nhanh từ khóa (Clear Button) khi đang nhập liệu
          if (_searchController.text.isNotEmpty)
            IconButton(
              onPressed: () {
                _searchController.clear();
                context.read<MapBloc>().add(MapSearchInputChanged(''));
                setState(() {});
              },
              icon: const Icon(Icons.clear, color: AppColors.onSurfaceVariant),
              iconSize: 20,
            ),
          Container(
            width: 1,
            height: 24,
            color: AppColors.outlineVariant,
            margin: const EdgeInsets.symmetric(horizontal: 4),
          ),
          IconButton(
            onPressed: () {
              // Sẽ kích hoạt bottom sheet bộ lọc nâng cao ở bước kế tiếp
            },
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
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            child: SizedBox(
              width: 96,
              height: 96,
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.surfaceContainerHigh,
                        child: const Icon(Icons.villa_outlined,
                            color: AppColors.outline),
                      ),
                    )
                  : Container(
                      color: AppColors.surfaceContainerHigh,
                      child: const Icon(Icons.villa_outlined,
                          color: AppColors.outline),
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
                    // FIX CHI TIẾT: Bọc Expanded cho vùng chứa giá để không đẩy nút tràn viền phải
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Từ',
                            style: AppTextStyles.labelMd.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          RichText(
                            maxLines: 1,
                            overflow: TextOverflow
                                .ellipsis, // Cắt chữ bằng dấu ... nếu text quá dài
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
                    ),
                    const SizedBox(
                        width: AppSpacing
                            .sm), // Khoảng đệm an toàn giữa giá và nút
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
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
