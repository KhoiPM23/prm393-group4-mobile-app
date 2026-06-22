import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_text_styles.dart';
import '../../domain/entities/property_entity.dart';
import '../widgets/vibe_bottom_nav_bar.dart';
import 'bloc/map_bloc.dart';
import 'bloc/map_event.dart';
import 'bloc/map_state.dart';

class ExploreMapScreen extends StatefulWidget {
  const ExploreMapScreen({super.key});

  @override
  State<ExploreMapScreen> createState() => _ExploreMapScreenState();
}

class _ExploreMapScreenState extends State<ExploreMapScreen>
    with TickerProviderStateMixin {
  int _currentNavIndex = 1;
  final MapController _mapController = MapController();
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  AnimationController? _cameraAnimController;
  final FocusNode _searchFocusNode = FocusNode();
  double _sheetExtent = 0.25;
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    context.read<MapBloc>().add(MapInitialized());
    _requestAndGetUserLocation();
  }

  @override
  void dispose() {
    _cameraAnimController?.dispose();
    _mapController.dispose();
    _searchFocusNode.dispose();
    _sheetController.dispose();
    super.dispose();
  }

  Future<void> _requestAndGetUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    final position = await Geolocator.getCurrentPosition();
    if (mounted) {
      context.read<MapBloc>().add(MapUserLocationUpdated(
          LatLng(position.latitude, position.longitude)));
    }
  }

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    _cameraAnimController?.dispose();
    final camera = _mapController.camera;
    final latTween = Tween<double>(
        begin: camera.center.latitude, end: destLocation.latitude);
    final lngTween = Tween<double>(
        begin: camera.center.longitude, end: destLocation.longitude);
    final zoomTween = Tween<double>(begin: camera.zoom, end: destZoom);

    final animationController = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    _cameraAnimController = animationController;
    final animation = CurvedAnimation(
        parent: animationController, curve: Curves.fastOutSlowIn);

    animationController.addListener(() {
      _mapController.move(
          LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
          zoomTween.evaluate(animation));
    });

    animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        animationController.dispose();
        if (_cameraAnimController == animationController) {
          _cameraAnimController = null;
        }
      }
    });
    animationController.forward();
  }

  String _calculateDistance(LatLng propertyLocation, LatLng? userLocation) {
    if (userLocation == null) return 'N/A';
    const Distance distanceCalculator = Distance();
    final double meter = distanceCalculator(userLocation, propertyLocation);
    if (meter < 1000) return '${meter.round()}m';
    return '${(meter / 1000).toStringAsFixed(1)}km';
  }

  Future<void> _launchGoogleMapsNavigation(double lat, double lng) async {
    // Sử dụng URL web với parameters /dir/ để yêu cầu vẽ đường (không tự động bắt đầu chế độ lái xe)
    final url = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _onNavTap(int index) {
    setState(() => _currentNavIndex = index);
    if (index == 0) Navigator.of(context).pushReplacementNamed('/home');
    if (index == 2 || index == 3) {
      Navigator.of(context).pushReplacementNamed('/profile');
    }
  }

  void _updateViewportBounds() {
    final bounds = _mapController.camera.visibleBounds;
    context.read<MapBloc>().add(MapViewportChanged(
        minLat: bounds.southWest.latitude,
        maxLat: bounds.northEast.latitude,
        minLng: bounds.southWest.longitude,
        maxLng: bounds.northEast.longitude));
  }

  Widget _buildQuickFilterChip({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? Colors.black : Colors.grey.shade300,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isActive ? 0.2 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 16, color: isActive ? Colors.white : Colors.black87),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDateRange() async {
    final initialRange = _selectedDateRange ??
        DateTimeRange(
          start: DateTime.now(),
          end: DateTime.now().add(const Duration(days: 2)),
        );

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: initialRange,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.black,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: false,
      body: MultiBlocListener(
        listeners: [
          BlocListener<MapBloc, MapState>(
            listenWhen: (previous, current) =>
                previous.selectedProperty != current.selectedProperty,
            listener: (context, state) {
              if (state.selectedProperty != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _sheetController.animateTo(0.55,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic);

                  _animatedMapMove(
                      LatLng(state.selectedProperty!.latitude,
                          state.selectedProperty!.longitude),
                      15.5);
                });
              } else {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _sheetController.animateTo(0.06,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic);
                });
              }
            },
          ),
          BlocListener<MapBloc, MapState>(
            listenWhen: (previous, current) =>
                previous.searchQuery != current.searchQuery &&
                current.searchQuery.isNotEmpty,
            listener: (context, state) {
              if (state.allProperties.isNotEmpty) {
                double sumLat = 0;
                double sumLng = 0;
                for (var p in state.allProperties) {
                  sumLat += p.latitude;
                  sumLng += p.longitude;
                }
                final center = LatLng(sumLat / state.allProperties.length,
                    sumLng / state.allProperties.length);
                _animatedMapMove(
                    center, 13.0); // Tự động bay tới vùng có kết quả
              }
            },
          ),
        ],
        child: BlocBuilder<MapBloc, MapState>(
          builder: (context, state) {
            final isSelected = state.selectedProperty != null;
            final isSearchActive = state.searchQuery.isNotEmpty;
            final displayList =
                isSearchActive ? state.allProperties : state.visibleProperties;

            return Stack(
              children: [
                // 1. LAYER BẢN ĐỒ NỀN
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
                      onTap: (_, __) {
                        _searchFocusNode.unfocus();
                        if (isSelected) {
                          context.read<MapBloc>().add(MapMarkerSelected(''));
                        }
                      },
                    ),
                    children: [
                      TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.vibelocals.app'),
                      if (state.userLocation != null)
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: state.userLocation!,
                              width: 36, // tăng từ 24 → 36
                              height: 36, // tăng từ 24 → 36
                              child:
                                  const _UserLocationBeacon(), // ← chỉ đổi dòng này
                            ),
                          ],
                        ),
                      MarkerLayer(
                        markers: state.visibleProperties.map((property) {
                          final isActive =
                              state.selectedProperty?.id == property.id;
                          return Marker(
                            point:
                                LatLng(property.latitude, property.longitude),
                            width: 75,
                            height: 42,
                            alignment: Alignment.center,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => context
                                  .read<MapBloc>()
                                  .add(MapMarkerSelected(property.id)),
                              child: _PriceMarker(
                                  price:
                                      '${(property.pricePerNight / 1000000).toStringAsFixed(1)}M',
                                  isActive: isActive),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                // 1.5 BACKDROP BLUR KHI TÌM KIẾM
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _searchFocusNode,
                    builder: (context, child) {
                      if (!_searchFocusNode.hasFocus) {
                        return const SizedBox.shrink();
                      }
                      return BackdropFilter(
                        filter: ui.ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                        child: Container(
                            color: Colors.black.withValues(alpha: 0.25)),
                      );
                    },
                  ),
                ),

                // 2. THANH KIỂM SOÁT TÌM KIẾM & CHỌN NGÀY (GLASSMORPHISM)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: ClipRect(
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.70),
                          border: Border(
                            bottom: BorderSide(
                                color: Colors.black.withValues(alpha: 0.05),
                                width: 1),
                          ),
                        ),
                        child: SafeArea(
                          bottom: false,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(AppSpacing.md,
                                AppSpacing.md, AppSpacing.md, 12),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _FloatingSearchBar(
                                  focusNode: _searchFocusNode,
                                  onBackTap: () {
                                    _searchFocusNode.unfocus();
                                    Navigator.of(context).pop();
                                  },
                                ),
                                const SizedBox(height: 8),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  clipBehavior: Clip.none,
                                  child: Row(
                                    children: [
                                      GestureDetector(
                                        onTap: _pickDateRange,
                                        child: AnimatedContainer(
                                          duration:
                                              const Duration(milliseconds: 250),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: _selectedDateRange != null
                                                ? null
                                                : Colors.white,
                                            gradient: _selectedDateRange != null
                                                ? const LinearGradient(
                                                    colors: [
                                                      AppColors
                                                          .secondaryContainer,
                                                      AppColors.secondaryFixed,
                                                    ],
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                  )
                                                : null,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border: Border.all(
                                              color: _selectedDateRange != null
                                                  ? AppColors.secondary
                                                      .withValues(alpha: 0.6)
                                                  : Colors.transparent,
                                              width: 1,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: _selectedDateRange !=
                                                        null
                                                    ? AppColors.secondary
                                                        .withValues(alpha: 0.20)
                                                    : Colors.black.withValues(
                                                        alpha: 0.08),
                                                blurRadius:
                                                    _selectedDateRange != null
                                                        ? 12
                                                        : 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              AnimatedSwitcher(
                                                duration: const Duration(
                                                    milliseconds: 200),
                                                child: Icon(
                                                  _selectedDateRange != null
                                                      ? Icons.calendar_today
                                                      : Icons.calendar_month,
                                                  key: ValueKey(
                                                      _selectedDateRange !=
                                                          null),
                                                  size: 16,
                                                  color: _selectedDateRange !=
                                                          null
                                                      ? AppColors
                                                          .onSecondaryContainer
                                                      : Colors.grey.shade700,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                _selectedDateRange == null
                                                    ? 'Chọn ngày dự kiến'
                                                    : '${_selectedDateRange!.start.day}/${_selectedDateRange!.start.month} - ${_selectedDateRange!.end.day}/${_selectedDateRange!.end.month}',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: _selectedDateRange !=
                                                          null
                                                      ? AppColors
                                                          .onSecondaryContainer
                                                      : AppColors.onSurface,
                                                ),
                                              ),
                                              if (_selectedDateRange !=
                                                  null) ...[
                                                const SizedBox(width: 6),
                                                GestureDetector(
                                                  onTap: () => setState(() =>
                                                      _selectedDateRange =
                                                          null),
                                                  child: Icon(
                                                      Icons.close_rounded,
                                                      size: 14,
                                                      color: AppColors
                                                          .onSecondaryContainer
                                                          .withValues(
                                                              alpha: 0.7)),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      _buildQuickFilterChip(
                                        icon: Icons.my_location,
                                        label: 'Gần tôi',
                                        isActive: state.userLocation != null,
                                        onTap: () async {
                                          await _requestAndGetUserLocation();
                                          if (state.userLocation != null) {
                                            _animatedMapMove(
                                                state.userLocation!, 15.5);
                                          }
                                        },
                                      ),
                                      const SizedBox(width: 8),
                                      _buildQuickFilterChip(
                                        icon: Icons.diamond,
                                        label: 'Siêu cấp',
                                        isActive: state.minRating != null &&
                                            state.minRating! >= 4.5,
                                        onTap: () {
                                          final current =
                                              context.read<MapBloc>().state;
                                          final isAlreadySuper =
                                              current.minRating != null &&
                                                  current.minRating! >= 4.5;
                                          context
                                              .read<MapBloc>()
                                              .add(MapFilterApplied(
                                                minPrice: current.minPrice,
                                                maxPrice: current.maxPrice,
                                                minRating:
                                                    isAlreadySuper ? null : 4.5,
                                                selectedAmenities:
                                                    current.selectedAmenities,
                                              ));
                                        },
                                      ),
                                      const SizedBox(width: 8),
                                      _buildQuickFilterChip(
                                        icon: Icons.pool,
                                        label: 'Hồ bơi',
                                        isActive: state.selectedAmenities
                                            .contains('Hồ bơi'),
                                        onTap: () {
                                          final current =
                                              context.read<MapBloc>().state;
                                          final amens = List<String>.from(
                                              current.selectedAmenities);
                                          if (amens.contains('Hồ bơi')) {
                                            amens.remove('Hồ bơi');
                                          } else {
                                            amens.add('Hồ bơi');
                                          }
                                          context
                                              .read<MapBloc>()
                                              .add(MapFilterApplied(
                                                minPrice: current.minPrice,
                                                maxPrice: current.maxPrice,
                                                minRating: current.minRating,
                                                selectedAmenities: amens,
                                              ));
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // 2.5 FLOATING MAP CONTROLS (My Location / Zoom)
                if (_sheetExtent < 0.8)
                  Positioned(
                    right: 16,
                    bottom:
                        MediaQuery.of(context).size.height * _sheetExtent + 16,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FloatingActionButton.small(
                          heroTag: 'my_location',
                          backgroundColor: Colors.white,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          onPressed: () {
                            if (state.userLocation != null) {
                              _animatedMapMove(state.userLocation!, 15.5);
                            } else {
                              _requestAndGetUserLocation();
                            }
                          },
                          child: const Icon(Icons.my_location,
                              color: Colors.black87),
                        ),
                      ],
                    ),
                  )
                else
                  const SizedBox.shrink(),

                // 3. CONTAINER TẤM TRƯỢT THÍCH ỨNG CHẾ ĐỘ HIỂN THỊ ĐỘC QUYỀN
                Positioned.fill(
                  child: NotificationListener<DraggableScrollableNotification>(
                    onNotification: (notification) {
                      setState(() {
                        _sheetExtent = notification.extent;
                      });
                      // Cải tiến cử chỉ vuốt xuống thoát ghim nhạy bén: Chỉ cần kéo nhẹ xuống dưới mốc 0.35 sẽ giải ghim ngay lập tức
                      if (isSelected && notification.extent <= 0.18) {
                        context.read<MapBloc>().add(MapMarkerSelected(''));
                      }
                      return true;
                    },
                    child: DraggableScrollableSheet(
                      controller: _sheetController,
                      // Cải tiến: Mốc chiều cao 0.45 để ôm đủ trọn vẹn mọi thứ, không bị mất nút
                      initialChildSize: isSelected ? 0.47 : 0.35,
                      minChildSize:
                          0.10, // Giữ min 0.10 cho danh sách, nhưng isSelected sẽ tự dismiss nếu dưới 0.18
                      maxChildSize: isSelected ? 0.47 : 0.88,
                      snap: true,
                      snapSizes: isSelected
                          ? const [0.10, 0.47]
                          : const [0.10, 0.35, 0.88],
                      builder: (context, scrollController) {
                        return Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.transparent
                                : AppColors.surface,
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(24)),
                            boxShadow: isSelected
                                ? null
                                : [
                                    BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.15),
                                        blurRadius: 20,
                                        offset: const Offset(0, -4))
                                  ],
                          ),
                          // Sử dụng ListView duy nhất bao trọn tất cả, từ Header đến các Item.
                          // Điều này giúp toàn bộ vùng cửa sổ (kể cả Header) đều nhận diện thao tác kéo (Drag) mượt mà!
                          child: ListView.builder(
                            controller: scrollController,
                            padding: EdgeInsets.zero,
                            itemCount: isSelected
                                ? 2 // Detail: Header Handle + PropertyPreviewCard
                                : (state.status == MapStatus.loading
                                    ? 5 // List: Header + 4 Skeletons
                                    : displayList.length +
                                        1), // List: Header + Properties
                            itemBuilder: (context, index) {
                              // INDEX 0: LUÔN LÀ HEADER HANDLE (Áp dụng chung cho cả 2 chế độ)
                              if (index == 0) {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const SizedBox(height: 12),
                                    Container(
                                      width: 40,
                                      height: 5,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade300,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    if (!isSelected) ...[
                                      Text(
                                        'Tìm thấy ${displayList.length} chỗ ở trong vùng này',
                                        style: AppTextStyles.labelLg.copyWith(
                                          color: AppColors.onSurface,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 12),
                                  ],
                                );
                              }

                              // XỬ LÝ CHẾ ĐỘ MỘT ĐỊA ĐIỂM (DETAIL)
                              if (isSelected) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: _PropertyPreviewCard(
                                    property: state.selectedProperty!,
                                    distance: _calculateDistance(
                                      LatLng(state.selectedProperty!.latitude,
                                          state.selectedProperty!.longitude),
                                      state.userLocation,
                                    ),
                                    actionButton: ElevatedButton.icon(
                                      onPressed: () =>
                                          _launchGoogleMapsNavigation(
                                              state.selectedProperty!.latitude,
                                              state
                                                  .selectedProperty!.longitude),
                                      icon: const Icon(Icons.directions,
                                          color: Colors.white, size: 16),
                                      label: const Text('Dẫn đường',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.tertiary,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        minimumSize: const Size(105, 38),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                      ),
                                    ),
                                    secondaryActionButton: OutlinedButton(
                                      onPressed: () => Navigator.of(context)
                                          .pushNamed('/property-detail',
                                              arguments:
                                                  state.selectedProperty),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.primary,
                                        side: const BorderSide(
                                            color: AppColors.primary),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        minimumSize: const Size(85, 38),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                      ),
                                      child: const Text('Chi tiết',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13)),
                                    ),
                                  ),
                                );
                              }

                              // XỬ LÝ CHẾ ĐỘ DANH SÁCH (LIST)
                              // Nếu cửa sổ đang thu gọn ở mức mép dưới (< 0.11), KHÔNG render các item bên dưới Header
                              if (_sheetExtent <= 0.11)
                                return const SizedBox.shrink();

                              if (state.status == MapStatus.loading) {
                                // Trả về từng Skeleton Item
                                return Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: AppSpacing.md,
                                      left: AppSpacing.md,
                                      right: AppSpacing.md),
                                  child: TweenAnimationBuilder<double>(
                                    tween: Tween(begin: 0.0, end: 1.0),
                                    duration:
                                        const Duration(milliseconds: 1000),
                                    curve: Curves.easeInOutSine,
                                    builder: (context, value, child) {
                                      final opacity =
                                          (math.sin(value * 3.14)).abs() * 0.5 +
                                              0.5;
                                      return Opacity(
                                          opacity: opacity, child: child);
                                    },
                                    child: Container(
                                      height: 280,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                  ),
                                );
                              }

                              // Trả về từng Property Item
                              final property = displayList[index - 1];
                              return Padding(
                                padding: const EdgeInsets.only(
                                    bottom: AppSpacing.md,
                                    left: AppSpacing.md,
                                    right: AppSpacing.md),
                                child: TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0.0, end: 1.0),
                                  duration: Duration(
                                      milliseconds: 300 +
                                          ((index - 1) * 50)
                                              .clamp(0, 400)
                                              .toInt()),
                                  curve: Curves.easeOutCubic,
                                  builder: (context, value, child) {
                                    return Opacity(
                                      opacity: value,
                                      child: Transform.translate(
                                        offset: Offset(0, 40 * (1 - value)),
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: Material(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(16),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(16),
                                      splashColor: AppColors.primaryFixed
                                          .withValues(alpha: 0.3),
                                      onTap: () => context
                                          .read<MapBloc>()
                                          .add(MapMarkerSelected(property.id)),
                                      child: _PropertyPreviewCard(
                                        property: property,
                                        distance: _calculateDistance(
                                          LatLng(property.latitude,
                                              property.longitude),
                                          state.userLocation,
                                        ),
                                        actionButton: OutlinedButton(
                                          onPressed: () => Navigator.of(context)
                                              .pushNamed('/property-detail',
                                                  arguments: property),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: AppColors.primary,
                                            side: const BorderSide(
                                                color: AppColors.primary),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                            minimumSize: const Size(85, 38),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10),
                                          ),
                                          child: const Text('Chi tiết',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13)),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // 4. LAYER THANH Tab ĐIỀU HƯỚNG
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  bottom: _sheetExtent < 0.16 ? -110 : 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.only(bottom: 12),
                    child: VibeBottomNavBar(
                        currentIndex: _currentNavIndex, onTap: _onNavTap),
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

class _PriceMarker extends StatefulWidget {
  final String price;
  final bool isActive;
  const _PriceMarker({required this.price, required this.isActive});

  @override
  State<_PriceMarker> createState() => _PriceMarkerState();
}

class _PriceMarkerState extends State<_PriceMarker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spawnCtrl;
  late final Animation<double> _spawnAnim;

  @override
  void initState() {
    super.initState();
    _spawnCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _spawnAnim = CurvedAnimation(parent: _spawnCtrl, curve: Curves.elasticOut);

    // Tạo độ trễ ngẫu nhiên nhẹ dựa vào hashCode của giá để các marker không hiện ra cùng lúc (Staggered Load)
    Future.delayed(Duration(milliseconds: widget.price.hashCode % 400), () {
      if (mounted) _spawnCtrl.forward();
    });
  }

  @override
  void dispose() {
    _spawnCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, -0.5),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: _spawnCtrl, curve: Curves.bounceOut)),
      child: FadeTransition(
        opacity: _spawnAnim,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 1.0, end: widget.isActive ? 1.15 : 1.0),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutBack,
          builder: (_, scale, child) =>
              Transform.scale(scale: scale, child: child),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: widget.isActive ? Colors.black : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: widget.isActive
                  ? Border.all(color: Colors.transparent, width: 1)
                  : Border.all(color: Colors.grey.shade300, width: 1),
              boxShadow: [
                BoxShadow(
                  color: widget.isActive
                      ? Colors.black.withValues(alpha: 0.35)
                      : Colors.black.withValues(alpha: 0.12),
                  blurRadius: widget.isActive ? 16 : 6,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Center(
              child: Text(
                widget.price,
                style: TextStyle(
                  color: widget.isActive ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: widget.isActive ? 14 : 13,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PropertyPreviewCard extends StatefulWidget {
  final PropertyEntity property;
  final String distance;
  final Widget actionButton;
  final Widget? secondaryActionButton;

  const _PropertyPreviewCard(
      {required this.property,
      required this.distance,
      required this.actionButton,
      this.secondaryActionButton});

  @override
  State<_PropertyPreviewCard> createState() => _PropertyPreviewCardState();
}

class _PropertyPreviewCardState extends State<_PropertyPreviewCard> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Stack(
              children: [
                Hero(
                  tag: 'property-image-${widget.property.id}',
                  child: SizedBox(
                    width: double.infinity,
                    height: 145,
                    child: widget.property.imageUrls.isNotEmpty
                        ? PageView.builder(
                            controller: _pageController,
                            onPageChanged: (idx) =>
                                setState(() => _currentPage = idx),
                            itemCount: widget.property.imageUrls.length,
                            itemBuilder: (context, index) {
                              return Image.network(
                                widget.property.imageUrls[index],
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                    color: Colors.grey.shade100,
                                    child: const Icon(Icons.villa,
                                        color: Colors.grey)),
                              );
                            },
                          )
                        : Container(
                            color: Colors.grey.shade100,
                            child: const Icon(Icons.villa, color: Colors.grey)),
                  ),
                ),
                // Premium dots indicator
                if (widget.property.imageUrls.length > 1)
                  Positioned(
                    bottom: 10,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        widget.property.imageUrls.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: _currentPage == index ? 16 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(3),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 2,
                                  offset: const Offset(0, 1))
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: _FavoriteButton(propertyId: widget.property.id),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                        child: Text(widget.property.title,
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis)),
                    const SizedBox(width: 6),
                    Row(children: [
                      const Icon(Icons.star, size: 14, color: Colors.black),
                      const SizedBox(width: 2),
                      Text(widget.property.rating.toStringAsFixed(1),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Colors.black))
                    ]),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                    '${widget.property.district}, Đà Nẵng • Cách ${widget.distance}',
                    style:
                        TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: RichText(
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(children: [
                          TextSpan(
                              text:
                                  'Từ ${(widget.property.pricePerNight).toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (m) => "${m[1]}.")}đ',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 14)),
                          TextSpan(
                              text: ' /đêm',
                              style: TextStyle(
                                  color: Colors.grey.shade600, fontSize: 12)),
                        ]),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.secondaryActionButton != null) ...[
                          widget.secondaryActionButton!,
                          const SizedBox(width: 6),
                        ],
                        widget.actionButton,
                      ],
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

class _FloatingSearchBar extends StatefulWidget {
  final VoidCallback? onBackTap;
  final FocusNode focusNode;
  const _FloatingSearchBar({this.onBackTap, required this.focusNode});

  @override
  State<_FloatingSearchBar> createState() => _FloatingSearchBarState();
}

class _FloatingSearchBarState extends State<_FloatingSearchBar> {
  late final TextEditingController _searchController;
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _dropdownKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  Timer? _debounceTimer;
  VoidCallback? _focusListener;

  static final List<String> _searchHistory = [
    'Khách sạn Sơn Trà',
    'Homestay Hải Châu'
  ];

  @override
  void initState() {
    super.initState();
    _searchController =
        TextEditingController(text: context.read<MapBloc>().state.searchQuery);
    // Lưu reference để dispose đúng cách
    _focusListener = () {
      if (widget.focusNode.hasFocus) {
        _showSearchOverlay();
      } else {
        _hideSearchOverlay();
      }
    };
    widget.focusNode.addListener(_focusListener!);
    widget.focusNode.addListener(() {
      if (mounted)
        setState(() {}); // Kích hoạt rebuild để AnimatedContainer đổi shadow
    });
  }

  void _saveQueryToHistory(String value) {
    final trimmed = value.trim();
    if (trimmed.isNotEmpty && !_searchHistory.contains(trimmed)) {
      setState(() => _searchHistory.insert(0, trimmed));
    }
  }

  @override
  void dispose() {
    // Remove đúng listener đã add — không còn memory leak
    if (_focusListener != null) {
      widget.focusNode.removeListener(_focusListener!);
    }
    _debounceTimer?.cancel();
    _hideSearchOverlay();
    _searchController.dispose();
    super.dispose();
  }

  void _showSearchOverlay() {
    _hideSearchOverlay();
    final mapBloc = context.read<MapBloc>();
    final renderBox = context.findRenderObject() as RenderBox?;
    final searchBarWidth =
        renderBox?.size.width ?? (MediaQuery.of(context).size.width - 32);

    _overlayEntry = OverlayEntry(
      builder: (overlayContext) => Stack(
        children: [
          Positioned.fill(
            child: Listener(
              behavior: HitTestBehavior.translucent,
              onPointerDown: (_) => widget.focusNode.unfocus(),
            ),
          ),
          Positioned(
            width: searchBarWidth,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: const Offset(0, 60),
              child: BlocProvider.value(
                value: mapBloc,
                child: Material(
                  key: _dropdownKey,
                  elevation: 8,
                  borderRadius: BorderRadius.circular(24),
                  color: Colors.white,
                  child: BlocBuilder<MapBloc, MapState>(
                    builder: (context, state) {
                      final query = _searchController.text.trim();
                      if (query.isEmpty) {
                        return Container(
                          constraints: const BoxConstraints(maxHeight: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 8),
                                  child: Text('Tìm kiếm gần đây',
                                      style: TextStyle(
                                          color: Colors.grey.shade800,
                                          fontWeight: FontWeight.bold))),
                              Flexible(
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  padding: EdgeInsets.zero,
                                  itemCount: _searchHistory.length,
                                  itemBuilder: (context, index) => ListTile(
                                    leading: const Icon(Icons.history,
                                        size: 20, color: Colors.black54),
                                    title: Text(_searchHistory[index],
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w500)),
                                    dense: true,
                                    onTap: () {
                                      _searchController.text =
                                          _searchHistory[index];
                                      mapBloc.add(MapSearchInputChanged(
                                          _searchHistory[index]));
                                      widget.focusNode.unfocus();
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      if (state.visibleProperties.isEmpty) {
                        return const Padding(
                            padding: EdgeInsets.all(20),
                            child: Text('Không tìm thấy kết quả phù hợp',
                                style: TextStyle(fontWeight: FontWeight.w500)));
                      }
                      return Container(
                        constraints: const BoxConstraints(maxHeight: 300),
                        child: ListView.builder(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: state.visibleProperties.length,
                          itemBuilder: (context, index) {
                            final property = state.visibleProperties[index];
                            return ListTile(
                              leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      shape: BoxShape.circle),
                                  child: const Icon(Icons.location_on,
                                      size: 20, color: Colors.black)),
                              title: Text(property.title,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                              subtitle: Text('${property.district}, Đà Nẵng',
                                  style:
                                      TextStyle(color: Colors.grey.shade600)),
                              dense: true,
                              onTap: () {
                                _saveQueryToHistory(property.title);
                                mapBloc.add(MapMarkerSelected(property.id));
                                _searchController.text = property.title;
                                widget.focusNode.unfocus();
                              },
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideSearchOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showFilterBottomSheet(BuildContext parentContext) {
    final mapBloc = parentContext.read<MapBloc>();
    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider.value(
        value: mapBloc,
        child: const _MapFilterModal(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isFocused = widget.focusNode.hasFocus;

    return CompositedTransformTarget(
      link: _layerLink,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            // Viền xanh nhạt khi focus — subtle nhưng rõ ràng
            color: isFocused
                ? AppColors.primary.withValues(alpha: 0.40)
                : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isFocused
                  ? AppColors.primary.withValues(alpha: 0.12)
                  : Colors.black.withValues(alpha: 0.10),
              blurRadius: isFocused ? 20 : 10,
              spreadRadius: isFocused ? 2 : 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            IconButton(
                onPressed: widget.onBackTap,
                icon: const Icon(Icons.arrow_back, color: Colors.black)),
            Expanded(
              child: TextField(
                controller: _searchController,
                focusNode: widget.focusNode,
                onChanged: (text) {
                  if (_debounceTimer?.isActive ?? false) {
                    _debounceTimer!.cancel();
                  }
                  _debounceTimer = Timer(const Duration(milliseconds: 300), () {
                    context.read<MapBloc>().add(MapSearchInputChanged(text));
                    _overlayEntry?.markNeedsBuild();
                  });
                },
                onSubmitted: (value) {
                  _saveQueryToHistory(value);
                  context.read<MapBloc>().add(MapSearchInputChanged(value));
                  widget.focusNode.unfocus();
                },
                decoration: const InputDecoration(
                    hintText: 'Tìm homestay quanh đây...',
                    hintStyle: TextStyle(
                        color: Colors.black54, fontWeight: FontWeight.w500),
                    border: InputBorder.none,
                    isDense: true),
                style: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.w500),
              ),
            ),
            if (_searchController.text.isNotEmpty)
              IconButton(
                  onPressed: () {
                    _searchController.clear();
                    context.read<MapBloc>().add(MapSearchInputChanged(''));
                    setState(() {});
                  },
                  icon:
                      const Icon(Icons.clear, color: Colors.black54, size: 20)),
            Container(
                width: 1,
                height: 24,
                color: Colors.grey.shade300,
                margin: const EdgeInsets.symmetric(horizontal: 4)),
            IconButton(
              onPressed: () => _showFilterBottomSheet(context),
              icon: const Icon(Icons.tune, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapFilterModal extends StatefulWidget {
  const _MapFilterModal();

  @override
  State<_MapFilterModal> createState() => _MapFilterModalState();
}

class _MapFilterModalState extends State<_MapFilterModal> {
  RangeValues _currentPriceRange = const RangeValues(0, 10000000);
  double? _localMinRating;
  List<String> _localAmenities = [];

  final List<String> _availableAmenities = [
    'Wifi',
    'Hồ bơi',
    'Bếp',
    'Điều hòa',
    'Phòng gym'
  ];

  @override
  void initState() {
    super.initState();
    final currentState = context.read<MapBloc>().state;
    _currentPriceRange = RangeValues(
        currentState.minPrice ?? 0, currentState.maxPrice ?? 10000000);
    _localMinRating = currentState.minRating;
    _localAmenities = List.from(currentState.selectedAmenities);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                    icon: const Icon(Icons.close, color: Colors.black),
                    onPressed: () => Navigator.pop(context)),
                Text('Bộ lọc',
                    style: AppTextStyles.titleLg.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18)),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _currentPriceRange = const RangeValues(0, 10000000);
                      _localMinRating = null;
                      _localAmenities.clear();
                    });
                    // Reset BLoC state ngay lập tức — không cần chờ user nhấn nút CTA
                    context.read<MapBloc>().add(MapFilterApplied(
                          minPrice: 0,
                          maxPrice: 10000000,
                          minRating: null,
                          selectedAmenities: const [],
                        ));
                  },
                  child: const Text('Xóa tất cả',
                      style: TextStyle(
                          color: Colors.black,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.bold)),
                )
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                Text('Khoảng giá',
                    style: AppTextStyles.titleLg.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18)),
                const SizedBox(height: 8),
                Text('Giá đêm trung bình chưa bao gồm phí và thuế',
                    style:
                        TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                const SizedBox(height: 24),
                RangeSlider(
                  values: _currentPriceRange,
                  min: 0,
                  max: 10000000,
                  divisions: 20,
                  activeColor: Colors.black,
                  inactiveColor: Colors.grey.shade300,
                  labels: RangeLabels(
                    '${(_currentPriceRange.start / 1000000).toStringAsFixed(1)}M',
                    '${(_currentPriceRange.end / 1000000).toStringAsFixed(1)}M',
                  ),
                  onChanged: (RangeValues values) {
                    setState(() {
                      _currentPriceRange = values;
                    });
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          'Từ ${(_currentPriceRange.start).toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (m) => "${m[1]}.")}đ',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                          'Đến ${(_currentPriceRange.end).toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (m) => "${m[1]}.")}đ+',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                const Divider(height: 1),
                const SizedBox(height: 24),

                // KHU VỰC LỌC SAO TRỰC QUAN (Airbnb Style)
                Text('Xếp hạng tối thiểu',
                    style: AppTextStyles.titleLg.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18)),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [null, 3.5, 4.0, 4.5, 5.0].map((rating) {
                      final isSelected = _localMinRating == rating;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(rating == null ? 'Bất kỳ' : '$rating+ ⭐',
                              style: TextStyle(
                                  color:
                                      isSelected ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.bold)),
                          selected: isSelected,
                          onSelected: (bool selected) {
                            if (selected) {
                              setState(() => _localMinRating = rating);
                            }
                          },
                          backgroundColor: Colors.white,
                          selectedColor: Colors.black,
                          showCheckmark: false,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                              side: BorderSide(
                                  color: isSelected
                                      ? Colors.black
                                      : Colors.grey.shade300,
                                  width: 1.5)),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 32),
                const Divider(height: 1),
                const SizedBox(height: 24),
                Text('Tiện ích',
                    style: AppTextStyles.titleLg.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18)),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _availableAmenities.map((amenity) {
                    final isSelected = _localAmenities.contains(amenity);
                    return FilterChip(
                      label: Text(amenity),
                      selected: isSelected,
                      selectedColor: Colors.black,
                      checkmarkColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 14),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: BorderSide(
                              color: isSelected
                                  ? Colors.black
                                  : Colors.grey.shade300,
                              width: 1.5)),
                      onSelected: (bool selected) {
                        setState(() {
                          if (selected) {
                            _localAmenities.add(amenity);
                          } else {
                            _localAmenities.remove(amenity);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(20),
            child: BlocBuilder<MapBloc, MapState>(
              buildWhen: (prev, curr) =>
                  prev.allProperties != curr.allProperties,
              builder: (context, state) {
                final minP = _currentPriceRange.start;
                final maxP = _currentPriceRange.end;

                final previewCount = state.allProperties.where((p) {
                  if (p.pricePerNight < minP) return false;
                  if (p.pricePerNight > maxP) return false;
                  if (_localMinRating != null && p.rating < _localMinRating!) {
                    return false;
                  }
                  if (_localAmenities.isNotEmpty &&
                      !_localAmenities.every((a) => p.amenities.contains(a))) {
                    return false;
                  }
                  return true;
                }).length;

                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    context.read<MapBloc>().add(MapFilterApplied(
                          minPrice: minP,
                          maxPrice: maxP,
                          minRating: _localMinRating,
                          selectedAmenities: _localAmenities,
                        ));
                    Navigator.pop(context);
                  },
                  child: Text('Hiển thị $previewCount chỗ ở',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonCard extends StatefulWidget {
  const _SkeletonCard();
  @override
  State<_SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<_SkeletonCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        final shimmer = Color.lerp(
          Colors.grey.shade200,
          Colors.grey.shade100,
          _anim.value,
        )!;
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Placeholder ảnh
              Container(
                height: 145,
                decoration: BoxDecoration(
                  color: shimmer,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _bar(shimmer, width: 180, height: 14),
                    const SizedBox(height: 6),
                    _bar(shimmer, width: 130, height: 12),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _bar(shimmer, width: 90, height: 14),
                        const Spacer(),
                        _bar(shimmer, width: 80, height: 36, radius: 8),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _bar(Color color,
      {required double width, required double height, double radius = 6}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class _FavoriteButton extends StatefulWidget {
  final String propertyId;
  const _FavoriteButton({required this.propertyId});

  @override
  State<_FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<_FavoriteButton>
    with SingleTickerProviderStateMixin {
  bool _isFavorite = false;
  late final AnimationController _bounceCtrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    // TweenSequence tạo hiệu ứng: phình to → nảy lại → ổn định
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.45), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.45, end: 0.90), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.90, end: 1.0), weight: 30),
    ]).animate(CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() => _isFavorite = !_isFavorite);
        _bounceCtrl.forward(from: 0); // Trigger mỗi lần tap
      },
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.92),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          // AnimatedSwitcher tạo cross-fade icon khi toggle
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              key: ValueKey(
                  _isFavorite), // Quan trọng: key khác nhau mới trigger switcher
              color: _isFavorite ? Colors.red.shade400 : Colors.black54,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }
}

class _UserLocationBeacon extends StatefulWidget {
  const _UserLocationBeacon();
  @override
  State<_UserLocationBeacon> createState() => _UserLocationBeaconState();
}

class _UserLocationBeaconState extends State<_UserLocationBeacon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _ringScale;
  late final Animation<double> _ringOpacity;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
    _ringScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    _ringOpacity = Tween<double>(begin: 0.6, end: 0.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Vòng sóng lan tỏa
          AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) => Opacity(
              opacity: _ringOpacity.value,
              child: Transform.scale(
                scale: _ringScale.value,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.blue.shade400,
                      width: 2.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Vòng nền mờ
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue.withValues(alpha: 0.20),
            ),
          ),
          // Chấm xanh trung tâm — viền trắng rõ nét
          Container(
            width: 13,
            height: 13,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue.shade600,
              border: Border.all(color: Colors.white, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withValues(alpha: 0.4),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
