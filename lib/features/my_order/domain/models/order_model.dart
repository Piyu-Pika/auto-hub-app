enum OrderStatus {
  delivered,
  inTransit,
  processing,
  cancelled,
}

class OrderTimelineEvent {
  const OrderTimelineEvent({
    required this.title,
    required this.isCompleted,
    this.time,
  });

  factory OrderTimelineEvent.fromJson(Map<String, dynamic> json) {
    return OrderTimelineEvent(
      title: json['title'] as String? ?? '',
      isCompleted: json['isCompleted'] as bool? ?? false,
      time: json['time'] as String?,
    );
  }

  final String title;
  final String? time;
  final bool isCompleted;
}

class Order {
  const Order({
    required this.id,
    required this.title,
    required this.price,
    required this.address,
    required this.date,
    required this.status,
    required this.timeline,
    this.orderNumber,
    this.trackingNumber,
    this.estimatedDelivery,
    this.subtotal,
    this.shipping,
    this.tax,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    final statusStr = json['status'] as String? ?? 'processing';
    OrderStatus orderStatus;
    switch (statusStr.toLowerCase()) {
      case 'intransit':
      case 'in_transit':
        orderStatus = OrderStatus.inTransit;
      case 'delivered':
        orderStatus = OrderStatus.delivered;
      case 'cancelled':
        orderStatus = OrderStatus.cancelled;
      default:
        orderStatus = OrderStatus.processing;
    }

    final rawPrice = json['price'] ?? json['total'];
    final price = (rawPrice is num) ? rawPrice.toDouble() : 0.0;

    DateTime date;
    final placedAtStr = json['placedAt'] as String?;
    if (placedAtStr != null) {
      date = DateTime.tryParse(placedAtStr) ?? DateTime.now();
    } else {
      date = DateTime.now();
    }

    final timelineList = <OrderTimelineEvent>[];
    if (json['timeline'] is List) {
      for (final e in json['timeline'] as List) {
        if (e is Map<String, dynamic>) {
          timelineList.add(OrderTimelineEvent.fromJson(e));
        }
      }
    }

    return Order(
      id: json['id'] as String? ?? '',
      orderNumber: json['orderNumber'] as String?,
      title: json['title'] as String? ?? 'Auto Part',
      price: price,
      address: json['address'] as String? ?? '',
      date: date,
      status: orderStatus,
      timeline: timelineList,
      trackingNumber: json['trackingNumber'] as String?,
      estimatedDelivery: json['estimatedDelivery'] as String?,
      subtotal: (json['subtotal'] as num?)?.toDouble(),
      shipping: (json['shipping'] as num?)?.toDouble(),
      tax: (json['tax'] as num?)?.toDouble(),
    );
  }

  final String id;
  final String? orderNumber;
  final String title;
  final double price;
  final String? trackingNumber;
  final String? estimatedDelivery;
  final String address;
  final DateTime date;
  final OrderStatus status;
  final List<OrderTimelineEvent> timeline;
  final double? subtotal;
  final double? shipping;
  final double? tax;

  Order copyWith({
    OrderStatus? status,
    List<OrderTimelineEvent>? timeline,
  }) {
    return Order(
      id: id,
      orderNumber: orderNumber,
      title: title,
      price: price,
      address: address,
      date: date,
      status: status ?? this.status,
      timeline: timeline ?? this.timeline,
      trackingNumber: trackingNumber,
      estimatedDelivery: estimatedDelivery,
      subtotal: subtotal,
      shipping: shipping,
      tax: tax,
    );
  }
}
