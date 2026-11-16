import 'package:auto_hub_app/features/browse/data/datasources/browse_remote_datasource.dart';
import 'package:auto_hub_app/features/browse/domain/models/product_part_item.dart';
import 'package:auto_hub_app/features/browse/domain/repositories/browse_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: BrowseRepository)
class BrowseRepositoryImpl implements BrowseRepository {
  BrowseRepositoryImpl(this._remoteDatasource);

  final BrowseRemoteDatasource _remoteDatasource;

  @override
  Future<List<ProductPartItem>> getParts() async {
    try {
      final response = await _remoteDatasource.getParts();
      return response.data ?? [];
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<ProductPartItem>> searchParts({
    String? query,
    List<String>? makes,
    List<String>? categories,
    List<String>? conditions,
    double? maxPrice,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _remoteDatasource.getParts(
        query: query,
        makes: makes,
        categories: categories,
        conditions: conditions,
        maxPrice: maxPrice,
        page: page,
        limit: limit,
      );
      return response.data ?? [];
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<ProductPartItem>> searchByVin(
    String vin, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _remoteDatasource.getParts(
        vin: vin,
        page: page,
        limit: limit,
      );
      return response.data ?? [];
    } catch (_) {
      return [];
    }
  }

  @override
  Future<Map<String, dynamic>> getPartDetail(String id) async {
    try {
      return await _remoteDatasource.getPartDetail(id);
    } catch (_) {
      return {};
    }
  }

  @override
  Future<List<ProductPartItem>> getSimilarParts(
    String id, {
    int limit = 10,
  }) async {
    try {
      return await _remoteDatasource.getSimilarParts(id, limit: limit);
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> toggleFavorite(String partId) async {
    await _remoteDatasource.toggleFavorite(partId);
  }
}
