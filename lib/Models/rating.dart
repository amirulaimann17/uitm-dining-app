class Rating {
  final int? ratingId;
  final int? cafeId;
  final int? studentId;
  final double rating;
  final String? comment;
  final DateTime timestamp;

  Rating({
    this.ratingId,
    this.cafeId,
    this.studentId,
    this.rating = 5, // Default value set to 5.0
    this.comment,
    required this.timestamp,
  });

  factory Rating.fromMap(Map<String, dynamic> json) => Rating(
        ratingId: json['ratingId'],
        cafeId: json['cafeId'],
        studentId: json['studentId'],
        rating: json['rating'],
        comment: json['comment'],
        timestamp: DateTime.parse(json['timestamp']),
      );

  Map<String, dynamic> toMap() => {
        'ratingId': ratingId,
        'cafeId': cafeId,
        'studentId': studentId,
        'rating': rating,
        'comment': comment,
        'timestamp': timestamp.toIso8601String(),
      };

  static double calculateAverageRating(List<Rating> ratings) {
    if (ratings.isEmpty) {
      return 0.0; // Return 0 if no ratings yet
    }
    double sum = 0;
    for (var rating in ratings) {
      sum += rating.rating;
    }
    return sum / ratings.length; // Calculate the average rating
  }
}
