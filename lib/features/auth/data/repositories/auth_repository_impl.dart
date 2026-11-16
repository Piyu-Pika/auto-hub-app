import 'package:auto_hub_app/core/errors/exceptions.dart';
import 'package:auto_hub_app/core/errors/failures.dart';
import 'package:auto_hub_app/core/network/token_storage.dart';
import 'package:auto_hub_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:auto_hub_app/features/auth/domain/entities/auth_result.dart';
import 'package:auto_hub_app/features/auth/domain/entities/user_entity.dart';
import 'package:auto_hub_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDatasource remoteDatasource,
    required TokenStorage tokenStorage,
  })  : _remoteDatasource = remoteDatasource,
        _tokenStorage = tokenStorage;

  final AuthRemoteDatasource _remoteDatasource;
  final TokenStorage _tokenStorage;

  @override
  Future<Either<Failure, AuthResult>> register({
    required String fullName,
    required String email,
    required String password,
    String? phone,
    String? deviceId,
    String? platform,
  }) async {
    try {
      final result = await _remoteDatasource.register(
        fullName: fullName,
        email: email,
        password: password,
        phone: phone,
        deviceId: deviceId,
        platform: platform,
      );

      await _tokenStorage.saveTokens(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );

      return Right(result);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message, field: e.field));
    } on ConflictException catch (e) {
      return Left(ConflictFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthResult>> login({
    required String email,
    required String password,
    String? deviceId,
  }) async {
    try {
      final result = await _remoteDatasource.login(
        email: email,
        password: password,
        deviceId: deviceId,
      );

      await _tokenStorage.saveTokens(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );

      return Right(result);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message, field: e.field));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthResult>> socialAuth({
    required String provider,
    required String idToken,
    String? deviceId,
  }) async {
    try {
      final result = await _remoteDatasource.socialAuth(
        provider: provider,
        idToken: idToken,
        deviceId: deviceId,
      );

      await _tokenStorage.saveTokens(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );

      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getSession() async {
    try {
      if (!_tokenStorage.isAuthenticated) {
        return const Left(UnauthorizedFailure(message: 'No active session.'));
      }
      final user = await _remoteDatasource.getSession();
      return Right(user);
    } on UnauthorizedException catch (e) {
      await _tokenStorage.clearTokens();
      return Left(UnauthorizedFailure(message: e.message));
    } on ServerException catch (e) {
      if (e.statusCode == 401) {
        await _tokenStorage.clearTokens();
        return Left(UnauthorizedFailure(message: e.message));
      }
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      final rft = _tokenStorage.refreshToken;
      await _remoteDatasource.logout(rft);
      await _tokenStorage.clearTokens();
      return const Right(null);
    } catch (_) {
      await _tokenStorage.clearTokens();
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, String>> forgotPassword(String email) async {
    try {
      final msg = await _remoteDatasource.forgotPassword(email);
      return Right(msg);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      final msg = await _remoteDatasource.resetPassword(
        token: token,
        newPassword: newPassword,
      );
      await _tokenStorage.clearTokens();
      return Right(msg);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message, field: e.field));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }
}
