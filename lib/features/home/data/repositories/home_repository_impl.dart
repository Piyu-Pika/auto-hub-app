import 'package:auto_hub_app/core/errors/exceptions.dart';
import 'package:auto_hub_app/core/errors/failures.dart';
import 'package:auto_hub_app/features/home/data/datasources/home_remote_datasource.dart';
import 'package:auto_hub_app/features/home/domain/entities/home_feed_entity.dart';
import 'package:auto_hub_app/features/home/domain/repositories/home_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: HomeRepository)
class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl(this._remoteDatasource);

  final HomeRemoteDatasource _remoteDatasource;

  @override
  Future<Either<Failure, HomeFeedEntity>> getHomeFeed({
    double? lat,
    double? lng,
  }) async {
    try {
      final feed = await _remoteDatasource.getHomeFeed(lat: lat, lng: lng);
      return Right(feed);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }
}
