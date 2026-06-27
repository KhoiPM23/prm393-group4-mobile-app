/// Repository interface cho tính năng lịch sử tìm kiếm gần đây.
/// Tầng Domain không biết gì về Drift hay SQLite — chỉ làm việc với interface này.
abstract class SearchHistoryRepository {
  /// Lấy [limit] từ khoá tìm kiếm gần đây nhất, sắp xếp mới nhất lên trước.
  Future<List<String>> getRecentSearches({int limit = 5});

  /// Thêm một từ khoá tìm kiếm vào lịch sử.
  /// Nếu từ khoá đã tồn tại (không phân biệt hoa thường), cập nhật lại thời điểm.
  Future<void> addSearchQuery(String query);

  /// Xoá một từ khoá cụ thể khỏi lịch sử.
  Future<void> deleteSearchQuery(String query);

  /// Xoá toàn bộ lịch sử tìm kiếm.
  Future<void> clearSearchHistory();
}
