import '../entities/property_entity.dart';
import '../entities/wishlist_album_entity.dart';

/// Repository interface cho tính năng Wishlist (Danh sách yêu thích).
/// Tầng Domain giao tiếp hoàn toàn qua interface này — không phụ thuộc Drift.
abstract class WishlistRepository {
  // ─── Album Operations ─────────────────────────────

  /// Lấy tất cả album của người dùng.
  /// Album mặc định ("Lịch sử gần đây") luôn đứng đầu danh sách.
  Future<List<WishlistAlbumEntity>> getAlbums();

  /// Lấy album mặc định (isDefault = true).
  Future<WishlistAlbumEntity?> getDefaultAlbum();

  /// Tạo một album mới với tên được chỉ định.
  /// Trả về ID của album vừa tạo.
  Future<int> createAlbum(String name);

  /// Đổi tên album. Trả về `false` nếu album không tồn tại hoặc là album mặc định.
  Future<bool> renameAlbum(int albumId, String newName);

  /// Xoá album và tất cả các chỗ nghỉ bên trong (CASCADE).
  /// Trả về `false` nếu album không tồn tại hoặc là album mặc định.
  Future<bool> deleteAlbum(int albumId);

  // ─── Item (Property) Operations ──────────────────

  /// Lấy danh sách chỗ nghỉ trong một album cụ thể.
  /// Kết hợp với PropertyRepository để trả về danh sách [PropertyEntity] đầy đủ.
  Future<List<PropertyEntity>> getPropertiesInAlbum(int albumId);

  /// Thêm một chỗ nghỉ vào album. Nếu đã có thì bỏ qua (idempotent).
  Future<void> addPropertyToAlbum(int albumId, String propertyId);

  /// Xoá một chỗ nghỉ khỏi album.
  Future<void> removePropertyFromAlbum(int albumId, String propertyId);

  /// Kiểm tra xem một chỗ nghỉ có đang được lưu trong album cụ thể không.
  Future<bool> isPropertyInAlbum(int albumId, String propertyId);

  /// Kiểm tra xem một chỗ nghỉ có được lưu trong bất kỳ album nào không.
  Future<bool> isPropertyInAnyWishlist(String propertyId);

  /// Thêm chỗ nghỉ vào album mặc định ("Lịch sử gần đây").
  /// Là shortcut kết hợp giữa [getDefaultAlbum] và [addPropertyToAlbum].
  Future<void> addPropertyToDefaultAlbum(String propertyId);

  /// Xoá chỗ nghỉ khỏi album mặc định.
  Future<void> removePropertyFromDefaultAlbum(String propertyId);

  // ─── Reactive Stream ──────────────────────────────

  /// Stream lắng nghe trạng thái yêu thích (trong album mặc định) của một chỗ nghỉ.
  /// Dùng để cập nhật icon trái tim trên PropertyCard theo thời gian thực.
  Stream<bool> watchIsPropertyInDefaultAlbum(String propertyId);

  /// Stream trả về tập hợp tất cả propertyId đang được yêu thích trong album mặc định.
  /// Dùng để render danh sách — so khớp batch thay vì query riêng từng item.
  Stream<Set<String>> watchDefaultAlbumPropertyIds();
}
