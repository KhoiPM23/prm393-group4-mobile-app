import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

// ─────────────────────────────────────────────
// TABLE DEFINITIONS
// ─────────────────────────────────────────────

/// Bảng lưu các từ khoá tìm kiếm gần đây.
class RecentSearches extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Từ khoá tìm kiếm.
  TextColumn get query => text().withLength(min: 1, max: 255)();

  /// Thời điểm lần cuối cùng từ khoá này được tìm kiếm.
  DateTimeColumn get searchedAt => dateTime().withDefault(currentDateAndTime)();
}

/// Bảng lưu các Album Yêu thích do người dùng tạo.
/// Album mặc định "Lịch sử gần đây" sẽ được tự động chèn khi DB được khởi tạo lần đầu.
class WishlistAlbums extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Tên album (ví dụ: "Lịch sử gần đây", "Du lịch hè 2026").
  TextColumn get name => text().withLength(min: 1, max: 100)();

  /// Cờ đánh dấu album hệ thống (không cho phép xoá/đổi tên).
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();

  /// Thời điểm tạo album.
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Bảng liên kết giữa Album Yêu thích và ID của chỗ nghỉ.
class WishlistItems extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// FK trỏ về WishlistAlbums.id.
  IntColumn get albumId =>
      integer().references(WishlistAlbums, #id, onDelete: KeyAction.cascade)();

  /// ID của chỗ nghỉ (tương ứng PropertyEntity.id từ mock/Firebase).
  TextColumn get propertyId => text()();

  /// Thời điểm thêm chỗ nghỉ vào album.
  DateTimeColumn get savedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
        {albumId, propertyId},
      ];
}

// ─────────────────────────────────────────────
// DATABASE CLASS
// ─────────────────────────────────────────────

@DriftDatabase(tables: [RecentSearches, WishlistAlbums, WishlistItems])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Dùng cho testing: nhận QueryExecutor từ bên ngoài.
  AppDatabase.withExecutor(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          // Tạo tất cả các bảng
          await m.createAll();

          // Chèn album mặc định "Lịch sử gần đây"
          await into(wishlistAlbums).insert(
            WishlistAlbumsCompanion.insert(
              name: 'Lịch sử gần đây',
              isDefault: const Value(true),
            ),
          );
        },
        onUpgrade: (m, from, to) async {
          // Placeholder cho các migration trong tương lai
        },
      );

  // ─── Recent Searches DAOs ────────────────────

  /// Truy vấn [limit] từ khoá tìm kiếm gần đây nhất, sắp xếp mới nhất lên trước.
  Future<List<RecentSearche>> getRecentSearches({int limit = 5}) {
    return (select(recentSearches)
          ..orderBy([(t) => OrderingTerm.desc(t.searchedAt)])
          ..limit(limit))
        .get();
  }

  /// Thêm hoặc cập nhật một từ khoá tìm kiếm.
  /// Nếu từ khoá đã tồn tại, cập nhật lại thời điểm tìm kiếm để nổi lên trên.
  Future<void> upsertSearchQuery(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    // Xoá bản ghi cũ nếu có (case-insensitive)
    await (delete(recentSearches)
          ..where((t) => t.query.lower().equals(trimmed.toLowerCase())))
        .go();

    // Chèn bản ghi mới với thời điểm hiện tại
    await into(recentSearches).insert(
      RecentSearchesCompanion.insert(query: trimmed),
    );
  }

  /// Xoá một từ khoá tìm kiếm cụ thể.
  Future<void> deleteSearchQuery(String query) {
    return (delete(recentSearches)
          ..where((t) => t.query.equals(query)))
        .go();
  }

  /// Xoá toàn bộ lịch sử tìm kiếm.
  Future<void> clearSearchHistory() => delete(recentSearches).go();

  // ─── Wishlist Albums DAOs ────────────────────

  /// Lấy tất cả album, sắp xếp: album mặc định lên đầu, các album khác theo thứ tự tạo.
  Future<List<WishlistAlbum>> getAllAlbums() {
    return (select(wishlistAlbums)
          ..orderBy([
            (t) => OrderingTerm.desc(t.isDefault),
            (t) => OrderingTerm.asc(t.createdAt),
          ]))
        .get();
  }

  /// Lấy album mặc định (isDefault = true).
  Future<WishlistAlbum?> getDefaultAlbum() {
    return (select(wishlistAlbums)
          ..where((t) => t.isDefault.equals(true))
          ..limit(1))
        .getSingleOrNull();
  }

  /// Tạo album mới với tên được chỉ định.
  Future<int> createAlbum(String name) {
    return into(wishlistAlbums).insert(
      WishlistAlbumsCompanion.insert(name: name.trim()),
    );
  }

  /// Đổi tên album (chỉ áp dụng cho album không phải mặc định).
  Future<bool> renameAlbum(int albumId, String newName) async {
    final album = await (select(wishlistAlbums)
          ..where((t) => t.id.equals(albumId)))
        .getSingleOrNull();

    if (album == null || album.isDefault) return false;

    await (update(wishlistAlbums)..where((t) => t.id.equals(albumId))).write(
      WishlistAlbumsCompanion(name: Value(newName.trim())),
    );
    return true;
  }

  /// Xoá album (chỉ áp dụng cho album không phải mặc định).
  /// Các WishlistItems thuộc album sẽ bị xoá theo cascade.
  Future<bool> deleteAlbum(int albumId) async {
    final album = await (select(wishlistAlbums)
          ..where((t) => t.id.equals(albumId)))
        .getSingleOrNull();

    if (album == null || album.isDefault) return false;

    await (delete(wishlistAlbums)..where((t) => t.id.equals(albumId))).go();
    return true;
  }

  // ─── Wishlist Items DAOs ─────────────────────

  /// Lấy danh sách ID chỗ nghỉ trong một album.
  Future<List<String>> getPropertyIdsInAlbum(int albumId) async {
    final items = await (select(wishlistItems)
          ..where((t) => t.albumId.equals(albumId))
          ..orderBy([(t) => OrderingTerm.desc(t.savedAt)]))
        .get();
    return items.map((i) => i.propertyId).toList();
  }

  /// Thêm một chỗ nghỉ vào album.
  /// Nếu đã tồn tại thì bỏ qua (do UniqueKey constraint).
  Future<void> addPropertyToAlbum(int albumId, String propertyId) async {
    await into(wishlistItems).insertOnConflictUpdate(
      WishlistItemsCompanion.insert(
        albumId: albumId,
        propertyId: propertyId,
      ),
    );
  }

  /// Xoá một chỗ nghỉ khỏi album.
  Future<void> removePropertyFromAlbum(int albumId, String propertyId) {
    return (delete(wishlistItems)
          ..where(
            (t) =>
                t.albumId.equals(albumId) & t.propertyId.equals(propertyId),
          ))
        .go();
  }

  /// Kiểm tra xem một chỗ nghỉ có nằm trong album cụ thể không.
  Future<bool> isPropertyInAlbum(int albumId, String propertyId) async {
    final count = await (select(wishlistItems)
          ..where(
            (t) =>
                t.albumId.equals(albumId) & t.propertyId.equals(propertyId),
          ))
        .get();
    return count.isNotEmpty;
  }

  /// Kiểm tra xem một chỗ nghỉ có nằm trong bất kỳ album nào không.
  Future<bool> isPropertyInAnyWishlist(String propertyId) async {
    final count = await (select(wishlistItems)
          ..where((t) => t.propertyId.equals(propertyId)))
        .get();
    return count.isNotEmpty;
  }

  /// Stream lắng nghe thay đổi trạng thái yêu thích của một chỗ nghỉ trong album mặc định.
  Stream<bool> watchIsPropertyInDefaultAlbum(String propertyId) {
    final defaultAlbumQuery = select(wishlistAlbums)
      ..where((t) => t.isDefault.equals(true))
      ..limit(1);

    return defaultAlbumQuery.watchSingleOrNull().asyncMap((album) async {
      if (album == null) return false;
      return isPropertyInAlbum(album.id, propertyId);
    });
  }
}

// ─────────────────────────────────────────────
// DATABASE CONNECTION FACTORY
// ─────────────────────────────────────────────

/// Tạo kết nối tới file SQLite trên thiết bị.
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'vibelocals.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
