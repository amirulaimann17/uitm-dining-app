import 'package:fypfinal/Models/rating.dart';

class Cafes {
  int? cafeId;
  String cafeName;
  String cafeUsername;
  String cafePassword;
  String cafeLocation;
  String cafeImage;
  String operationHours;
  bool isOpen;
  List<Rating> ratings;

  Cafes({
    this.cafeId,
    required this.cafeName,
    required this.cafeUsername,
    required this.cafePassword,
    required this.cafeLocation,
    required this.cafeImage,
    required this.operationHours,
    required this.isOpen,
    List<Rating>? ratings,
  }) : ratings = ratings ?? [];

  factory Cafes.fromMap(Map<String, dynamic> json) => Cafes(
        cafeId: json["cafeId"],
        cafeName: json["cafeName"],
        cafeUsername: json["cafeUsername"],
        cafePassword: json["cafePassword"],
        cafeLocation: json["cafeLocation"],
        cafeImage: json["cafeImage"],
        operationHours: json["operationHours"],
        isOpen: json["isOpen"] == 1,
      );

  Map<String, dynamic> toMap() => {
        "cafeId": cafeId,
        "cafeName": cafeName,
        "cafeUsername": cafeUsername,
        "cafePassword": cafePassword,
        "cafeLocation": cafeLocation,
        "cafeImage": cafeImage,
        "operationHours": operationHours,
        "isOpen": isOpen ? 1 : 0,
      };
}
