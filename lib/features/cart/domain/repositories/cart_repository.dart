import 'package:auto_hub_app/core/errors/failures.dart';
import 'package:auto_hub_app/features/cart/domain/entities/cart.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class CartRepository {
  Future<Either<Failure, Cart>> getCart();
  Future<Either<Failure, Cart>> addItem({required String partId, int quantity = 1});
  Future<Either<Failure, Cart>> updateItemQuantity({required String cartItemId, required int quantity});
  Future<Either<Failure, Cart>> removeItem(String cartItemId);
  Future<Either<Failure, Map<String, dynamic>>> checkout({
    required String addressId,
    required String paymentMethodId,
    String shippingMethod = 'standard',
    String? couponCode,
  });
}

