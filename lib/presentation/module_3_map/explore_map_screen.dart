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
        if (_cameraAnimController == animationController)
          _cameraAnimController = null;
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
    final url =
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _onNavTap(int index) {
    setState(() => _currentNavIndex = index);
    if (index == 0) Navigator.of(context).pushReplacementNamed('/home');
    if (index == 2 || index == 3)
      Navigator.of(context).pushReplacementNamed('/profile');
  }

  void _updateViewportBounds() {
    final bounds = _mapController.camera.visibleBounds;
    context.read<MapBloc>().add(MapViewportChanged(
        minLat: bounds.southWest.latitude,
        maxLat: bounds.northEast.latitude,
        minLng: bounds.southWest.longitude,
        maxLng: bounds.northEast.longitude));
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
            // Khi ghim địa điểm: Hạ sheet xuống tầm thấp cố định (0.35) để lộ bản đồ thông thoáng chuẩn Airbnb
            _sheetController.animateTo(0.35,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _animatedMapMove(
                  LatLng(state.selectedProperty!.latitude,
                      state.selectedProperty!.longitude),
                  15.5);
            });
          } else {
            _sheetController.animateTo(0.25,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic);
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
                        if (isSelected)
                          context.read<MapBloc>().add(MapMarkerSelected(''));
                      },
                    ),
                    children: [
                      TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.vibelocals.app'),

                      // Hiển thị vị trí GPS người dùng dạng chấm xanh radar Airbnb
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
                              child: _PriceMarkerAirbnb(
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

                // 2. LAYER THANH TÌM KIẾM
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: _FloatingSearchBar(
                        focusNode: _searchFocusNode,
                        onBackTap: () {
                          _searchFocusNode.unfocus();
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ),
                ),

                // 3. TẤM TRƯỢT DỌC SẮP XẾP KHUNG HÌNH CHUẨN AIRBNB
                Positioned.fill(
                  child: DraggableScrollableSheet(
                    controller: _sheetController,
                    initialChildSize: 0.25,
                    minChildSize: 0.15,
                    maxChildSize: isSelected
                        ? 0.35
                        : 0.85, // Khóa chiều cao khi ghim phòng, tránh trượt che mất map
                    snap: true,
                    snapSizes: isSelected ? const [0.35] : const [0.25, 0.85],
                    builder: (context, scrollController) {
                      return Container(
                        padding: const EdgeInsets.only(bottom: 75),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(24)),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 20,
                                offset: const Offset(0, -4))
                          ],
                        ),
                        child: CustomScrollView(
                          controller: scrollController,
                          slivers: [
                            SliverToBoxAdapter(
                              child: Column(
                                children: [
                                  const SizedBox(height: 12),
                                  Container(
                                      width: 40,
                                      height: 5,
                                      decoration: BoxDecoration(
                                          color: Colors.grey.shade300,
                                          borderRadius:
                                              BorderRadius.circular(10))),
                                  const SizedBox(height: 12),
                                  if (!isSelected) ...[
                                    Text(
                                        'Tìm thấy ${displayList.length} chỗ ở trong vùng này',
                                        style: AppTextStyles.labelLg.copyWith(
                                            color: AppColors.onSurface,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16)),
                                    const SizedBox(height: AppSpacing.md),
                                  ]
                                ],
                              ),
                            ),
                            if (isSelected)
                              // CHẾ ĐỘ 1: Đã ghim -> Hiện thẻ Airbnb Độc quyền kèm nút Dẫn đường Native Google Maps
                              SliverPadding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md),
                                sliver: SliverToBoxAdapter(
                                  child: _PropertyPreviewCardAirbnb(
                                    property: state.selectedProperty!,
                                    distance: _calculateDistance(
                                        LatLng(state.selectedProperty!.latitude,
                                            state.selectedProperty!.longitude),
                                        state.userLocation),
                                    actionButton: ElevatedButton.icon(
                                      onPressed: () =>
                                          _launchGoogleMapsNavigation(
                                              state.selectedProperty!.latitude,
                                              state
                                                  .selectedProperty!.longitude),
                                      icon: const Icon(Icons.directions,
                                          color: Colors.white, size: 18),
                                      label: const Text('Dẫn đường',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14)),
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.tertiary,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                          minimumSize: const Size(110, 40)),
                                    ),
                                  ),
                                ),
                              )
                            else
                              // CHẾ ĐỘ 2: Chưa ghim -> Hiện danh sách cuộn dọc Airbnb toàn diện ảnh lớn xếp tầng
                              SliverPadding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md),
                                sliver: SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                      final property = displayList[index];
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                            bottom: AppSpacing.md),
                                        child: GestureDetector(
                                          onTap: () => context
                                              .read<MapBloc>()
                                              .add(MapMarkerSelected(
                                                  property.id)),
                                          child: _PropertyPreviewCardAirbnb(
                                            property: property,
                                            distance: _calculateDistance(
                                                LatLng(property.latitude,
                                                    property.longitude),
                                                state.userLocation),
                                            actionButton: OutlinedButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pushNamed(
                                                          '/property-detail',
                                                          arguments: property),
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
                                                      const Size(100, 40)),
                                              child: const Text('Chi tiết',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    childCount: displayList.length,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // 5. LAYER BOTTOM NAVIGATION BAR
                Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: VibeBottomNavBar(
                        currentIndex: _currentNavIndex, onTap: _onNavTap)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PriceMarkerAirbnb extends StatelessWidget {
  final String price;
  final bool isActive;
  const _PriceMarkerAirbnb({required this.price, required this.isActive});

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
        child: Text(price,
            style: TextStyle(
                color: isActive ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 13)),
      ),
    );
  }
}

class _PropertyPreviewCardAirbnb extends StatelessWidget {
  final PropertyEntity property;
  final String distance;
  final Widget actionButton;

  const _PropertyPreviewCardAirbnb(
      {required this.property,
      required this.distance,
      required this.actionButton});

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
            child: SizedBox(
              width: double.infinity,
              height: 155,
              child: property.imageUrls.isNotEmpty
                  ? Image.network(property.imageUrls.first,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey.shade100,
                          child: const Icon(Icons.villa, color: Colors.grey)))
                  : Container(
                      color: Colors.grey.shade100,
                      child: const Icon(Icons.villa, color: Colors.grey)),
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
                    RichText(
                      text: TextSpan(children: [
                        TextSpan(
                            text:
                                '${property.pricePerNight.toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (m) => "${m[1]}.")}đ',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 15)),
                        TextSpan(
                            text: ' /đêm',
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 13)),
                      ]),
                    ),
                    actionButton,
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
      if (widget.focusNode.hasFocus)
        _showSearchOverlay();
      else
        _hideSearchOverlay();
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
                  if (_debounceTimer?.isActive ?? false)
                    _debounceTimer!.cancel();
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
                onPressed: () {},
                icon: const Icon(Icons.tune, color: Colors.black)),
          ],
        ),
      ),
    );
  }
}
