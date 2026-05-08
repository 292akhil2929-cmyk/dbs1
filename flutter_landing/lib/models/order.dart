class Order {
  final String orderId;
  final String status;
  final double totalAmount;
  final DateTime orderedAt;
  final int itemCount;
  final String paymentMethod;
  final String street;
  final String city;

  const Order({
    required this.orderId,
    required this.status,
    required this.totalAmount,
    required this.orderedAt,
    required this.itemCount,
    required this.paymentMethod,
    required this.street,
    required this.city,
  });

  factory Order.fromJson(Map<String, dynamic> j) => Order(
        orderId: j['order_id']?.toString() ?? '',
        status: j['status'] as String? ?? 'pending',
        totalAmount: (j['total_amount'] as num?)?.toDouble() ?? 0.0,
        orderedAt: j['ordered_at'] != null
            ? DateTime.tryParse(j['ordered_at'].toString()) ?? DateTime.now()
            : DateTime.now(),
        itemCount: (j['item_count'] as num?)?.toInt() ?? 0,
        paymentMethod: j['payment_method'] as String? ?? 'Cash on Delivery',
        street: j['street'] as String? ?? '',
        city: j['city'] as String? ?? '',
      );

  factory Order.fromLocal(Map<String, dynamic> j) => Order.fromJson(j);

  Map<String, dynamic> toJson() => {
        'order_id': orderId,
        'status': status,
        'total_amount': totalAmount,
        'ordered_at': orderedAt.toIso8601String(),
        'item_count': itemCount,
        'payment_method': paymentMethod,
        'street': street,
        'city': city,
      };
}
