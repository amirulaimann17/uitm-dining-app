import 'package:flutter/material.dart';
import 'package:fypfinal/SQLite/sqlite.dart';
import 'package:fypfinal/appStyle.dart';
import 'package:intl/intl.dart';

class WhiteText extends StatelessWidget {
  final String text;

  const WhiteText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(color: Colors.white),
    );
  }
}

class RatingPage extends StatefulWidget {
  final int cafeId;
  final int studentId;

  const RatingPage({required this.cafeId, required this.studentId, super.key});

  @override
  _RatingPageState createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  int _rating = 0;
  final TextEditingController _commentController = TextEditingController();
  late Color myColor;
  List<Map<String, dynamic>> _ratings = [];

  @override
  void initState() {
    super.initState();
    _displayRatings();
  }

  Future<void> _displayRatings() async {
    final DatabaseHelper dbHelper = DatabaseHelper();
    final List<Map<String, dynamic>> ratings =
        await dbHelper.getAllRatingsByCafeId(widget.cafeId);
    setState(() {
      _ratings = ratings;
    });
  }

  // Count the occurrences of each rating value
  Map<int, int> _countRatings() {
    final Map<int, int> countMap = {
      1: 0,
      2: 0,
      3: 0,
      4: 0,
      5: 0,
    };
    for (var rating in _ratings) {
      final int value = rating['rating'];
      countMap[value] = (countMap[value] ?? 0) + 1;
    }
    return countMap;
  }

  Widget _buildAddRatingStarIcon(int rating) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          5,
          (index) => GestureDetector(
            onTap: () {
              setState(() {
                _rating = index + 1;
              });
            },
            child: Icon(
              index < rating ? Icons.star : Icons.star_border,
              color: Colors.orange,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListRatingStarIcon(int rating) {
    return Row(
      children: List.generate(
        5,
        (index) => Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.orange,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    myColor = AppStyles.primaryColor(context);
    final Map<int, int> ratingCounts = _countRatings();
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'Ratings and Reviews',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage("assets/bg.png"),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.7),
                  BlendMode.darken,
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          // Display the rating statistics using graphical bars
                          for (int i = 5; i >= 1; i--)
                            Row(
                              children: [
                                Text(
                                  '$i ',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Icon(
                                  Icons.star,
                                  color: Colors.orange,
                                  size: 15,
                                ),
                                const SizedBox(width: 10),
                                SizedBox(
                                  width: 250,
                                  height: 6,
                                  child: LinearProgressIndicator(
                                    value: _ratings.isNotEmpty
                                        ? ratingCounts[i]! / _ratings.length
                                        : 0.0,
                                    backgroundColor: Colors.grey[700],
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                      Colors.orange,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  '${ratingCounts[i]}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Center(
                      child: Text(
                        'Rating',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 7),
                    Center(child: _buildAddRatingStarIcon(_rating)),
                    const SizedBox(height: 20),
                    const WhiteText(
                      'Comment',
                    ),
                    TextField(
                      controller: _commentController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Enter your comment',
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                        ),
                        border: const OutlineInputBorder(),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        final int result = await _addRating(
                          _rating,
                          _commentController.text,
                        );
                        if (result > 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Rating added successfully'),
                            ),
                          );
                          Navigator.pop(context); // Return to previous screen
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Failed to add rating'),
                            ),
                          );
                        }
                      },
                      child: const Text('Submit Rating'),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      'Comments',
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _ratings.length,
                      itemBuilder: (context, index) {
                        final rating = _ratings.reversed.toList()[index];
                        return ListTile(
                          leading: CircleAvatar(
                            child: Text(
                              rating['studentName'][0],
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            '${rating['studentName']}',
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildListRatingStarIcon(rating['rating']),
                              WhiteText('${rating['comment']}'),
                              Text(
                                  DateFormat('yyyy-MM-dd HH:mm:ss').format(
                                    DateTime.parse(rating['timestamp']),
                                  ),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w100,
                                  )),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<int> _addRating(int rating, String comment) async {
    try {
      final DatabaseHelper dbHelper = DatabaseHelper();
      final int result = await dbHelper.addRating(
        widget.cafeId,
        widget.studentId,
        rating,
        comment,
      );
      _displayRatings(); // Refresh the ratings list after adding a new rating
      return result;
    } catch (e) {
      return -1; // Return a negative value to indicate failure
    }
  }
}
