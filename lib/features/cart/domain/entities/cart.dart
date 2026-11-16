import 'package:auto_hub_app/features/browse/domain/models/product_part_item.dart';
import 'package:equatable/equatable.dart';

class CartItem extends Equatable {
  const CartItem({
    required this.cartItemId,
    required this.part,
    required this.quantity,
    required this.unitPrice,
    required this.maxQuantity,
    this.isAvailable = true,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      cartItemId: json['cartItemId'] as String? ?? '',
      part: ProductPartItem.fromJson(
        json['part'] as Map<String, dynamic>? ?? <String, dynamic>{},
      ),
      quantity: json['quantity'] as int? ?? 1,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      maxQuantity: json['maxQuantity'] as int? ?? 1,
      isAvailable: json['isAvailable'] as bool? ?? true,
    );
  }

  final String cartItemId;
  final ProductPartItem part;
  final int quantity;
  final double unitPrice;
  final int maxQuantity;
  final bool isAvailable;

  @override
  List<Object?> get props => [
        cartItemId,
        part,
        quantity,
        unitPrice,
        maxQuantity,
        isAvailable,
      ];
}

class Cart extends Equatable {
  const Cart({
    required this.cartId,
    required this.items,
    required this.subtotal,
    required this.shipping,
    required this.tax,
    required this.total,
    this.freeShippingThreshold = 100,
    this.qualifiesForFreeShipping = false,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    final itemsList = <CartItem>[];
    if (json['items'] is List) {
      for (final e in json['items'] as List) {
        if (e is Map<String, dynamic>) {
          itemsList.add(CartItem.fromJson(e));
        }
      }
    }

    return Cart(
      cartId: json['cartId'] as String? ?? '',
      items: itemsList,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      shipping: (json['shipping'] as num?)?.toDouble() ?? 0.0,
      tax: (json['tax'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      freeShippingThreshold:
          (json['freeShippingThreshold'] as num?)?.toDouble() ?? 100.0,
      qualifiesForFreeShipping:
          json['qualifiesForFreeShipping'] as bool? ?? false,
    );
  }

  final String cartId;
  final List<CartItem> items;
  final double subtotal;
  final double shipping;
  final double tax;
  final double total;
  final double freeShippingThreshold;
  final bool qualifiesForFreeShipping;

  @override
  List<Object?> get props => [
        cartId,
        items,
        subtotal,
        shipping,
        tax,
        total,
        freeShippingThreshold,
        qualifiesForFreeShipping,
      ];
}

