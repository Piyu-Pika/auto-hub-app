import 'package:auto_hub_app/core/errors/failures.dart';
import 'package:auto_hub_app/features/auth/domain/entities/auth_result.dart';
import 'package:auto_hub_app/features/auth/domain/entities/user_entity.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, AuthResult>> register({
    required String fullName,
    required String email,
    required String password,
    String? phone,
    String? deviceId,
    String? platform,
  });

  Future<Either<Failure, AuthResult>> login({
    required String email,
    required String password,
    String? deviceId,
  });

  Future<Either<Failure, AuthResult>> socialAuth({
    required String provider,
    required String idToken,
    String? deviceId,
  });

  Future<Either<Failure, UserEntity>> getSession();

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, String>> forgotPassword(String email);

  Future<Either<Failure, String>> resetPassword({
    required String token,
    required String newPassword,
  });
}
