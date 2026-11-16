import 'package:auto_hub_app/core/errors/failures.dart';
import 'package:auto_hub_app/features/request_junk/models/junk_models.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class JunkRepository {
  Future<Either<Failure, Map<String, dynamic>>> getInstantQuote({
    required String year,
    required String make,
    required String model,
    required String condition,
    required bool hasTitle,
    required bool hasKeys,
    String? vin,
  });

  Future<Either<Failure, List<String>>> uploadVehicleImages(List<String> filePaths);

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
  });

  Future<Either<Failure, List<JunkRequest>>> getJunkRequests({
    String status = 'all',
  });

  Future<Either<Failure, JunkRequest>> getJunkRequestById(String id);

  Future<Either<Failure, JunkRequest>> acceptOffer(String id, {required int offerAmount});

  Future<Either<Failure, JunkRequest>> schedulePickup(
    String id, {
    required String scheduledAt,
    String? notes,
  });

  Future<Either<Failure, JunkRequest>> cancelJunkRequest(String id, {String? reason});
}

