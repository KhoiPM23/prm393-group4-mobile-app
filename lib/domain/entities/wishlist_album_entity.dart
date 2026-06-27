/// Thực thể đại diện cho một Album Yêu thích trong tầng Domain.
/// Ánh xạ từ WishlistAlbum (Drift DataClass) nhưng tách biệt hoàn toàn khỏi tầng Data.
class WishlistAlbumEntity {
  final int id;
  final String name;

  /// Cờ đánh dấu album hệ thống — không cho phép xoá hoặc đổi tên.
  final bool isDefault;

  final DateTime createdAt;

  const WishlistAlbumEntity({
    required this.id,
    required this.name,
    required this.isDefault,
    required this.createdAt,
  });

  @override
  String toString() =>
      'WishlistAlbumEntity(id: $id, name: $name, isDefault: $isDefault)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WishlistAlbumEntity &&
          other.id == id &&
          other.name == name &&
          other.isDefault == isDefault &&
          other.createdAt == createdAt;

  @override
  int get hashCode => Object.hash(id, name, isDefault, createdAt);
}
