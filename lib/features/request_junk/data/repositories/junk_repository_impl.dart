import 'package:auto_hub_app/core/errors/exceptions.dart';
import 'package:auto_hub_app/core/errors/failures.dart';
import 'package:auto_hub_app/features/request_junk/data/datasources/junk_remote_datasource.dart';
import 'package:auto_hub_app/features/request_junk/domain/repositories/junk_repository.dart';
import 'package:auto_hub_app/features/request_junk/models/junk_models.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: JunkRepository)
class JunkRepositoryImpl implements JunkRepository {
  JunkRepositoryImpl(this._remoteDatasource);

  final JunkRemoteDatasource _remoteDatasource;

  @override
  Future<Either<Failure, Map<String, dynamic>>> getInstantQuote({
    required String year,
    required String make,
    required String model,
    required String condition,
    required bool hasTitle,
    required bool hasKeys,
    String? vin,
  }) async {
    try {
      final res = await _remoteDatasource.getInstantQuote(
        year: year,
        make: make,
        model: model,
        condition: condition,
        hasTitle: hasTitle,
        hasKeys: hasKeys,
        vin: vin,
      );
      return Right(res);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<String>>> uploadVehicleImages(
    List<String> filePaths,
  ) async {
    try {
      final urls = await _remoteDatasource.uploadVehicleImages(filePaths);
      return Right(urls);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, JunkRequest>> createJunkRequest({
    required String year,
    required String make,
    required String model,
    required String condition,
    required bool hasTitle,
    required bool hasKeys,
    required String pickupAddress,
    String? vin,
    String? notes,
    List<String>? imageUrls,
  }) async {
    try {
      final req = await _remoteDatasource.createJunkRequest(
        year: year,
        make: make,
        model: model,
        condition: condition,
        hasTitle: hasTitle,
        hasKeys: hasKeys,
        pickupAddress: pickupAddress,
        vin: vin,
        notes: notes,
        imageUrls: imageUrls,
      );
      return Right(req);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<JunkRequest>>> getJunkRequests({
    String status = 'all',
  }) async {
    try {
      final list = await _remoteDatasource.getJunkRequests(status: status);
      return Right(list);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, JunkRequest>> getJunkRequestById(String id) async {
    try {
      final req = await _remoteDatasource.getJunkRequestById(id);
      return Right(req);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, JunkRequest>> acceptOffer(
    String id, {
    required int offerAmount,
  }) async {
    try {
      final req = await _remoteDatasource.acceptOffer(id, offerAmount: offerAmount);
      return Right(req);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, JunkRequest>> schedulePickup(
    String id, {
    required String scheduledAt,
    String? notes,
  }) async {
    try {
      final req = await _remoteDatasource.schedulePickup(
        id,
        scheduledAt: scheduledAt,
        notes: notes,
      );
      return Right(req);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, JunkRequest>> cancelJunkRequest(
    String id, {
    String? reason,
  }) async {
    try {
      final req = await _remoteDatasource.cancelJunkRequest(id, reason: reason);
      return Right(req);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }
}

