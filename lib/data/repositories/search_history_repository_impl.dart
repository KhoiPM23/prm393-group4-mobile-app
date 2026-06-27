import '../../domain/repositories/search_history_repository.dart';
import '../datasources/local/app_database.dart';

/// Triển khai [SearchHistoryRepository] sử dụng Drift SQLite.
/// Giao tiếp trực tiếp với [AppDatabase] để lưu/đọc lịch sử tìm kiếm.
class SearchHistoryRepositoryImpl implements SearchHistoryRepository {
  final AppDatabase _db;

  const SearchHistoryRepositoryImpl(this._db);

  @override
  Future<List<String>> getRecentSearches({int limit = 5}) async {
    final rows = await _db.getRecentSearches(limit: limit);
    return rows.map((r) => r.query).toList();
  }

  @override
  Future<void> addSearchQuery(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    await _db.upsertSearchQuery(trimmed);
  }

  @override
  Future<void> deleteSearchQuery(String query) =>
      _db.deleteSearchQuery(query);

  @override
  Future<void> clearSearchHistory() => _db.clearSearchHistory();
}
