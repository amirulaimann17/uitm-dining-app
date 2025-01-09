class Student {
  int? studentId;
  String studentName;
  String studentEmail;
  String studentPassword;
  List<String>? favoriteCafes; // Optional field for list of favorite cafes

  Student({
    this.studentId,
    required this.studentName,
    required this.studentEmail,
    required this.studentPassword,
    this.favoriteCafes, // Marked as optional in constructor
  });

  factory Student.fromMap(Map<String, dynamic> json) => Student(
        studentId: json["studentId"],
        studentName: json["studentName"],
        studentEmail: json["studentEmail"],
        studentPassword: json["studentPassword"],
        favoriteCafes: json["favoriteCafes"] != null
            ? List<String>.from(json["favoriteCafes"])
            : null, // Parse list if not null
      );

  Map<String, dynamic> toMap() {
    return {
      "studentId": studentId,
      "studentName": studentName,
      "studentEmail": studentEmail,
      "studentPassword": studentPassword,
      "favoriteCafes": favoriteCafes, // Include if not null
    };
  }
}
