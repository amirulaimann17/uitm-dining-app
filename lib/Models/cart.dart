class Cart {
  int? studentId;
  int? menuId;
  int? cafeId; // Added cafeId
  int quantity;
  String dateAdded;

  Cart({
    this.studentId,
    this.menuId,
    this.cafeId,
    required this.quantity,
    required this.dateAdded,
  });

  factory Cart.fromMap(Map<String, dynamic> json) => Cart(
        studentId: json["studentId"],
        menuId: json["menuId"],
        cafeId: json["cafeId"],
        quantity: json["quantity"],
        dateAdded: json["dateAdded"],
      );

  Map<String, dynamic> toMap() => {
        "studentId": studentId,
        "menuId": menuId,
        "cafeId": cafeId,
        "quantity": quantity,
        "dateAdded": dateAdded,
      };
}
