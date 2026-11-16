import 'package:auto_hub_app/features/browse/data/datasources/browse_remote_datasource.dart';
import 'package:auto_hub_app/features/browse/data/repositories/mock_browse_repository.dart';
import 'package:auto_hub_app/features/browse/domain/models/product_part_item.dart';
import 'package:auto_hub_app/features/browse/domain/repositories/browse_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: BrowseRepository)
class BrowseRepositoryImpl implements BrowseRepository {
  BrowseRepositoryImpl(this._remoteDatasource);

  final BrowseRemoteDatasource _remoteDatasource;
  final MockBrowseRepository _fallback = MockBrowseRepository();

  @override
  Future<List<ProductPartItem>> getParts() async {
    try {
      final response = await _remoteDatasource.getParts();
      final items = response.data;
      if (items != null && items.isNotEmpty) {
        return items;
      }
      return await _fallback.getParts();
    } catch (_) {
      return _fallback.getParts();
    }
  }

  @override
  Future<List<ProductPartItem>> searchParts({
    String? query,
    List<String>? makes,
    List<String>? categories,
    List<String>? conditions,
    double? maxPrice,
  }) async {
    try {
      final response = await _remoteDatasource.getParts(
        query: query,
        makes: makes,
        categories: categories,
        conditions: conditions,
        maxPrice: maxPrice,
      );
      final items = response.data;
      if (items != null && items.isNotEmpty) {
        return items;
      }
      return await _fallback.searchParts(
        query: query,
        makes: makes,
        categories: categories,
        conditions: conditions,
        maxPrice: maxPrice,
      );
    } catch (_) {
      return _fallback.searchParts(
        query: query,
        makes: makes,
        categories: categories,
        conditions: conditions,
        maxPrice: maxPrice,
      );
    }
  }

  @override
  Future<List<ProductPartItem>> searchByVin(String vin) async {
    try {
      final response = await _remoteDatasource.getParts(vin: vin);
      final items = response.data;
      if (items != null && items.isNotEmpty) {
        return items;
      }
      return await _fallback.searchByVin(vin);
    } catch (_) {
      return _fallback.searchByVin(vin);
    }
  }

  @override
  Future<void> toggleFavorite(String partId) async {
    try {
      await _remoteDatasource.toggleFavorite(partId);
    } catch (_) {
      await _fallback.toggleFavorite(partId);
    }
  }
}
