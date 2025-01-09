// ignore_for_file: file_names, library_private_types_in_public_api, deprecated_member_use

import 'dart:io';

import 'package:fypfinal/AdminView/ViewSelectionPage.dart';
import 'package:fypfinal/Models/cafe.dart';
import 'package:fypfinal/SQLite/sqlite.dart';
import 'package:flutter/material.dart';
import 'package:fypfinal/appStyle.dart';
import 'package:fypfinal/cafeView/updateCafeDetails.dart';
import 'package:geocoding/geocoding.dart';

class ViewCafesPage extends StatefulWidget {
  const ViewCafesPage({super.key});

  @override
  _ViewCafesPageState createState() => _ViewCafesPageState();
}

class _ViewCafesPageState extends State<ViewCafesPage> {
  late List<Cafes> cafes;
  final DatabaseHelper db = DatabaseHelper();
  late Color myColor;
  late Size mediaSize;

  @override
  void initState() {
    super.initState();
    cafes = [];
    refreshCafes();
  }

  Future<void> refreshCafes() async {
    try {
      final List<Cafes> cafeList = await db.getAllCafes();
      setState(() {
        cafes = cafeList;
      });
    } catch (e) {
      // Handle the error as needed (e.g., show an error message)
    }
  }

  @override
  Widget build(BuildContext context) {
    myColor = AppStyles.primaryColor(context);
    mediaSize = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ViewSelectionPage()),
        );
        return false;
      },
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage("assets/bg.png"),
            fit: BoxFit.cover,
            colorFilter:
                ColorFilter.mode(myColor.withOpacity(0.2), BlendMode.dstATop),
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title
                const SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      'Cafes List',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // Cafe List
                Expanded(
                  child: _buildCafeList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCafeList() {
    return RefreshIndicator(
      onRefresh: refreshCafes,
      child: ListView.builder(
        itemCount: cafes.length,
        itemBuilder: (context, index) {
          return ExpansionTile(
            title: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image.file(
                    File(cafes[index].cafeImage),
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16), // Add space between image and text
                white((cafes[index].cafeName)),
              ],
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCafeDetails(cafes[index]),
                    const SizedBox(height: 16), // Add some space
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            if (cafes[index].cafeId != null) {
                              // Call deleteCafe method
                              _deleteCafe(cafes[index].cafeId!);
                            }
                          },
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.white, // Set icon color to white
                          ),
                          label: white('Delete'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.red, // Set background color to red
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () {
                            if (cafes[index].cafeId != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UpdateCafeDetailsPage(
                                      cafeId: cafes[index].cafeId!),
                                ),
                              );
                            }
                          },
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.white,
                          ),
                          label: white('Edit'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors
                                .deepPurple, // Set background color to red
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget white(String text) {
    return Text(
      text,
      style: const TextStyle(color: Colors.white),
    );
  }

  Widget _buildCafeDetails(Cafes cafe) {
    final locationParts = cafe.cafeLocation.split(',');
    final latitude = double.tryParse(locationParts[0]) ?? 0.0;
    final longitude = double.tryParse(locationParts[1]) ?? 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        white('ID: ${cafe.cafeId}'),
        white('Name: ${cafe.cafeName}'),
        white('Username: ${cafe.cafeUsername}'),
        white('Password: ${cafe.cafePassword}'),
        FutureBuilder<List<Placemark>>(
          future: placemarkFromCoordinates(latitude, longitude),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.white));
            } else {
              final placemarks = snapshot.data;
              if (placemarks != null && placemarks.isNotEmpty) {
                final firstPlacemark = placemarks.first;
                return white(
                  'Location: ${firstPlacemark.street}, ${firstPlacemark.locality}, ${firstPlacemark.administrativeArea}, ${firstPlacemark.country}',
                );
              } else {
                return const Text('Address not found.',
                    style: TextStyle(color: Colors.white));
              }
            }
          },
        ),
        white('Operation Hours: ${cafe.operationHours}'),
        white('Is Open: ${cafe.isOpen ? 'Yes' : 'No'}'),
        // Display ratings if needed
        if (cafe.ratings.isNotEmpty) ...[
          white('Ratings:'),
          for (var rating in cafe.ratings)
            white(
              'Rating: ${rating.rating}, Comment: ${rating.comment}, Timestamp: ${rating.timestamp}',
            ),
        ],
      ],
    );
  }

  Future<void> _deleteCafe(int cafeId) async {
    final confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this cafe?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, false); // User canceled deletion
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, true); // User confirmed deletion
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final result = await db.deleteCafe(cafeId);
      if (result > 0) {
        // If deletion is successful, refresh the cafe list
        refreshCafes();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cafe deleted successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete cafe')),
        );
      }
    }
  }
}
