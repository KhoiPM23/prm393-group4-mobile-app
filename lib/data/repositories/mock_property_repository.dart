import '../../domain/entities/property_entity.dart';
import '../../domain/repositories/property_repository.dart';
import '../models/property_model.dart';

class MockPropertyRepository implements PropertyRepository {
  @override
  Future<List<PropertyEntity>> getProperties() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return PropertyModel.mockList();
  }

  @override
  Future<List<PropertyEntity>> getFeaturedProperties() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return PropertyModel.mockList();
  }

  @override
  Future<List<PropertyEntity>> getNearbyProperties() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return PropertyModel.mockList().reversed.toList();
  }

  @override
  Future<PropertyEntity> getPropertyById(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return PropertyModel.mockList().firstWhere(
      (p) => p.id == id,
      orElse: () => throw Exception('Property not found'),
    );
  }
}
