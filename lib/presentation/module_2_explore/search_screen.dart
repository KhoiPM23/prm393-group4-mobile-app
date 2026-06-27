import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_dimensions.dart';
import '../widgets/property_card.dart';
import 'blocs/search/search_bloc.dart';
import 'blocs/search/search_event.dart';
import 'blocs/search/search_state.dart';
import '../../data/repositories/mock_property_repository.dart';
import 'widgets/filter_bottom_sheet.dart';

class SearchScreen extends StatefulWidget {
  final String initialQuery;
  
  const SearchScreen({super.key, this.initialQuery = ''});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late TextEditingController _searchController;
  late FocusNode _focusNode;
  String _selectedCategory = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);
    _focusNode = FocusNode();
    // Delay request focus to avoid IME composing bug during route transition
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearch(BuildContext context) {
    context.read<SearchBloc>().add(
          SearchPropertiesRequested(
            query: _searchController.text,
            category: _selectedCategory,
          ),
        );
  }

  void _openFilter(BuildContext context) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FilterBottomSheet(),
    );
    
    if (!context.mounted) return;
    if (result != null) {
      setState(() {
        _selectedCategory = result;
      });
      _onSearch(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SearchBloc(
        propertyRepository: MockPropertyRepository(),
      )..add(SearchPropertiesRequested(query: widget.initialQuery)),
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.surface,
              elevation: 0,
              iconTheme: const IconThemeData(color: AppColors.onSurface),
              title: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(
                      color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        focusNode: _focusNode,
                        style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurface),
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm điểm đến...',
                          hintStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.outline),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
                        ),
                        onSubmitted: (_) => _onSearch(context),
                      ),
                    ),
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear, size: 20, color: AppColors.onSurfaceVariant),
                        onPressed: () {
                          _searchController.clear();
                          _onSearch(context);
                        },
                      ),
                  ],
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.tune, color: AppColors.primary),
                  onPressed: () => _openFilter(context),
                ),
                const SizedBox(width: 8),
              ],
            ),
            body: BlocBuilder<SearchBloc, SearchState>(
              builder: (context, state) {
                if (state is SearchLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is SearchFailure) {
                  return Center(child: Text('Lỗi: ${state.error}'));
                } else if (state is SearchLoaded) {
                  final properties = state.properties;
                  if (properties.isEmpty) {
                    return Center(
                      child: Text(
                        'Không tìm thấy kết quả nào.',
                        style: AppTextStyles.bodyLg.copyWith(color: AppColors.onSurfaceVariant),
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: properties.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.lg),
                    itemBuilder: (context, i) {
                      final p = properties[i];
                      final formattedPrice = '${p.pricePerNight.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}đ';
                      return PropertyCard(
                        title: p.title,
                        location: p.location,
                        priceText: formattedPrice,
                        rating: p.rating,
                        imageUrl: p.imageUrls.isNotEmpty ? p.imageUrls.first : '',
                        onTap: () => Navigator.of(context).pushNamed('/property-detail', arguments: p),
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          );
        }
      ),
    );
  }
}
