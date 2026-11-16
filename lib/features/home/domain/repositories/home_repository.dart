import 'package:auto_hub_app/core/errors/failures.dart';
import 'package:auto_hub_app/features/home/domain/entities/home_feed_entity.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class HomeRepository {
  Future<Either<Failure, HomeFeedEntity>> getHomeFeed({
    double? lat,
    double? lng,
  });
}
