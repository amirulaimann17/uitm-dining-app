import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fypfinal/Models/cafe.dart';
import 'package:fypfinal/SQLite/sqlite.dart';
import 'package:fypfinal/studentView/studentMenuPage.dart';
import 'package:fypfinal/appStyle.dart';

class FavoriteCafesPage extends StatefulWidget {
  final int studentId;
  const FavoriteCafesPage({super.key, required this.studentId});

  @override
  _FavoriteCafesPageState createState() => _FavoriteCafesPageState();
}

class _FavoriteCafesPageState extends State<FavoriteCafesPage> {
  late Color myColor;
  late Size mediaSize;
  late Future<List<Cafes>?> favoriteCafes;
  late DatabaseHelper handler;

  @override
  void initState() {
    super.initState();
    handler = DatabaseHelper();
    favoriteCafes = _getFavoriteCafes();
  }

  Future<List<Cafes>?> _getFavoriteCafes() async {
    return handler.getFavoriteCafes(widget.studentId);
  }

  Future<void> _refreshFavoriteCafes() async {
    setState(() {
      favoriteCafes = _getFavoriteCafes();
    });
  }

  @override
  Widget build(BuildContext context) {
    myColor = AppStyles.primaryColor(context);
    mediaSize = MediaQuery.of(context).size;

    return Scaffold(
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
          _buildTopBar(),
          _buildFavoriteCafesList(),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 50,
      child: SizedBox(
        width: mediaSize.width,
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Favorite Cafes",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 30,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteCafesList() {
    return RefreshIndicator(
      onRefresh: _refreshFavoriteCafes,
      child: FutureBuilder<List<Cafes>?>(
        future: favoriteCafes,
        builder: (BuildContext context, AsyncSnapshot<List<Cafes>?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final favoriteCafes = snapshot.data ?? [];
            return Stack(
              children: [
                GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                  ),
                  padding: const EdgeInsets.only(top: 120.0),
                  itemCount: favoriteCafes.isEmpty ? 1 : favoriteCafes.length,
                  itemBuilder: (context, index) {
                    if (favoriteCafes.isEmpty) {
                      return Container(); // Return an empty container for the overlay
                    } else {
                      return _buildCafeItem(favoriteCafes[index]);
                    }
                  },
                ),
                if (favoriteCafes.isEmpty)
                  const Center(
                    child: Text(
                      "No favorite cafes",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildCafeItem(Cafes cafe) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: cafe.isOpen ? Colors.white : Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: cafe.isOpen
              ? [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.6),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: GestureDetector(
          onTap: cafe.isOpen
              ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StudentMenuPage(
                        cafeId: cafe.cafeId!,
                        studentId: widget.studentId,
                      ),
                    ),
                  );
                }
              : null, // Disable tap if cafe is closed
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Image.file(
                      File(cafe.cafeImage),
                      width: double.maxFinite,
                      height: (MediaQuery.of(context).size.width / 2) - 32,
                      fit: BoxFit.cover,
                      color: cafe.isOpen ? null : Colors.grey,
                      colorBlendMode: cafe.isOpen ? null : BlendMode.saturation,
                    ),
                  ),
                  if (!cafe.isOpen)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8.0),
              Text(
                cafe.cafeName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                cafe.operationHours,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 13.0,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                cafe.isOpen ? 'Open' : 'Closed',
                style: TextStyle(
                  color: cafe.isOpen ? Colors.green : Colors.red,
                  fontSize: 13.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
