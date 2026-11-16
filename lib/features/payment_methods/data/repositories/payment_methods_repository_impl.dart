import 'package:auto_hub_app/features/payment_methods/data/datasources/payment_remote_datasource.dart';
import 'package:auto_hub_app/features/payment_methods/domain/entities/payment_card.dart';
import 'package:auto_hub_app/features/payment_methods/domain/repositories/payment_methods_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: PaymentMethodsRepository)
class PaymentMethodsRepositoryImpl implements PaymentMethodsRepository {
  PaymentMethodsRepositoryImpl(this._remoteDatasource);

  final PaymentRemoteDatasource _remoteDatasource;

  @override
  Future<List<PaymentCard>> getPaymentMethods() async {
    return _remoteDatasource.getPaymentMethods();
  }

  @override
  Future<PaymentCard> addPaymentMethod({
    required String cardHolder,
    required String cardNumber,
    required String expiry,
    required String cvc,
  }) async {
    return _remoteDatasource.addPaymentMethod(
      cardHolder: cardHolder,
      cardNumber: cardNumber,
      expiry: expiry,
      cvc: cvc,
    );
  }

  @override
  Future<void> removePaymentMethod(String cardId) async {
    await _remoteDatasource.removePaymentMethod(cardId);
  }

  @override
  Future<void> setDefaultPaymentMethod(String cardId) async {
    await _remoteDatasource.setDefaultPaymentMethod(cardId);
  }
}
