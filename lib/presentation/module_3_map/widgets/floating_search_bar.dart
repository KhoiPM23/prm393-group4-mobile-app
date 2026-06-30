import 'dart:async';
import '../../../../core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/map_bloc.dart';
import '../bloc/map_state.dart';
import '../bloc/map_event.dart';
import 'map_filter_bottom_sheet.dart';

class FloatingSearchBar extends StatefulWidget {
  final VoidCallback? onBackTap;
  final FocusNode focusNode;
  const FloatingSearchBar({super.key, this.onBackTap, required this.focusNode});

  @override
  State<FloatingSearchBar> createState() => FloatingSearchBarState();
}

class FloatingSearchBarState extends State<FloatingSearchBar> {
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
    final initialQuery = context.read<MapBloc>().state.searchQuery;
    _searchController = TextEditingController(
        text: (initialQuery == 'Khu vực bản đồ' || initialQuery == 'Mọi nơi') 
            ? '' 
            : initialQuery);
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
        child: const MapFilterModal(),
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

