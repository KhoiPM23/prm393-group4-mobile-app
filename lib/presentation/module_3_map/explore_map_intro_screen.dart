import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class ExploreMapIntroScreen extends StatefulWidget {
  final String? initialCity;
  final DateTimeRange? initialDates;
  const ExploreMapIntroScreen({super.key, this.initialCity, this.initialDates});

  @override
  State<ExploreMapIntroScreen> createState() => _ExploreMapIntroScreenState();
}

class _ExploreMapIntroScreenState extends State<ExploreMapIntroScreen> {
  int _expandedSection = 0; // 0: Địa điểm, 1: Thời gian
  late TextEditingController _searchController;
  final FocusNode _searchFocusNode = FocusNode();

  Timer? _debounce;
  final Dio _dio = Dio();
  bool _isLoadingCities = false;
  bool _isSearchingActive =
      false; // When true, hides the "When" section and expands search to full screen

  // Airbnb style colorful icons and mock cities
  final List<Map<String, dynamic>> _allCities = [
    {
      'name': 'Gần tôi',
      'location': 'Tìm kiếm xung quanh bạn',
      'icon': Icons.navigation,
      'color': Colors.blue.shade600,
      'bg': Colors.blue.shade50
    },
    {
      'name': 'Đà Nẵng',
      'location': 'Việt Nam',
      'icon': Icons.beach_access,
      'color': Colors.teal.shade600,
      'bg': Colors.teal.shade50,
      'lat': 16.055,
      'lon': 108.235
    },
    {
      'name': 'Hồ Chí Minh',
      'location': 'Việt Nam',
      'icon': Icons.location_city,
      'color': Colors.indigo.shade600,
      'bg': Colors.indigo.shade50,
      'lat': 10.762,
      'lon': 106.660
    },
    {
      'name': 'Hà Nội',
      'location': 'Việt Nam',
      'icon': Icons.account_balance,
      'color': Colors.pink.shade600,
      'bg': Colors.pink.shade50,
      'lat': 21.028,
      'lon': 105.854
    },
    {
      'name': 'Phú Quốc',
      'location': 'Kiên Giang, Việt Nam',
      'icon': Icons.pool,
      'color': Colors.orange.shade600,
      'bg': Colors.orange.shade50,
      'lat': 10.289,
      'lon': 103.984
    },
    {
      'name': 'Nha Trang',
      'location': 'Khánh Hòa, Việt Nam',
      'icon': Icons.water,
      'color': Colors.lightBlue.shade600,
      'bg': Colors.lightBlue.shade50,
      'lat': 12.238,
      'lon': 109.196
    },
    {
      'name': 'Bangkok',
      'location': 'Thái Lan',
      'icon': Icons.temple_buddhist,
      'color': Colors.green.shade600,
      'bg': Colors.green.shade50,
      'lat': 13.756,
      'lon': 100.501
    },
    {
      'name': 'Paris',
      'location': 'Pháp',
      'icon': Icons.tour,
      'color': Colors.blue.shade800,
      'bg': Colors.blue.shade50,
      'lat': 48.856,
      'lon': 2.352
    },
  ];

  List<Map<String, dynamic>> _suggestedCities = [];
  String? _selectedCity;
  DateTimeRange? _selectedDateRange;
  String? _selectedFlexibleDate;

  final List<String> _flexibleDates = [
    'Cuối tuần này',
    'Tuần sau',
    'Tháng này',
    'Tháng sau'
  ];
  
  static Map<String, dynamic>? _recentSearch;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialCity ?? '');
    _selectedCity = widget.initialCity;
    _selectedDateRange = widget.initialDates;
    _suggestedCities = List.from(_allCities);

    if (_selectedCity != null && _selectedCity!.isNotEmpty) {
      _expandedSection = 1;
    }

    _searchFocusNode.addListener(() {
      setState(() {
        _isSearchingActive = _searchFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  
  Map<String, dynamic> _getCityIconConfig(String cityName) {
    final lower = cityName.toLowerCase();
    if (lower.contains('nẵng') || lower.contains('nha trang') || lower.contains('phú quốc') || lower.contains('vũng tàu') || lower.contains('biển')) {
      return {'icon': Icons.beach_access, 'color': Colors.teal.shade600, 'bg': Colors.teal.shade50};
    } else if (lower.contains('đà lạt') || lower.contains('sapa') || lower.contains('bản') || lower.contains('mộc châu')) {
      return {'icon': Icons.park_rounded, 'color': Colors.green.shade600, 'bg': Colors.green.shade50};
    } else if (lower.contains('hội an') || lower.contains('huế') || lower.contains('ninh bình') || lower.contains('thái lan')) {
      return {'icon': Icons.temple_buddhist, 'color': Colors.orange.shade600, 'bg': Colors.orange.shade50};
    } else if (lower.contains('hồ chí minh') || lower.contains('hà nội') || lower.contains('city') || lower.contains('thành phố')) {
      return {'icon': Icons.location_city, 'color': Colors.indigo.shade600, 'bg': Colors.indigo.shade50};
    }
    return {'icon': Icons.location_on, 'color': Colors.grey.shade700, 'bg': Colors.grey.shade200};
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    if (value.trim().isEmpty) {
      setState(() {
        _suggestedCities = List.from(_allCities);
        _isLoadingCities = false;
      });
      return;
    }

    setState(() {
      _isLoadingCities = true;
    });

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        final response = await _dio.get(
          'https://nominatim.openstreetmap.org/search',
          queryParameters: {
            'q': value,
            'format': 'json',
            'limit': 15, // Increase limit for better results
            'addressdetails': 1,
            'accept-language': 'vi,en'
          },
          options: Options(
            headers: {'User-Agent': 'HotelBookingApp/1.0 Flutter'},
          ),
        );

        if (response.statusCode == 200 && mounted) {
          final data = response.data as List;
          final List<Map<String, dynamic>> results = [];
          for (var item in data) {
            final address = item['address'] ?? {};
            final name = address['city'] ??
                address['town'] ??
                address['village'] ??
                address['county'] ??
                item['name'];
            final stateName = address['state'] ?? '';
            final country = address['country'] ?? '';

            final locationDetails = [stateName, country]
                .where((e) => e.toString().isNotEmpty)
                .join(', ');

            if (name != null) {
              results.add({
                'name': name.toString(),
                'location': locationDetails,
                'lat': double.tryParse(item['lat']?.toString() ?? ''),
                'lon': double.tryParse(item['lon']?.toString() ?? ''),
                ..._getCityIconConfig(name.toString()),
              });
            }
          }

          final uniqueResults = <String, Map<String, dynamic>>{};
          for (var item in results) {
            uniqueResults[item['name']] = item;
          }

          setState(() {
            _suggestedCities = uniqueResults.values.toList();
            _isLoadingCities = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoadingCities = false;
          });
        }
      }
    });
  }

  void _onCitySelected(Map<String, dynamic> cityData) async {
    String city = cityData['name'];
    
    // Nếu là tìm kiếm gần đây (có ngày) thì load và navigate luôn
    if (cityData.containsKey('dates') && cityData['dates'] != null) {
      setState(() {
        _selectedCity = city;
        _selectedDateRange = cityData['dates'];
      });
      _onSearch();
      return;
    }

    if (city == 'Gần tôi') {
      setState(() => _isLoadingCities = true);
      try {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
          final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
          setState(() {
            _selectedCity = 'Gần tôi';
            _searchController.text = 'Gần tôi';
            _searchFocusNode.unfocus();
            _isSearchingActive = false;
            _expandedSection = 1;
            _isLoadingCities = false;
            
            _suggestedCities.removeWhere((e) => e['name'] == 'Gần tôi');
            _suggestedCities.insert(0, {
              'name': 'Gần tôi',
              'location': 'Vị trí của bạn',
              'icon': Icons.navigation,
              'color': Colors.blue.shade600,
              'bg': Colors.blue.shade50,
              'lat': position.latitude,
              'lon': position.longitude,
            });
          });
        } else {
           setState(() => _isLoadingCities = false);
        }
      } catch (e) {
         setState(() => _isLoadingCities = false);
      }
      return;
    }
    setState(() {
      _selectedCity = city;
      _searchController.text = city;
      _searchFocusNode.unfocus();
      _isSearchingActive = false;
      _expandedSection = 1; // Nhảy sang chọn ngày
    });
  }

  void _selectFlexibleDate(String dateStr) {
    final now = DateTime.now();
    DateTime start;
    DateTime end;

    if (dateStr == 'Cuối tuần này') {
      final daysToSaturday = 6 - now.weekday;
      start = now.add(Duration(days: daysToSaturday >= 0 ? daysToSaturday : 6));
      end = start.add(const Duration(days: 1));
    } else if (dateStr == 'Tuần sau') {
      final daysToNextMonday = 8 - now.weekday;
      start = now.add(Duration(days: daysToNextMonday));
      end = start.add(const Duration(days: 6));
    } else if (dateStr == 'Tháng này') {
      start = DateTime(now.year, now.month, 1);
      end = DateTime(now.year, now.month + 1, 0); // Last day of current month
      // if today is past the 1st, start from today so they can actually select it
      if (now.day > 1) {
         start = DateTime(now.year, now.month, now.day);
      }
    } else {
      start = DateTime(now.year, now.month + 1, 1);
      end = DateTime(now.year, now.month + 2, 0);
    }

    setState(() {
      _selectedFlexibleDate = dateStr;
      _selectedDateRange = DateTimeRange(start: start, end: end);
    });
  }

  void _onSearch() {
    // Navigate to map with data
    final lat = _suggestedCities.firstWhere((e) => e['name'] == _selectedCity, orElse: () => {})['lat'];
    final lon = _suggestedCities.firstWhere((e) => e['name'] == _selectedCity, orElse: () => {})['lon'];
    
    _recentSearch = {
      'name': _selectedCity ?? 'Mọi nơi',
      'location': _selectedDateRange != null 
          ? '${_selectedDateRange!.start.day}-${_selectedDateRange!.end.day} Thg ${_selectedDateRange!.start.month}' 
          : 'Bất kỳ lúc nào',
      'icon': Icons.schedule,
      'color': Colors.black87,
      'bg': Colors.grey.shade100,
      'lat': lat,
      'lon': lon,
      'dates': _selectedDateRange,
    };

    Navigator.of(context).pushReplacementNamed(
      '/explore',
      arguments: {
        'city': _selectedCity,
        'dates': _selectedDateRange,
        'lat': lat,
        'lon': lon,
      },
    );
  }

  void _onClearAll() {
    setState(() {
      _selectedCity = null;
      _selectedDateRange = null;
      _selectedFlexibleDate = null;
      _searchController.clear();

      _onSearchChanged('');
      _searchFocusNode.unfocus();
      _isSearchingActive = false;
      _expandedSection = 0;
    });
  }

  Widget _buildWhereExpanded() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            _isSearchingActive ? BorderRadius.zero : BorderRadius.circular(32),
        boxShadow: _isSearchingActive
            ? []
            : [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 12))
              ],
      ),
      child: CustomScrollView(
        shrinkWrap: !_isSearchingActive,
        slivers: [
          // Header
          if (!_isSearchingActive)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 8),
                child: Text(
                  'Bạn muốn đi đâu?',
                  style: AppTextStyles.headlineLg.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ),
            ),

          // Sticky Search Bar
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickySearchBarDelegate(
              child: Padding(
                padding: EdgeInsets.only(
                    top: _isSearchingActive ? 16 : 8,
                    left: 24,
                    right: 24,
                    bottom: 16),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                      color: _isSearchingActive ? Colors.white : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(32),
                      border: _isSearchingActive 
                          ? Border.all(color: Colors.black87, width: 1.5)
                          : null,
                      boxShadow: const []),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.black87, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          onChanged: _onSearchChanged,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                          decoration: InputDecoration(
                            hintText: 'Tìm kiếm điểm đến',
                            hintStyle: TextStyle(
                                color: Colors.grey.shade400,
                                fontWeight: FontWeight.w400),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      if (_searchController.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.close,
                              size: 20, color: Colors.black54),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                        )
                    ],
                  ),
                ),
              ),
            ),
          ),

          if (!_isLoadingCities && _recentSearch != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 8),
                child: Text(
                  'Tìm kiếm gần đây',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ),
            ),
          
          if (!_isLoadingCities && _recentSearch != null)
            SliverToBoxAdapter(
              child: _buildLocationItem(_recentSearch!),
            ),

          if (!_isLoadingCities)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 8),
                child: Text(
                  'Điểm đến gợi ý',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ),
            ),

          // List of cities
          if (_isLoadingCities)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(
                    child: CircularProgressIndicator(color: Colors.black)),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final city = _suggestedCities[index];
                    return _buildLocationItem(city);
                  },
                  childCount: _suggestedCities.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLocationItem(Map<String, dynamic> city) {
    return InkWell(
      onTap: () => _onCitySelected(city),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: city['bg'],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(city['icon'], color: city['color'], size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    city['name'],
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    city['location'],
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWhenExpanded() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, 12))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
            child: Text(
              'Chọn ngày đi và về',
              style: AppTextStyles.headlineLg.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 12,
              itemBuilder: (context, index) {
                DateTime now = DateTime.now();
                DateTime monthDate = DateTime(now.year, now.month + index, 1);
                int daysInMonth =
                    DateTime(monthDate.year, monthDate.month + 1, 0).day;
                int firstDayWeekday = monthDate.weekday; // 1 (Mon) - 7 (Sun)
                if (firstDayWeekday == 7)
                  firstDayWeekday =
                      0; // Chuyển Sun(7) thành 0 để tính toán dễ hơn

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        'Tháng ${monthDate.month} ${monthDate.year}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children:
                          ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'].map((d) {
                        return Expanded(
                          child: Center(
                            child: Text(
                              d,
                              style: const TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        childAspectRatio: 1,
                      ),
                      itemCount: daysInMonth + firstDayWeekday,
                      itemBuilder: (context, gridIndex) {
                        if (gridIndex < firstDayWeekday)
                          return const SizedBox.shrink();

                        int day = gridIndex - firstDayWeekday + 1;
                        DateTime currentDate =
                            DateTime(monthDate.year, monthDate.month, day);
                        bool isPast = currentDate
                            .isBefore(DateTime(now.year, now.month, now.day));

                        bool isSelected = false;
                        bool isStart = false;
                        bool isEnd = false;
                        bool isInRange = false;

                        if (_selectedDateRange != null) {
                          final start = _selectedDateRange!.start;
                          final end = _selectedDateRange!.end;
                          if (currentDate.year == start.year &&
                              currentDate.month == start.month &&
                              currentDate.day == start.day) {
                            isSelected = true;
                            isStart = true;
                          }
                          if (currentDate.year == end.year &&
                              currentDate.month == end.month &&
                              currentDate.day == end.day) {
                            isSelected = true;
                            isEnd = true;
                          }
                          if (currentDate.isAfter(start) &&
                              currentDate.isBefore(end)) {
                            isInRange = true;
                          }
                        }

                        return GestureDetector(
                          onTap: isPast
                              ? null
                              : () {
                                  setState(() {
                                    if (_selectedDateRange == null) {
                                      _selectedDateRange = DateTimeRange(start: currentDate, end: currentDate);
                                    } else if (_selectedDateRange!.start == _selectedDateRange!.end) {
                                      if (currentDate.isBefore(_selectedDateRange!.start)) {
                                        _selectedDateRange = DateTimeRange(start: currentDate, end: _selectedDateRange!.end);
                                      } else {
                                        _selectedDateRange = DateTimeRange(start: _selectedDateRange!.start, end: currentDate);
                                      }
                                    } else {
                                      _selectedDateRange = DateTimeRange(start: currentDate, end: currentDate);
                                    }
                                    _selectedFlexibleDate = null;
                                  });
                                },
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 2), // Keep vertical margin to separate weeks slightly
                            child: Stack(
                              children: [
                                // Range background
                                if (isSelected && !isStart && !isEnd)
                                  Container(color: Colors.grey.shade200),
                                if (isSelected && isStart && !isEnd)
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    bottom: 0,
                                    width: MediaQuery.of(context).size.width / 14, // Roughly half cell width
                                    child: Container(color: Colors.grey.shade200),
                                  ),
                                if (isSelected && isEnd && !isStart)
                                  Positioned(
                                    left: 0,
                                    top: 0,
                                    bottom: 0,
                                    width: MediaQuery.of(context).size.width / 14,
                                    child: Container(color: Colors.grey.shade200),
                                  ),
                                if (isInRange)
                                  Container(color: Colors.grey.shade200),
                                // Circle for selected
                                Center(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isSelected ? Colors.black : Colors.transparent,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '$day',
                                        style: TextStyle(
                                          color: isPast
                                              ? Colors.grey.shade300
                                              : (isSelected ? Colors.white : Colors.black87),
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade100)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _flexibleDates.map((date) {
                    final isSelected = _selectedFlexibleDate == date;
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () {
                          if (isSelected) {
                            setState(() {
                              _selectedFlexibleDate = null;
                              _selectedDateRange = null;
                            });
                          } else {
                            _selectFlexibleDate(date);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.black : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: isSelected
                                    ? Colors.black
                                    : Colors.grey.shade300,
                                width: 1.5),
                          ),
                          child: Text(
                            date,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight:
                                  isSelected ? FontWeight.bold : FontWeight.w600,
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsedCard(
      {required String title,
      required String value,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isSearchingActive,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _isSearchingActive) {
          setState(() {
            _isSearchingActive = false;
            _searchFocusNode.unfocus();
          });
        }
      },
      child: Scaffold(
        backgroundColor:
            _isSearchingActive ? Colors.white : const Color(0xFFF7F7F7),
        body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            if (!_isSearchingActive)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: Colors.black12, blurRadius: 4)
                              ]),
                          child: const Icon(Icons.arrow_back,
                              color: Colors.black, size: 18)),
                      onPressed: () {
                        if (_isSearchingActive) {
                          setState(() {
                            _isSearchingActive = false;
                            _searchFocusNode.unfocus();
                          });
                        } else {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                    const SizedBox(), // Removed right 'Xóa tất cả'
                  ],
                ),
              ),

            // Main Content
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: _isSearchingActive ? 0 : 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_expandedSection == 0 || _isSearchingActive)
                      _isSearchingActive ? Expanded(child: _buildWhereExpanded()) : Flexible(child: _buildWhereExpanded())
                    else
                      _buildCollapsedCard(
                        title: 'Địa điểm',
                        value: _selectedCity ?? 'Mọi nơi',
                        onTap: () => setState(() {
                          _expandedSection = 0;
                          _isSearchingActive = true;
                          Future.delayed(const Duration(milliseconds: 100),
                              () => _searchFocusNode.requestFocus());
                        }),
                      ),
                    if (!_isSearchingActive) const SizedBox(height: 16),
                    if (!_isSearchingActive) ...[
                      if (_expandedSection == 1)
                        Flexible(child: _buildWhenExpanded())
                      else
                        _buildCollapsedCard(
                          title: 'Thời gian',
                          value: _selectedDateRange != null
                              ? '${_selectedDateRange!.start.day}/${_selectedDateRange!.start.month} - ${_selectedDateRange!.end.day}/${_selectedDateRange!.end.month}'
                              : 'Bất kỳ lúc nào',
                          onTap: () => setState(() {
                            _expandedSection = 1;
                            _searchFocusNode.unfocus();
                            _isSearchingActive = false;
                          }),
                        ),
                    ]
                  ],
                ),
              ),
            ),

            // Bottom Action Bar
            if (!_isSearchingActive)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.grey.shade200)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: _onClearAll,
                      child: const Text('Xóa tất cả',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline)),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        minimumSize: const Size(0, 52),
                      ),
                      onPressed: _onSearch,
                      icon: const Icon(Icons.search, size: 20),
                      label: const Text('Tìm kiếm',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    ));
  }
}


class _StickySearchBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _StickySearchBarDelegate({required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: child,
    );
  }

  @override
  double get maxExtent => 76.0;

  @override
  double get minExtent => 76.0;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => true;
}
