import 'package:auto_hub_app/features/payment_methods/data/datasources/mock_payment_data.dart';
import 'package:auto_hub_app/features/payment_methods/data/datasources/payment_remote_datasource.dart';
import 'package:auto_hub_app/features/payment_methods/domain/entities/payment_card.dart';
import 'package:auto_hub_app/features/payment_methods/domain/repositories/payment_methods_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: PaymentMethodsRepository)
class PaymentMethodsRepositoryImpl implements PaymentMethodsRepository {
  PaymentMethodsRepositoryImpl(this._remoteDatasource);

  final PaymentRemoteDatasource _remoteDatasource;
  final List<PaymentCard> _fallbackCards = List.from(mockPaymentCards);

  @override
  Future<List<PaymentCard>> getPaymentMethods() async {
    try {
      final list = await _remoteDatasource.getPaymentMethods();
      if (list.isNotEmpty) return list;
      return List.unmodifiable(_fallbackCards);
    } catch (_) {
      return List.unmodifiable(_fallbackCards);
    }
  }

  @override
  Future<PaymentCard> addPaymentMethod({
    required String cardHolder,
    required String cardNumber,
    required String expiry,
    required String cvc,
  }) async {
    try {
      final card = await _remoteDatasource.addPaymentMethod(
        cardHolder: cardHolder,
        cardNumber: cardNumber,
        expiry: expiry,
        cvc: cvc,
      );
      _fallbackCards.add(card);
      return card;
    } catch (_) {
      final cleanNumber = cardNumber.replaceAll(RegExp(r'\s+'), '');
      final last4 = cleanNumber.length >= 4
          ? cleanNumber.substring(cleanNumber.length - 4)
          : cleanNumber;

      String detectedBrand = 'Visa';
      if (cleanNumber.startsWith('4')) {
        detectedBrand = 'Visa';
      } else if (cleanNumber.startsWith('5')) {
        detectedBrand = 'Mastercard';
      } else if (cleanNumber.startsWith(RegExp(r'3[47]'))) {
        detectedBrand = 'AmEx';
      } else if (cleanNumber.startsWith('6')) {
        detectedBrand = 'Discover';
      }

      final newCard = PaymentCard(
        id: 'pm_${DateTime.now().millisecondsSinceEpoch}',
        cardHolder: cardHolder.toUpperCase(),
        last4: last4,
        expiry: expiry,
        brand: detectedBrand,
        isDefault: _fallbackCards.isEmpty,
      );
      _fallbackCards.add(newCard);
      return newCard;
    }
  }

  @override
  Future<void> removePaymentMethod(String cardId) async {
    try {
      await _remoteDatasource.removePaymentMethod(cardId);
      _fallbackCards.removeWhere((c) => c.id == cardId);
    } catch (_) {
      _fallbackCards.removeWhere((c) => c.id == cardId);
    }
  }

  @override
  Future<void> setDefaultPaymentMethod(String cardId) async {
    try {
      await _remoteDatasource.setDefaultPaymentMethod(cardId);
    } catch (_) {
      for (var i = 0; i < _fallbackCards.length; i++) {
        _fallbackCards[i] = _fallbackCards[i].copyWith(
          isDefault: _fallbackCards[i].id == cardId,
        );
      }
    }
  }
}
