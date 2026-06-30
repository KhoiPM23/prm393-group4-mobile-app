import 'dart:math' as math;
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/map_bloc.dart';
import '../bloc/map_state.dart';
import '../bloc/map_event.dart';

class MapFilterModal extends StatefulWidget {
  const MapFilterModal({super.key});

  @override
  State<MapFilterModal> createState() => MapFilterModalState();
}

class MapFilterModalState extends State<MapFilterModal> {
  RangeValues _currentPriceRange = const RangeValues(0, 10000000);
  double? _localMinRating;
  List<String> _localAmenities = [];

  List<double> _priceHistogram = [];
  final double _maxPossiblePrice = 10000000;
  final int _histogramBins = 60; // Smooth like Airbnb

  bool _showAllAmenities = false;
  final Map<String, List<Map<String, dynamic>>> _amenityCategories = {
    'Phổ biến': [
      {'name': 'Wifi', 'icon': Icons.wifi},
      {'name': 'Máy lạnh', 'icon': Icons.ac_unit},
      {'name': 'Chỗ đậu xe', 'icon': Icons.local_parking},
      {'name': 'Bếp', 'icon': Icons.kitchen},
      {'name': 'Hồ bơi', 'icon': Icons.pool},
      {'name': 'Cho phép thú cưng', 'icon': Icons.pets},
    ],
    'Thiết yếu': [
      {'name': 'Máy giặt', 'icon': Icons.local_laundry_service},
      {'name': 'Máy sấy tóc', 'icon': Icons.air},
      {'name': 'Lò sưởi', 'icon': Icons.hvac},
      {'name': 'Bàn làm việc', 'icon': Icons.desk},
      {'name': 'Bàn ủi', 'icon': Icons.iron},
    ],
    'Nổi bật': [
      {'name': 'Khu BBQ', 'icon': Icons.outdoor_grill},
      {'name': 'Bồn tắm', 'icon': Icons.bathtub},
      {'name': 'Gym', 'icon': Icons.fitness_center},
      {'name': 'Ăn sáng', 'icon': Icons.restaurant},
      {'name': 'Lò sưởi trong nhà', 'icon': Icons.fireplace},
      {'name': 'View biển', 'icon': Icons.water},
      {'name': 'Ban công', 'icon': Icons.balcony},
    ],
    'An toàn': [
      {'name': 'Báo khói', 'icon': Icons.sensors},
      {'name': 'Báo khí CO', 'icon': Icons.co2},
    ]
  };

  @override
  void initState() {
    super.initState();
    final state = context.read<MapBloc>().state;
    _currentPriceRange =
        RangeValues(state.minPrice ?? 0, state.maxPrice ?? _maxPossiblePrice);
    _localMinRating = state.minRating;
    _localAmenities = List.from(state.selectedAmenities);
    _generateHistogramData();
  }

  void _generateHistogramData() {
    final state = context.read<MapBloc>().state;
    final properties = state.allProperties;

    final List<double> smoothedCounts = List.filled(_histogramBins, 0.0);
    double maxCount = 0;

    // Áp dụng Kernel Density (Gaussian Smoothing) để làm mượt biểu đồ dù ít data
    for (var p in properties) {
      final price = p.pricePerNight;
      int centerBin = ((price / _maxPossiblePrice) * _histogramBins).floor();
      if (centerBin >= _histogramBins) centerBin = _histogramBins - 1;
      if (centerBin < 0) centerBin = 0;

      // Lan toả giá trị sang các cột xung quanh (Tạo đường cong hình chuông)
      for (int i = -4; i <= 4; i++) {
        int targetBin = centerBin + i;
        if (targetBin >= 0 && targetBin < _histogramBins) {
          // Tính trọng số bằng hàm e^(-x^2) đơn giản
          double weight = math.exp(-(i * i) / 4.0);
          smoothedCounts[targetBin] += weight;
        }
      }
    }

    for (var count in smoothedCounts) {
      if (count > maxCount) maxCount = count;
    }

    if (maxCount == 0) {
      _priceHistogram = List.filled(_histogramBins, 2.0);
    } else {
      // Create a smooth visual representation (min height 2.0px so empty bins still show slightly)
      _priceHistogram =
          smoothedCounts.map((c) => (c / maxCount) * 45.0 + 2.0).toList();
    }
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
                    HapticFeedback.selectionClick();
                    setState(() {
                      _currentPriceRange = RangeValues(0, _maxPossiblePrice);
                      _localMinRating = null;
                      _localAmenities.clear();
                    });
                    context.read<MapBloc>().add(MapFilterApplied(
                          minPrice: 0,
                          maxPrice: _maxPossiblePrice,
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
                // HISTOGRAM + SLIDER STACK UI (Airbnb Style)
                SizedBox(
                  height: 80,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      // Histogram
                      Positioned(
                        bottom:
                            24, // Align exactly to the track's vertical center
                        left: 24,
                        right: 24,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: List.generate(_histogramBins, (index) {
                            final binMin =
                                index * (_maxPossiblePrice / _histogramBins);
                            final binMax = (index + 1) *
                                (_maxPossiblePrice / _histogramBins);
                            final isActive =
                                binMax >= _currentPriceRange.start &&
                                    binMin <= _currentPriceRange.end;

                            return Expanded(
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 0.5),
                                height: _priceHistogram[index],
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? AppColors.primary
                                      : Colors.grey.shade300,
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(2)),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      // Range Slider
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: AppColors.primary,
                            inactiveTrackColor: Colors.grey.shade300,
                            trackHeight: 2.0,
                            thumbColor: Colors.white,
                            overlayColor:
                                AppColors.primary.withValues(alpha: 0.1),
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 14.0,
                              elevation: 4.0,
                              pressedElevation: 8.0,
                            ),
                            rangeTrackShape:
                                const RoundedRectRangeSliderTrackShape(),
                          ),
                          child: RangeSlider(
                            values: _currentPriceRange,
                            min: 0,
                            max: _maxPossiblePrice,
                            divisions: 200, // 10,000,000 / 50,000 = 200 bước
                            onChanged: (values) {
                              if (_currentPriceRange.start != values.start ||
                                  _currentPriceRange.end != values.end) {
                                HapticFeedback.selectionClick();
                              }
                              setState(() {
                                _currentPriceRange = values;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
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
                              HapticFeedback.selectionClick();
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
                ..._amenityCategories.entries.map((category) {
                  // Chỉ hiển thị "Phổ biến" nếu _showAllAmenities là false
                  if (!_showAllAmenities && category.key != 'Phổ biến') {
                    return const SizedBox.shrink();
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_showAllAmenities) ...[
                        Text(category.key,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87)),
                        const SizedBox(height: 12),
                      ],
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: category.value.map((amenity) {
                          final name = amenity['name'] as String;
                          final icon = amenity['icon'] as IconData;
                          final isSelected = _localAmenities.contains(name);
                          return FilterChip(
                            avatar: Icon(icon,
                                size: 18,
                                color: isSelected ? Colors.white : Colors.black87),
                            label: Text(name),
                            selected: isSelected,
                            selectedColor: Colors.black,
                            checkmarkColor: Colors.transparent, // Disable default checkmark to show our icon
                            showCheckmark: false,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            labelStyle: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                                fontWeight: FontWeight.w500,
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
                              HapticFeedback.selectionClick();
                              setState(() {
                                if (selected) {
                                  _localAmenities.add(name);
                                } else {
                                  _localAmenities.remove(name);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                    ],
                  );
                }),
                if (!_showAllAmenities)
                  InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _showAllAmenities = true);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text('Hiển thị thêm',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  decoration: TextDecoration.underline)),
                          SizedBox(width: 4),
                          Icon(Icons.keyboard_arrow_down, size: 20),
                        ],
                      ),
                    ),
                  )
                else
                  InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _showAllAmenities = false);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text('Thu gọn',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  decoration: TextDecoration.underline)),
                          SizedBox(width: 4),
                          Icon(Icons.keyboard_arrow_up, size: 20),
                        ],
                      ),
                    ),
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

