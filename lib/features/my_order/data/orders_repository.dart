import 'package:auto_hub_app/features/my_order/data/datasources/order_remote_datasource.dart';
import 'package:auto_hub_app/features/my_order/domain/models/order_model.dart';
import 'package:auto_hub_app/injection.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart' hide Order;

@lazySingleton
class OrdersRepository {
  OrdersRepository(this._datasource);

  static OrdersRepository get instance => getIt<OrdersRepository>();

  final OrderRemoteDatasource _datasource;

  final ValueNotifier<List<Order>> ordersNotifier =
      ValueNotifier<List<Order>>([]);

  List<Order> getOrders() => ordersNotifier.value;

  Future<List<Order>> fetchOrders() async {
    try {
      final orders = await _datasource.getOrders();
      ordersNotifier.value = orders;
      return orders;
    } catch (_) {
      return ordersNotifier.value;
    }
  }

  Order? getOrderById(String id) {
    for (final order in ordersNotifier.value) {
      if (order.id == id) {
        return order;
      }
    }
    return null;
  }

  /// Fetches a single order from the API, falling back to the cached list.
  Future<Order?> fetchOrderById(String id) async {
    final cached = getOrderById(id);
    if (cached != null) return cached;
    try {
      final order = await _datasource.getOrderById(id);
      final list = List<Order>.from(ordersNotifier.value);
      final index = list.indexWhere((o) => o.id == id);
      if (index != -1) {
        list[index] = order;
      } else {
        list.add(order);
      }
      ordersNotifier.value = list;
      return order;
    } catch (_) {
      return null;
    }
  }

  Future<void> cancelOrder(String id, {String reason = 'no_longer_needed'}) async {
    final updated = await _datasource.cancelOrder(id, reason: reason);
    final list = List<Order>.from(ordersNotifier.value);
    final index = list.indexWhere((o) => o.id == id);
    if (index != -1) {
      list[index] = updated;
    } else {
      list.add(updated);
    }
    ordersNotifier.value = list;
  }
}
