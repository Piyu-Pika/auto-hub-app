import 'package:auto_hub_app/core/errors/exceptions.dart';
import 'package:auto_hub_app/core/network/api_endpoints.dart';
import 'package:auto_hub_app/core/network/api_response.dart';
import 'package:auto_hub_app/features/home/data/models/home_feed_model.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

abstract interface class HomeRemoteDatasource {
  Future<HomeFeedModel> getHomeFeed({double? lat, double? lng});
}

@LazySingleton(as: HomeRemoteDatasource)
class HomeRemoteDatasourceImpl implements HomeRemoteDatasource {
  HomeRemoteDatasourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<HomeFeedModel> getHomeFeed({double? lat, double? lng}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.homeFeed,
        queryParameters: {
          if (lat != null) 'lat': lat,
          if (lng != null) 'lng': lng,
        },
      );

      final envelope = ApiResponse<HomeFeedModel>.fromJson(
        response.data ?? <String, dynamic>{},
        (dynamic json) =>
            HomeFeedModel.fromJson(json as Map<String, dynamic>),
      );

      return envelope.requireData;
    } on DioException catch (e) {
      if (e.error is ServerException) throw e.error!;
      throw ServerException(
        message: e.message ?? 'Unable to load home feed.',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
