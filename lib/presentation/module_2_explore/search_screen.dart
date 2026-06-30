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
import '../../domain/repositories/search_history_repository.dart';
import 'cubit/wishlist_cubit.dart';
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
  List<String> _recentSearches = [];
  bool _showHistory = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChanged);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _focusNode.requestFocus();
    });
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      _loadRecentSearches();
      setState(() => _showHistory = true);
    } else {
      setState(() => _showHistory = false);
    }
  }

  Future<void> _loadRecentSearches() async {
    final repo = context.read<SearchHistoryRepository>();
    final searches = await repo.getRecentSearches(limit: 5);
    if (mounted) setState(() => _recentSearches = searches);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearch(BuildContext context) {
    final query = _searchController.text;
    if (query.trim().isNotEmpty) {
      context.read<SearchHistoryRepository>().addSearchQuery(query.trim());
    }
    setState(() => _showHistory = false);
    _focusNode.unfocus();
    context.read<SearchBloc>().add(
          SearchPropertiesRequested(
            query: query,
            category: _selectedCategory,
          ),
        );
  }

  void _applyHistoryQuery(BuildContext context, String query) {
    _searchController.text = query;
    _onSearch(context);
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
      setState(() => _selectedCategory = result);
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
                        style: AppTextStyles.bodyMd
                            .copyWith(color: AppColors.onSurface),
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm điểm đến...',
                          hintStyle: AppTextStyles.bodyMd
                              .copyWith(color: AppColors.outline),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 0, vertical: 12),
                        ),
                        onSubmitted: (_) => _onSearch(context),
                      ),
                    ),
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear,
                            size: 20, color: AppColors.onSurfaceVariant),
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
            body: _showHistory && _recentSearches.isNotEmpty
                ? _SearchHistoryList(
                    searches: _recentSearches,
                    onSelect: (q) => _applyHistoryQuery(context, q),
                  )
                : BlocBuilder<SearchBloc, SearchState>(
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
                              style: AppTextStyles.bodyLg.copyWith(
                                  color: AppColors.onSurfaceVariant),
                            ),
                          );
                        }
                        return BlocBuilder<WishlistCubit, Set<String>>(
                          builder: (context, favoriteIds) {
                            return ListView.separated(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              itemCount: properties.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: AppSpacing.lg),
                              itemBuilder: (context, i) {
                                final p = properties[i];
                                final formattedPrice =
                                    '${p.pricePerNight.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}đ';
                                return PropertyCard(
                                  title: p.title,
                                  location: p.location,
                                  priceText: formattedPrice,
                                  rating: p.rating,
                                  imageUrl: p.imageUrls.isNotEmpty
                                      ? p.imageUrls.first
                                      : '',
                                  isFavorite: favoriteIds.contains(p.id),
                                  onFavoriteToggle: () => context
                                      .read<WishlistCubit>()
                                      .toggleFavorite(p.id),
                                  onTap: () => Navigator.of(context)
                                      .pushNamed('/property-detail',
                                          arguments: p),
                                );
                              },
                            );
                          },
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
          );
        },
      ),
    );
  }
}

class _SearchHistoryList extends StatelessWidget {
  final List<String> searches;
  final ValueChanged<String> onSelect;

  const _SearchHistoryList({required this.searches, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      itemCount: searches.length,
      itemBuilder: (context, i) {
        final query = searches[i];
        return ListTile(
          leading: const Icon(Icons.history,
              color: AppColors.onSurfaceVariant, size: 20),
          title: Text(query,
              style: AppTextStyles.bodyMd
                  .copyWith(color: AppColors.onSurface)),
          onTap: () => onSelect(query),
        );
      },
    );
  }
}
