import 'package:auto_hub_app/features/browse/domain/models/product_part_item.dart';

abstract class BrowseRepository {
  Future<List<ProductPartItem>> getParts();
  
  Future<List<ProductPartItem>> searchParts({
    String? query,
    List<String>? makes,
    List<String>? categories,
    List<String>? conditions,
    double? maxPrice,
    int page = 1,
    int limit = 20,
  });
  
  Future<List<ProductPartItem>> searchByVin(
    String vin, {
    int page = 1,
    int limit = 20,
  });

  Future<Map<String, dynamic>> getPartDetail(String id);

  Future<List<ProductPartItem>> getSimilarParts(String id, {int limit = 10});
  
  Future<void> toggleFavorite(String partId);
}
