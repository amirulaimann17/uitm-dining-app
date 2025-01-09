import 'dart:convert';

import 'package:fypfinal/Models/orderItem.dart';

class Order {
  int? orderId;
  final int studentId;
  final int cafeId;
  final DateTime orderDate;
  final double totalPrice;
  final String orderStatus;
  final List<OrderItem> items;

  Order({
    this.orderId,
    required this.studentId,
    required this.cafeId,
    required this.orderDate,
    required this.totalPrice,
    required this.orderStatus,
    required this.items,
  });

  @override
  String toString() {
    return 'Order ID: $orderId, Student ID: $studentId, Cafe ID: $cafeId, Order Date: $orderDate, Total Price: $totalPrice, Order Status: $orderStatus, Items: $items';
  }

  factory Order.fromMap(Map<String, dynamic> json) {
    // Parse order items
    List<OrderItem> items = [];
    List<String> itemMenuIds = (json['itemMenuIds'] ?? '').split(',');
    List<String> itemQuantities = (json['itemQuantities'] ?? '').split(',');
    List<String> itemPrices = (json['itemPrices'] ?? '').split(',');
    for (int i = 0; i < itemMenuIds.length; i++) {
      items.add(OrderItem(
        menuId: int.parse(itemMenuIds[i]),
        quantity: int.parse(itemQuantities[i]),
        menuPrice: double.parse(itemPrices[i]),
      ));
    }

    return Order(
      orderId: json["orderId"] as int?,
      studentId: json["studentId"] as int,
      cafeId: json["cafeId"] as int,
      orderDate: DateTime.parse(json["orderDate"] as String),
      totalPrice: (json["totalPrice"] ?? 0.0) as double,
      orderStatus: json["orderStatus"] as String,
      items: items,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'studentId': studentId,
      'cafeId': cafeId,
      'orderDate': orderDate.toIso8601String(),
      'totalPrice': totalPrice,
      'orderStatus': orderStatus,
      'items': jsonEncode(items
          .map((item) => item.toMap())
          .toList()), // Convert items to JSON string
    };
  }
}
