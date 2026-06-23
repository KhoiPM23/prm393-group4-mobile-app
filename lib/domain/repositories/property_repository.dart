import '../entities/property_entity.dart';

abstract class PropertyRepository {
  Future<List<PropertyEntity>> getProperties();
  Future<List<PropertyEntity>> getFeaturedProperties();
  Future<List<PropertyEntity>> getNearbyProperties();
  Future<PropertyEntity> getPropertyById(String id);
  Future<List<PropertyEntity>> searchProperties(String query, String category);
}
