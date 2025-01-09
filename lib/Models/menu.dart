class MenuModel {
  int? menuId;
  String menuName;
  double menuPrice;
  String menuDescription;
  String menuCategory;
  int cafeId;
  String menuImage;
  bool isAvailable; // New field

  MenuModel({
    this.menuId,
    required this.menuName,
    required this.menuPrice,
    required this.menuDescription,
    required this.menuCategory,
    required this.cafeId,
    required this.menuImage,
    required this.isAvailable, // Initialize the new field
  });

  factory MenuModel.fromMap(Map<String, dynamic> json) => MenuModel(
        menuId: json["menuId"],
        menuName: json["menuName"],
        menuPrice: json["menuPrice"],
        menuDescription: json["menuDescription"],
        menuCategory: json["menuCategory"],
        cafeId: json["cafeId"],
        menuImage: json["menuImage"],
        isAvailable: json["isAvailable"] == 1, // Convert int to bool
      );

  Map<String, dynamic> toMap() => {
        "menuId": menuId,
        "menuName": menuName,
        "menuPrice": menuPrice,
        "menuDescription": menuDescription,
        "menuCategory": menuCategory,
        "cafeId": cafeId,
        "menuImage": menuImage,
        "isAvailable": isAvailable ? 1 : 0, // Convert bool to int
      };
}
