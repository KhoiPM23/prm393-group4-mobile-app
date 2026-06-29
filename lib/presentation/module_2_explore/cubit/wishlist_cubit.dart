import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/wishlist_repository.dart';

/// Cubit quản lý trạng thái yêu thích (Wishlist) toàn cục.
/// State là Set<String> gồm tất cả propertyId đang được yêu thích trong album mặc định.
class WishlistCubit extends Cubit<Set<String>> {
  final WishlistRepository _repo;
  StreamSubscription<Set<String>>? _sub;

  WishlistCubit(this._repo) : super(const {}) {
    _sub = _repo.watchDefaultAlbumPropertyIds().listen(emit);
  }

  /// Toggle trạng thái yêu thích: thêm vào hoặc xoá khỏi album mặc định.
  Future<void> toggleFavorite(String propertyId) async {
    if (state.contains(propertyId)) {
      await _repo.removePropertyFromDefaultAlbum(propertyId);
    } else {
      await _repo.addPropertyToDefaultAlbum(propertyId);
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
