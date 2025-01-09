class FavoriteCafe {
  final int studentId;
  final int cafeId;

  FavoriteCafe({required this.studentId, required this.cafeId});

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'cafeId': cafeId,
    };
  }

  factory FavoriteCafe.fromMap(Map<String, dynamic> map) {
    return FavoriteCafe(
      studentId: map['studentId'],
      cafeId: map['cafeId'],
    );
  }
}
