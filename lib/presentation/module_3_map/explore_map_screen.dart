import 'dart:async';

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
    final url = 'google.navigation:q=$lat,$lng';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      final webUrl =
          'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
      await launchUrl(Uri.parse(webUrl), mode: LaunchMode.externalApplication);
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
      body: BlocListener<MapBloc, MapState>(
        listenWhen: (previous, current) =>
            previous.selectedProperty != current.selectedProperty,
        listener: (context, state) {
          if (state.selectedProperty != null) {
            // FIX TRIỆT ĐỂ: Bọc animateTo vào addPostFrameCallback để ép hệ thống đợi bản đồ ổn định layout rồi mới phóng cao tấm trượt, giải quyết lỗi kẹt ở vị trí thấp
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _sheetController.animateTo(
                  0.55, // Nâng sải không gian lên mốc 0.55 để lộ hoàn toàn phần thành tiền
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic);

              _animatedMapMove(
                  LatLng(state.selectedProperty!.latitude,
                      state.selectedProperty!.longitude),
                  15.5);
            });
          } else {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _sheetController.animateTo(0.45,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic);
            });
          }
        },
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
                              width: 24,
                              height: 24,
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.blue.withValues(alpha: 0.25),
                                    shape: BoxShape.circle),
                                child: Center(
                                  child: Container(
                                    width: 14,
                                    height: 14,
                                    decoration: BoxDecoration(
                                        color: Colors.blue,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: Colors.white, width: 2)),
                                  ),
                                ),
                              ),
                            )
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

                // 2. THANH KIỂM SOÁT TÌM KIẾM & CHỌN NGÀY
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
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
                          GestureDetector(
                            onTap: _pickDateRange,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.08),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2))
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.calendar_month,
                                      size: 16, color: Colors.grey.shade700),
                                  const SizedBox(width: 8),
                                  Text(
                                    _selectedDateRange == null
                                        ? 'Chọn ngày dự kiến'
                                        : '${_selectedDateRange!.start.day}/${_selectedDateRange!.start.month} - ${_selectedDateRange!.end.day}/${_selectedDateRange!.end.month}',
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF333333)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

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
                      // CHÍNH XÁC: Ánh xạ mốc chiều cao 0.55 đồng bộ vào cấu hình hệ thống tấm nền trượt
                      initialChildSize: isSelected ? 0.55 : 0.45,
                      minChildSize: isSelected ? 0.10 : 0.08,
                      maxChildSize: isSelected ? 0.55 : 0.95,
                      snap: true,
                      snapSizes: isSelected
                          ? const [
                              0.10,
                              0.55
                            ] // Khóa cứng mốc 0.55 cao ráo hiển thị siêu đẹp, không lo bị lấp giá tiền
                          : const [0.08, 0.45, 0.95],
                      builder: (context, scrollController) {
                        return Container(
                          margin: isSelected
                              ? const EdgeInsets.symmetric(horizontal: 16)
                              : EdgeInsets.zero,
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
                          child: isSelected
                              ? Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.15),
                                          blurRadius: 16,
                                          offset: const Offset(0, 4))
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                          width: 40,
                                          height: 5,
                                          decoration: BoxDecoration(
                                              color: Colors.grey.shade300,
                                              borderRadius:
                                                  BorderRadius.circular(10))),
                                      const SizedBox(height: 16),
                                      Expanded(
                                        child: ListView(
                                          controller: scrollController,
                                          padding: EdgeInsets.zero,
                                          physics:
                                              const ClampingScrollPhysics(),
                                          children: [
                                            _PropertyPreviewCard(
                                              property: state.selectedProperty!,
                                              distance: _calculateDistance(
                                                  LatLng(
                                                      state.selectedProperty!
                                                          .latitude,
                                                      state.selectedProperty!
                                                          .longitude),
                                                  state.userLocation),
                                              // Cấu hình cặp nút đôi cân đối chống tràn viền
                                              actionButton: ElevatedButton.icon(
                                                onPressed: () =>
                                                    _launchGoogleMapsNavigation(
                                                        state.selectedProperty!
                                                            .latitude,
                                                        state.selectedProperty!
                                                            .longitude),
                                                icon: const Icon(
                                                    Icons.directions,
                                                    color: Colors.white,
                                                    size: 16),
                                                label: const Text('Dẫn đường',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 13)),
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor: AppColors
                                                        .tertiary,
                                                    foregroundColor: Colors
                                                        .white,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8)),
                                                    minimumSize:
                                                        const Size(105, 38),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 10)),
                                              ),
                                              secondaryActionButton:
                                                  OutlinedButton(
                                                onPressed: () =>
                                                    Navigator.of(context)
                                                        .pushNamed(
                                                  '/property-detail',
                                                  arguments:
                                                      state.selectedProperty,
                                                ),
                                                style: OutlinedButton.styleFrom(
                                                  foregroundColor:
                                                      AppColors.primary,
                                                  side: const BorderSide(
                                                      color: AppColors.primary),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
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
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Container(
                                  color: Colors.white,
                                  child: Column(
                                    children: [
                                      GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onVerticalDragUpdate: (details) {
                                          if (_sheetController.isAttached) {
                                            final double delta =
                                                details.primaryDelta! /
                                                    MediaQuery.of(context)
                                                        .size
                                                        .height;
                                            final double newSize =
                                                (_sheetController.size - delta)
                                                    .clamp(0.08, 0.95);
                                            _sheetController.jumpTo(newSize);
                                          }
                                        },
                                        onVerticalDragEnd: (details) {
                                          if (_sheetController.isAttached) {
                                            final List<double> snaps = [
                                              0.08,
                                              0.45,
                                              0.95
                                            ];
                                            final double currentSize =
                                                _sheetController.size;
                                            double closestSnap = snaps.first;
                                            double minDelta =
                                                (currentSize - closestSnap)
                                                    .abs();
                                            for (final snap in snaps) {
                                              final d =
                                                  (currentSize - snap).abs();
                                              if (d < minDelta) {
                                                minDelta = d;
                                                closestSnap = snap;
                                              }
                                            }
                                            _sheetController.animateTo(
                                                closestSnap,
                                                duration: const Duration(
                                                    milliseconds: 150),
                                                curve: Curves.easeOutCubic);
                                          }
                                        },
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const SizedBox(height: 12),
                                            Container(
                                                width: 40,
                                                height: 5,
                                                decoration: BoxDecoration(
                                                    color: Colors.grey.shade300,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10))),
                                            const SizedBox(height: 12),
                                            Text(
                                                'Tìm thấy ${displayList.length} chỗ ở trong vùng này',
                                                style: AppTextStyles.labelLg
                                                    .copyWith(
                                                        color:
                                                            AppColors.onSurface,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 15)),
                                            const SizedBox(height: 12),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: ListView.builder(
                                          controller: scrollController,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: AppSpacing.md),
                                          itemCount: displayList.length,
                                          itemBuilder: (context, index) {
                                            final property = displayList[index];
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: AppSpacing.md),
                                              child: GestureDetector(
                                                onTap: () => context
                                                    .read<MapBloc>()
                                                    .add(MapMarkerSelected(
                                                        property.id)),
                                                child: _PropertyPreviewCard(
                                                  property: property,
                                                  distance: _calculateDistance(
                                                      LatLng(property.latitude,
                                                          property.longitude),
                                                      state.userLocation),
                                                  actionButton: OutlinedButton(
                                                    onPressed: () => Navigator
                                                            .of(context)
                                                        .pushNamed(
                                                            '/property-detail',
                                                            arguments:
                                                                property),
                                                    style: OutlinedButton.styleFrom(
                                                        foregroundColor:
                                                            AppColors.primary,
                                                        side: const BorderSide(
                                                            color: AppColors
                                                                .primary),
                                                        shape:
                                                            RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8)),
                                                        minimumSize: const Size(
                                                            100, 38)),
                                                    child: const Text(
                                                        'Chi tiết',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
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

class _PriceMarker extends StatelessWidget {
  final String price;
  final bool isActive;
  const _PriceMarker({required this.price, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? Colors.black : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border:
            isActive ? null : Border.all(color: Colors.grey.shade300, width: 1),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 6,
              offset: const Offset(0, 3))
        ],
      ),
      child: Center(
        child: Text(
          price,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: isActive ? 14 : 13,
          ),
        ),
      ),
    );
  }
}

class _PropertyPreviewCard extends StatelessWidget {
  final PropertyEntity property;
  final String distance;
  final Widget actionButton;
  final Widget? secondaryActionButton; // Thuộc tính bổ sung nút phụ

  const _PropertyPreviewCard(
      {required this.property,
      required this.distance,
      required this.actionButton,
      this.secondaryActionButton});

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
                SizedBox(
                  width: double.infinity,
                  height: 145,
                  child: property.imageUrls.isNotEmpty
                      ? Image.network(property.imageUrls.first,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey.shade100,
                              child:
                                  const Icon(Icons.villa, color: Colors.grey)))
                      : Container(
                          color: Colors.grey.shade100,
                          child: const Icon(Icons.villa, color: Colors.grey)),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: _FavoriteButton(propertyId: property.id),
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
                        child: Text(property.title,
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
                      Text(property.rating.toString(),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Colors.black))
                    ]),
                  ],
                ),
                const SizedBox(height: 2),
                Text('${property.district}, Đà Nẵng • Cách $distance',
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
                                  'Từ ${(property.pricePerNight).toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (m) => "${m[1]}.")}đ',
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
                        if (secondaryActionButton != null) ...[
                          secondaryActionButton!,
                          const SizedBox(width: 6),
                        ],
                        actionButton,
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

  static final List<String> _searchHistory = [
    'Khách sạn Sơn Trà',
    'Homestay Hải Châu'
  ];

  @override
  void initState() {
    super.initState();
    _searchController =
        TextEditingController(text: context.read<MapBloc>().state.searchQuery);
    widget.focusNode.addListener(() {
      if (widget.focusNode.hasFocus) {
        _showSearchOverlay();
      } else {
        _hideSearchOverlay();
      }
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
                  onPointerDown: (_) => widget.focusNode.unfocus())),
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
    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2))
            ]),
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
                      _localAmenities.clear();
                    });
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
              builder: (context, state) {
                final minP = _currentPriceRange.start;
                final maxP = _currentPriceRange.end;

                final previewCount = state.allProperties.where((p) {
                  if (p.pricePerNight < minP) return false;
                  if (p.pricePerNight > maxP) return false;
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

class _FavoriteButton extends StatefulWidget {
  final String propertyId;
  const _FavoriteButton({required this.propertyId});

  @override
  State<_FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<_FavoriteButton> {
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isFavorite = !_isFavorite;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 4,
                offset: const Offset(0, 2))
          ],
        ),
        child: Icon(
          _isFavorite ? Icons.favorite : Icons.favorite_border,
          color: _isFavorite ? Colors.red : Colors.black,
          size: 18,
        ),
      ),
    );
  }
}
