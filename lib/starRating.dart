// ignore_for_file: file_names

import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final double rating;
  final int starCount;
  final double size;
  final Color color;

  const StarRating({
    super.key,
    required this.rating,
    this.starCount = 1,
    this.size = 24,
    this.color = Colors.yellow,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(starCount, (index) {
        if (index < rating) {
          return Icon(
            Icons.star,
            size: size,
            color: color,
          );
        } else {
          return Icon(
            Icons.star_border,
            size: size,
            color: color,
          );
        }
      }),
    );
  }
}
