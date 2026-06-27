import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_text_styles.dart';
import '../widgets/vibe_bottom_nav_bar.dart';
import 'bloc/map_bloc.dart';
import 'bloc/map_event.dart';
import 'bloc/map_state.dart';
import 'widgets/price_marker.dart';
import 'widgets/map_scale_bar.dart';
import 'widgets/property_card.dart';
import 'widgets/floating_search_bar.dart';
import 'widgets/user_location_beacon.dart';

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
  final ValueNotifier<double> _sheetExtentNotifier =
      ValueNotifier<double>(0.10);
  DateTimeRange? _selectedDateRange;
  Timer? _boundsDebounceTimer;

  @override
  void initState() {
    super.initState();
    context.read<MapBloc>().add(MapInitialized());
    _requestAndGetUserLocation();
  }

  @override
  void dispose() {
    _boundsDebounceTimer?.cancel();
    _sheetExtentNotifier.dispose();
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
        _updateViewportBounds();
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
    final url = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng';
    final uri = Uri.parse(url);

    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Không thể mở hướng dẫn chỉ đường: $e');
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
    _boundsDebounceTimer?.cancel();
    _boundsDebounceTimer = Timer(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      final bounds = _mapController.camera.visibleBounds;
      context.read<MapBloc>().add(MapViewportChanged(
          minLat: bounds.southWest.latitude,
          maxLat: bounds.northEast.latitude,
          minLng: bounds.southWest.longitude,
          maxLng: bounds.northEast.longitude));
    });
  }

  Widget _buildQuickFilterChip({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
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
    final mq = MediaQuery.of(context);
    // Tính toán chiều cao tối đa của tấm trượt để vừa khít dưới thanh tìm kiếm (khoảng 145px + safeArea)
    final double maxListSize =
        (1.0 - ((mq.padding.top + 130) / mq.size.height)).clamp(0.5, 0.95);

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
                  _sheetController.animateTo(0.40,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut);

                  _animatedMapMove(
                      LatLng(state.selectedProperty!.latitude,
                          state.selectedProperty!.longitude),
                      15.5);
                });
              } else {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _sheetController.animateTo(0.10,
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
        child: Stack(
          children: [
            // 1. LAYER BẢN ĐỒ NỀN
            Positioned.fill(
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: const LatLng(16.055, 108.235),
                  initialZoom: 13.5,
                  minZoom: 9.0, // Cho phép zoom xa hơn để thấy tới Hội An
                  maxZoom: 18.0,
                  onMapReady: _updateViewportBounds,
                  onPositionChanged: (position, hasGesture) {
                    if (hasGesture) _updateViewportBounds();
                  },
                  onTap: (_, __) {
                    _searchFocusNode.unfocus();
                    final currentState = context.read<MapBloc>().state;
                    if (currentState.selectedProperty != null) {
                      context.read<MapBloc>().add(MapMarkerSelected(''));
                    }
                  },
                ),
                children: [
                  TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.vibelocals.app'),
                  BlocBuilder<MapBloc, MapState>(
                    buildWhen: (previous, current) =>
                        previous.userLocation != current.userLocation,
                    builder: (context, state) {
                      if (state.userLocation != null) {
                        return MarkerLayer(
                          markers: [
                            Marker(
                              point: state.userLocation!,
                              width: 36,
                              height: 36,
                              child: const UserLocationBeacon(),
                            ),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  BlocBuilder<MapBloc, MapState>(
                    buildWhen: (previous, current) =>
                        previous.visibleProperties !=
                            current.visibleProperties ||
                        previous.selectedProperty != current.selectedProperty,
                    builder: (context, state) {
                      return MarkerLayer(
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
                              onTap: () {
                                HapticFeedback.lightImpact();
                                context
                                    .read<MapBloc>()
                                    .add(MapMarkerSelected(property.id));
                              },
                              child: PriceMarker(
                                  price:
                                      '${(property.pricePerNight / 1000000).toStringAsFixed(1)}M',
                                  isActive: isActive),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),

            // 2. CÁC THÀNH PHẦN KHÁC NẰM ĐÈ LÊN TRÊN (OVERLAYS)
            Positioned.fill(
              child: BlocBuilder<MapBloc, MapState>(
                builder: (context, state) {
                  final isSelected = state.selectedProperty != null;
                  final isSearchActive = state.searchQuery.isNotEmpty;
                  final displayList = isSearchActive
                      ? state.allProperties
                      : state.visibleProperties;

                  return Stack(
                    children: [
                      // 1.5 BACKDROP BLUR KHI TÌM KIẾM
                      Positioned.fill(
                        child: AnimatedBuilder(
                          animation: _searchFocusNode,
                          builder: (context, child) {
                            if (!_searchFocusNode.hasFocus) {
                              return const SizedBox.shrink();
                            }
                            return BackdropFilter(
                              filter:
                                  ui.ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
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
                            filter:
                                ui.ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.70),
                                border: Border(
                                  bottom: BorderSide(
                                      color:
                                          Colors.black.withValues(alpha: 0.05),
                                      width: 1),
                                ),
                              ),
                              child: SafeArea(
                                bottom: false,
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      AppSpacing.md,
                                      AppSpacing.md,
                                      AppSpacing.md,
                                      12),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      FloatingSearchBar(
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
                                                duration: const Duration(
                                                    milliseconds: 250),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 8),
                                                decoration: BoxDecoration(
                                                  color:
                                                      _selectedDateRange != null
                                                          ? null
                                                          : Colors.white,
                                                  gradient: _selectedDateRange !=
                                                          null
                                                      ? const LinearGradient(
                                                          colors: [
                                                            AppColors
                                                                .secondaryContainer,
                                                            AppColors
                                                                .secondaryFixed,
                                                          ],
                                                          begin:
                                                              Alignment.topLeft,
                                                          end: Alignment
                                                              .bottomRight,
                                                        )
                                                      : null,
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  border: Border.all(
                                                    color: _selectedDateRange !=
                                                            null
                                                        ? AppColors.secondary
                                                            .withValues(
                                                                alpha: 0.6)
                                                        : Colors.transparent,
                                                    width: 1,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color:
                                                          _selectedDateRange !=
                                                                  null
                                                              ? AppColors
                                                                  .secondary
                                                                  .withValues(
                                                                      alpha:
                                                                          0.20)
                                                              : Colors.black
                                                                  .withValues(
                                                                      alpha:
                                                                          0.08),
                                                      blurRadius:
                                                          _selectedDateRange !=
                                                                  null
                                                              ? 12
                                                              : 8,
                                                      offset:
                                                          const Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    AnimatedSwitcher(
                                                      duration: const Duration(
                                                          milliseconds: 200),
                                                      child: Icon(
                                                        _selectedDateRange != null
                                                            ? Icons
                                                                .calendar_today
                                                            : Icons
                                                                .calendar_month,
                                                        key: ValueKey(
                                                            _selectedDateRange !=
                                                                null),
                                                        size: 16,
                                                        color: _selectedDateRange !=
                                                                null
                                                            ? AppColors
                                                                .onSecondaryContainer
                                                            : Colors
                                                                .grey.shade700,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      _selectedDateRange == null
                                                          ? 'Chọn ngày dự kiến'
                                                          : '${_selectedDateRange!.start.day}/${_selectedDateRange!.start.month} - ${_selectedDateRange!.end.day}/${_selectedDateRange!.end.month}',
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: _selectedDateRange !=
                                                                null
                                                            ? AppColors
                                                                .onSecondaryContainer
                                                            : AppColors
                                                                .onSurface,
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
                                                                    alpha:
                                                                        0.7)),
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
                                                  _animatedMapMove(state.userLocation!, 15.5);
                                                }
                                              },
                                            ),
                                            ...[
                                              {'icon': Icons.pool, 'label': 'Hồ bơi', 'name': 'Hồ bơi'},
                                              {'icon': Icons.wifi, 'label': 'Wifi', 'name': 'Wifi'},
                                              {'icon': Icons.kitchen, 'label': 'Bếp', 'name': 'Bếp'},
                                              {'icon': Icons.pets, 'label': 'Thú cưng', 'name': 'Cho phép thú cưng'},
                                              {'icon': Icons.ac_unit, 'label': 'Máy lạnh', 'name': 'Máy lạnh'},
                                              {'icon': Icons.local_parking, 'label': 'Đậu xe', 'name': 'Chỗ đậu xe'},
                                              {'icon': Icons.local_laundry_service, 'label': 'Máy giặt', 'name': 'Máy giặt'},
                                            ].map((amenity) {
                                              final name = amenity['name'] as String;
                                              return Padding(
                                                padding: const EdgeInsets.only(left: 8),
                                                child: _buildQuickFilterChip(
                                                  icon: amenity['icon'] as IconData,
                                                  label: amenity['label'] as String,
                                                  isActive: state.selectedAmenities.contains(name),
                                                  onTap: () {
                                                    HapticFeedback.selectionClick();
                                                    final current = context.read<MapBloc>().state;
                                                    final amens = List<String>.from(current.selectedAmenities);
                                                    amens.contains(name) ? amens.remove(name) : amens.add(name);
                                                    context.read<MapBloc>().add(MapFilterApplied(
                                                      minPrice: current.minPrice,
                                                      maxPrice: current.maxPrice,
                                                      minRating: current.minRating,
                                                      selectedAmenities: amens,
                                                    ));
                                              },
                                                ),
                                              );
                                            }),
                                            const SizedBox(width: 8),
                                            _buildQuickFilterChip(
                                              icon: Icons.pets,
                                              label: 'Thú cưng',
                                              isActive: state.selectedAmenities
                                                  .contains('Thú cưng'),
                                              onTap: () {
                                                HapticFeedback.selectionClick();
                                                final current = context
                                                    .read<MapBloc>()
                                                    .state;
                                                final amens = List<String>.from(
                                                    current.selectedAmenities);
                                                amens.contains('Thú cưng')
                                                    ? amens.remove('Thú cưng')
                                                    : amens.add('Thú cưng');
                                                context.read<MapBloc>().add(
                                                    MapFilterApplied(
                                                        minPrice:
                                                            current.minPrice,
                                                        maxPrice:
                                                            current.maxPrice,
                                                        minRating:
                                                            current.minRating,
                                                        selectedAmenities:
                                                            amens));
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
                      ValueListenableBuilder<double>(
                        valueListenable: _sheetExtentNotifier,
                        builder: (context, extent, child) {
                          final isNearTop = extent >= (maxListSize - 0.05);
                          return Positioned(
                            right: 16,
                            bottom:
                                MediaQuery.of(context).size.height * extent +
                                    16,
                            child: IgnorePointer(
                              ignoring: isNearTop,
                              child: AnimatedOpacity(
                                opacity: isNearTop ? 0.0 : 1.0,
                                duration: const Duration(milliseconds: 200),
                                child: child!,
                              ),
                            ),
                          );
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  )
                                ],
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  if (state.userLocation != null) {
                                    _animatedMapMove(state.userLocation!, 15.5);
                                  } else {
                                    _requestAndGetUserLocation();
                                  }
                                },
                                child: const Icon(Icons.my_location,
                                    color: Colors.black87, size: 22),
                              ),
                            ),
                            const SizedBox(height: 8),
                            // ZOOM IN/OUT
                            Container(
                              width: 40,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  )
                                ],
                              ),
                              child: Column(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      final currentZoom =
                                          _mapController.camera.zoom;
                                      _animatedMapMove(
                                          _mapController.camera.center,
                                          currentZoom + 1);
                                    },
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(12)),
                                    child: const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 8),
                                      child: Icon(Icons.add,
                                          color: Colors.black54, size: 24),
                                    ),
                                  ),
                                  Container(
                                      width: 24,
                                      height: 1,
                                      color: Colors.grey.shade300),
                                  InkWell(
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      final currentZoom =
                                          _mapController.camera.zoom;
                                      _animatedMapMove(
                                          _mapController.camera.center,
                                          currentZoom - 1);
                                    },
                                    borderRadius: const BorderRadius.vertical(
                                        bottom: Radius.circular(12)),
                                    child: const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 8),
                                      child: Icon(Icons.remove,
                                          color: Colors.black54, size: 24),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 8),
                            // SCALE BAR
                            MapScaleBar(mapController: _mapController),
                          ],
                        ),
                      ),

                      // 3. CONTAINER TẤM TRƯỢT THÍCH ỨNG CHẾ ĐỘ HIỂN THỊ ĐỘC QUYỀN
                      Positioned.fill(
                        child: NotificationListener<
                            DraggableScrollableNotification>(
                          onNotification: (notification) {
                            final prev = _sheetExtentNotifier.value;
                            _sheetExtentNotifier.value = notification.extent;
                            // Cải tiến: Chỉ giải ghim khi người dùng thực sự kéo XUỐNG qua mốc 0.18
                            if (isSelected &&
                                prev > 0.18 &&
                                notification.extent <= 0.18) {
                              context
                                  .read<MapBloc>()
                                  .add(MapMarkerSelected(''));
                            }
                            return true;
                          },
                          child: DraggableScrollableSheet(
                            controller: _sheetController,
                            // Cải tiến: Mốc chiều cao 0.35 để ôm trọn vẹn card, khi unselect sẽ về sát đáy 0.10
                            initialChildSize: isSelected ? 0.35 : 0.10,
                            minChildSize: 0.10,
                            maxChildSize: isSelected ? 0.35 : maxListSize,
                            snap: true,
                            snapSizes: isSelected
                                ? const [0.10, 0.35]
                                : [0.10, 0.35, maxListSize],
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
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          if (!isSelected) ...[
                                            Text(
                                              'Tìm thấy ${displayList.length} chỗ ở trong vùng này',
                                              style: AppTextStyles.labelLg
                                                  .copyWith(
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
                                        child: PropertyPreviewCard(
                                          property: state.selectedProperty!,
                                          distance: _calculateDistance(
                                            LatLng(
                                                state
                                                    .selectedProperty!.latitude,
                                                state.selectedProperty!
                                                    .longitude),
                                            state.userLocation,
                                          ),
                                          actionButton: ElevatedButton.icon(
                                            onPressed: () =>
                                                _launchGoogleMapsNavigation(
                                                    state.selectedProperty!
                                                        .latitude,
                                                    state.selectedProperty!
                                                        .longitude),
                                            icon: const Icon(Icons.directions,
                                                color: Colors.white, size: 16),
                                            label: const Text('Dẫn đường',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13)),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  AppColors.tertiary,
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8)),
                                              minimumSize: const Size(105, 38),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10),
                                            ),
                                          ),
                                          secondaryActionButton: OutlinedButton(
                                            onPressed: () =>
                                                Navigator.of(context).pushNamed(
                                                    '/property-detail',
                                                    arguments:
                                                        state.selectedProperty),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor:
                                                  AppColors.primary,
                                              side: const BorderSide(
                                                  color: AppColors.primary),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8)),
                                              minimumSize: const Size(85, 38),
                                              padding:
                                                  const EdgeInsets.symmetric(
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
                                    Widget itemContent;
                                    if (state.status == MapStatus.loading) {
                                      // Trả về từng Skeleton Item
                                      itemContent = Padding(
                                        padding: const EdgeInsets.only(
                                            bottom: AppSpacing.md,
                                            left: AppSpacing.md,
                                            right: AppSpacing.md),
                                        child: TweenAnimationBuilder<double>(
                                          tween: Tween(begin: 0.0, end: 1.0),
                                          duration: const Duration(
                                              milliseconds: 1000),
                                          curve: Curves.easeInOutSine,
                                          builder: (context, value, child) {
                                            final opacity =
                                                (math.sin(value * 3.14)).abs() *
                                                        0.5 +
                                                    0.5;
                                            return Opacity(
                                                opacity: opacity, child: child);
                                          },
                                          child: Container(
                                            height: 280,
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade200,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                          ),
                                        ),
                                      );
                                    } else {
                                      // Trả về từng Property Item
                                      final property = displayList[index - 1];
                                      itemContent = Padding(
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
                                                offset:
                                                    Offset(0, 40 * (1 - value)),
                                                child: child,
                                              ),
                                            );
                                          },
                                          child: Material(
                                            color: Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            child: InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              splashColor: AppColors
                                                  .primaryFixed
                                                  .withValues(alpha: 0.3),
                                              onTap: () => context
                                                  .read<MapBloc>()
                                                  .add(MapMarkerSelected(
                                                      property.id)),
                                              child: PropertyPreviewCard(
                                                property: property,
                                                distance: _calculateDistance(
                                                  LatLng(property.latitude,
                                                      property.longitude),
                                                  state.userLocation,
                                                ),
                                                actionButton: OutlinedButton(
                                                  onPressed: () => Navigator.of(
                                                          context)
                                                      .pushNamed(
                                                          '/property-detail',
                                                          arguments: property),
                                                  style:
                                                      OutlinedButton.styleFrom(
                                                    foregroundColor:
                                                        AppColors.primary,
                                                    side: const BorderSide(
                                                        color:
                                                            AppColors.primary),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8)),
                                                    minimumSize:
                                                        const Size(85, 38),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 10),
                                                  ),
                                                  child: const Text('Chi tiết',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 13)),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }

                                    return ValueListenableBuilder<double>(
                                      valueListenable: _sheetExtentNotifier,
                                      builder: (context, extent, child) {
                                        // Nếu tấm trượt ở mức thấp nhất, ẩn item để tránh lộ ảnh ở mép dưới màn hình
                                        if (extent <= 0.12) {
                                          return const SizedBox.shrink();
                                        }
                                        return child!;
                                      },
                                      child: itemContent,
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      // 4. LAYER THANH Tab ĐIỀU HƯỚNG
                      ValueListenableBuilder<double>(
                        valueListenable: _sheetExtentNotifier,
                        builder: (context, extent, child) {
                          return AnimatedPositioned(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOutCubic,
                            bottom: (extent < 0.16 || isSelected) ? -110 : 0,
                            left: 0,
                            right: 0,
                            child: child!,
                          );
                        },
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
          ],
        ),
      ),
    );
  }
}

