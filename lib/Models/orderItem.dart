class OrderItem {
  final int menuId;
  final int quantity;
  final double menuPrice;

  OrderItem({
    required this.menuId,
    required this.quantity,
    required this.menuPrice,
  });

  @override
  String toString() {
    return 'Menu ID: $menuId, Quantity: $quantity, Menu Price: $menuPrice';
  }

  factory OrderItem.fromMap(Map<String, dynamic> json) => OrderItem(
        menuId: json["menuId"],
        quantity: json["quantity"],
        menuPrice: json["menuPrice"],
      );

  Map<String, dynamic> toMap() => {
        'menuId': menuId,
        'quantity': quantity,
        'menuPrice': menuPrice,
      };
}
