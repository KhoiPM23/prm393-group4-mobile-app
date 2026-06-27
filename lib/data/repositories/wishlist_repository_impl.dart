import '../../domain/entities/property_entity.dart';
import '../../domain/entities/wishlist_album_entity.dart';
import '../../domain/repositories/property_repository.dart';
import '../../domain/repositories/wishlist_repository.dart';
import '../datasources/local/app_database.dart';

/// Triển khai [WishlistRepository] sử dụng Drift SQLite.
///
/// Phụ thuộc vào:
/// - [AppDatabase]: truy cập các bảng wishlist_albums và wishlist_items.
/// - [PropertyRepository]: lấy thông tin đầy đủ của [PropertyEntity] theo ID.
class WishlistRepositoryImpl implements WishlistRepository {
  final AppDatabase _db;
  final PropertyRepository _propertyRepository;

  const WishlistRepositoryImpl({
    required AppDatabase db,
    required PropertyRepository propertyRepository,
  })  : _db = db,
        _propertyRepository = propertyRepository;

  // ─── Chuyển đổi Drift DataClass → Domain Entity ───

  WishlistAlbumEntity _toEntity(WishlistAlbum album) {
    return WishlistAlbumEntity(
      id: album.id,
      name: album.name,
      isDefault: album.isDefault,
      createdAt: album.createdAt,
    );
  }

  // ─── Album Operations ─────────────────────────────

  @override
  Future<List<WishlistAlbumEntity>> getAlbums() async {
    final albums = await _db.getAllAlbums();
    return albums.map(_toEntity).toList();
  }

  @override
  Future<WishlistAlbumEntity?> getDefaultAlbum() async {
    final album = await _db.getDefaultAlbum();
    return album != null ? _toEntity(album) : null;
  }

  @override
  Future<int> createAlbum(String name) => _db.createAlbum(name);

  @override
  Future<bool> renameAlbum(int albumId, String newName) =>
      _db.renameAlbum(albumId, newName);

  @override
  Future<bool> deleteAlbum(int albumId) => _db.deleteAlbum(albumId);

  // ─── Item (Property) Operations ──────────────────

  @override
  Future<List<PropertyEntity>> getPropertiesInAlbum(int albumId) async {
    final propertyIds = await _db.getPropertyIdsInAlbum(albumId);

    // Lấy thông tin từng chỗ nghỉ từ PropertyRepository, bỏ qua các ID không tìm thấy
    final List<PropertyEntity> result = [];
    for (final id in propertyIds) {
      try {
        final property = await _propertyRepository.getPropertyById(id);
        result.add(property);
      } catch (_) {
        // Bỏ qua nếu chỗ nghỉ đã bị xoá hoặc không tìm thấy
      }
    }
    return result;
  }

  @override
  Future<void> addPropertyToAlbum(int albumId, String propertyId) =>
      _db.addPropertyToAlbum(albumId, propertyId);

  @override
  Future<void> removePropertyFromAlbum(int albumId, String propertyId) =>
      _db.removePropertyFromAlbum(albumId, propertyId);

  @override
  Future<bool> isPropertyInAlbum(int albumId, String propertyId) =>
      _db.isPropertyInAlbum(albumId, propertyId);

  @override
  Future<bool> isPropertyInAnyWishlist(String propertyId) =>
      _db.isPropertyInAnyWishlist(propertyId);

  // ─── Default Album Shortcuts ──────────────────────

  @override
  Future<void> addPropertyToDefaultAlbum(String propertyId) async {
    final defaultAlbum = await _db.getDefaultAlbum();
    if (defaultAlbum == null) return;
    await _db.addPropertyToAlbum(defaultAlbum.id, propertyId);
  }

  @override
  Future<void> removePropertyFromDefaultAlbum(String propertyId) async {
    final defaultAlbum = await _db.getDefaultAlbum();
    if (defaultAlbum == null) return;
    await _db.removePropertyFromAlbum(defaultAlbum.id, propertyId);
  }

  // ─── Reactive Stream ──────────────────────────────

  @override
  Stream<bool> watchIsPropertyInDefaultAlbum(String propertyId) =>
      _db.watchIsPropertyInDefaultAlbum(propertyId);
}
