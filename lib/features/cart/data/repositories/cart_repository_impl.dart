import 'package:auto_hub_app/core/errors/exceptions.dart';
import 'package:auto_hub_app/core/errors/failures.dart';
import 'package:auto_hub_app/features/cart/data/datasources/cart_remote_datasource.dart';
import 'package:auto_hub_app/features/cart/domain/entities/cart.dart';
import 'package:auto_hub_app/features/cart/domain/repositories/cart_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: CartRepository)
class CartRepositoryImpl implements CartRepository {
  CartRepositoryImpl(this._remoteDatasource);

  final CartRemoteDatasource _remoteDatasource;

  @override
  Future<Either<Failure, Cart>> getCart() async {
    try {
      final cart = await _remoteDatasource.getCart();
      return Right(cart);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Cart>> addItem({
    required String partId,
    int quantity = 1,
  }) async {
    try {
      final cart = await _remoteDatasource.addItem(
        partId: partId,
        quantity: quantity,
      );
      return Right(cart);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Cart>> updateItemQuantity({
    required String cartItemId,
    required int quantity,
  }) async {
    try {
      final cart = await _remoteDatasource.updateItemQuantity(
        cartItemId: cartItemId,
        quantity: quantity,
      );
      return Right(cart);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Cart>> removeItem(String cartItemId) async {
    try {
      final cart = await _remoteDatasource.removeItem(cartItemId);
      return Right(cart);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> checkout({
    required String addressId,
    required String paymentMethodId,
    String shippingMethod = 'standard',
    String? couponCode,
  }) async {
    try {
      final res = await _remoteDatasource.checkout(
        addressId: addressId,
        paymentMethodId: paymentMethodId,
        shippingMethod: shippingMethod,
        couponCode: couponCode,
      );
      return Right(res);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }
}

