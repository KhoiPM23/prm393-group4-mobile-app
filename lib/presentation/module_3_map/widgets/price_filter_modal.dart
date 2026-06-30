import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../bloc/map_bloc.dart';
import '../bloc/map_event.dart';
import '../bloc/map_state.dart';

class PriceFilterModal extends StatefulWidget {
  const PriceFilterModal({super.key});

  @override
  State<PriceFilterModal> createState() => _PriceFilterModalState();
}

class _PriceFilterModalState extends State<PriceFilterModal> {
  RangeValues _currentPriceRange = const RangeValues(0, 10000000);
  List<double> _priceHistogram = [];
  final double _maxPossiblePrice = 10000000;
  final int _histogramBins = 60;

  @override
  void initState() {
    super.initState();
    final state = context.read<MapBloc>().state;
    _currentPriceRange = RangeValues(state.minPrice ?? 0, state.maxPrice ?? _maxPossiblePrice);
    _generateHistogramData();
  }

  void _generateHistogramData() {
    final state = context.read<MapBloc>().state;
    final properties = state.allProperties;

    final List<double> smoothedCounts = List.filled(_histogramBins, 0.0);
    double maxCount = 0;

    for (var p in properties) {
      final price = p.pricePerNight;
      int centerBin = ((price / _maxPossiblePrice) * _histogramBins).floor();
      if (centerBin >= _histogramBins) centerBin = _histogramBins - 1;
      if (centerBin < 0) centerBin = 0;

      for (int i = -4; i <= 4; i++) {
        int targetBin = centerBin + i;
        if (targetBin >= 0 && targetBin < _histogramBins) {
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
      _priceHistogram = smoothedCounts.map((c) => (c / maxCount) * 45.0 + 2.0).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentMinStr = _formatCurrency(_currentPriceRange.start);
    final currentMaxStr = _formatCurrency(_currentPriceRange.end) + (_currentPriceRange.end >= _maxPossiblePrice ? '+' : '');

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.black),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => Navigator.pop(context)
                ),
                Text('Giá', style: AppTextStyles.titleLg.copyWith(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
                TextButton(
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _currentPriceRange = RangeValues(0, _maxPossiblePrice);
                    });
                  },
                  child: const Text('Xóa', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Khoảng giá', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                const SizedBox(height: 8),
                Text('Giá đêm trung bình chưa bao gồm phí và thuế', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                const SizedBox(height: 32),
                SizedBox(
                  height: 80,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      // Histogram
                      Positioned(
                        bottom: 24, // Align exactly to the track's vertical center
                        left: 24,
                        right: 24,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: List.generate(_histogramBins, (index) {
                            final binMin = index * (_maxPossiblePrice / _histogramBins);
                            final binMax = (index + 1) * (_maxPossiblePrice / _histogramBins);
                            final isActive = binMax >= _currentPriceRange.start && binMin <= _currentPriceRange.end;

                            return Expanded(
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.symmetric(horizontal: 0.5),
                                height: _priceHistogram[index],
                                decoration: BoxDecoration(
                                  color: isActive ? AppColors.primary : Colors.grey.shade300,
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
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
                            overlayColor: AppColors.primary.withValues(alpha: 0.1),
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 14.0,
                              elevation: 4.0,
                              pressedElevation: 8.0,
                            ),
                            rangeTrackShape: const RoundedRectRangeSliderTrackShape(),
                          ),
                          child: RangeSlider(
                            values: _currentPriceRange,
                            min: 0,
                            max: _maxPossiblePrice,
                            divisions: 200, // 10,000,000 / 50,000 = 200 bước
                            onChanged: (values) {
                              if (_currentPriceRange.start != values.start || _currentPriceRange.end != values.end) {
                                HapticFeedback.selectionClick();
                                setState(() {
                                  _currentPriceRange = values;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Từ $currentMinStr', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
                    Text('Đến $currentMaxStr', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
                  ],
                ),
              ],
            ),
          ),
          
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          
            Padding(
              padding: const EdgeInsets.all(24),
              child: BlocBuilder<MapBloc, MapState>(
                buildWhen: (prev, curr) => prev.allProperties != curr.allProperties,
                builder: (context, state) {
                  final minP = _currentPriceRange.start;
                  final maxP = _currentPriceRange.end;

                  final previewCount = state.allProperties.where((p) {
                    if (p.pricePerNight < minP) return false;
                    if (p.pricePerNight > maxP) return false;
                    return true;
                  }).length;

                  return SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      onPressed: () {
                        final current = context.read<MapBloc>().state;
                        context.read<MapBloc>().add(MapFilterApplied(
                          minPrice: minP,
                          maxPrice: maxP,
                          minRating: current.minRating,
                          selectedAmenities: current.selectedAmenities,
                        ));
                        Navigator.pop(context);
                      },
                      child: Text('Hiển thị $previewCount chỗ ở', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  );
                }
              ),
            ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  String _formatCurrency(double value) {
    if (value == 0) return '0đ';
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1).replaceAll('.0', '')}tr';
    }
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}k';
    }
    return '${value.toStringAsFixed(0)}đ';
  }
}
