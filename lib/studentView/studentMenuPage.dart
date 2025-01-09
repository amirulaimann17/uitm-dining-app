import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fypfinal/mapView.dart';
import 'package:fypfinal/studentView/viewCartPage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:fypfinal/Models/cafe.dart';
import 'package:fypfinal/appStyle.dart';
import 'package:fypfinal/studentView/ratingPage.dart';
import 'package:fypfinal/Models/menu.dart';
import 'package:fypfinal/SQLite/sqlite.dart';
import 'package:fypfinal/cafeView/menuDetailsPage.dart';
import 'package:geocoding/geocoding.dart';

class StudentMenuPage extends StatefulWidget {
  final int cafeId;
  final int studentId;
  const StudentMenuPage(
      {required this.cafeId, required this.studentId, Key? key})
      : super(key: key);

  @override
  State<StudentMenuPage> createState() => _StudentMenuPageState();
}

class _StudentMenuPageState extends State<StudentMenuPage> {
  late Color myColor;
  late Size mediaSize;
  late DatabaseHelper handler;
  late Future<List<MenuModel>> menu;
  int? selectedCafeId;
  late Future<Cafes?> cafeFuture;
  final db = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    handler = DatabaseHelper();
    menu = handler.getAllMenusByCafeId(widget.cafeId);
    cafeFuture = handler.getCafeDetails(widget.cafeId);
    selectedCafeId = widget.cafeId;
  }

  @override
  Widget build(BuildContext context) {
    myColor = AppStyles.primaryColor(context);
    mediaSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              _buildTop(),
              _buildSearchBar(),
              _buildCategoryLabels(),
              Expanded(
                child: _buildMenuList(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTop() {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: FutureBuilder<Cafes?>(
        future: cafeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox(
              width: mediaSize.width,
              child: const CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            final cafe = snapshot.data;
            if (cafe == null) {
              return const Text('Cafe not found.');
            }
            final locationParts = cafe.cafeLocation.split(',');
            final latitude = double.tryParse(locationParts[0]) ?? 0.0;
            final longitude = double.tryParse(locationParts[1]) ?? 0.0;
            return SizedBox(
              width: mediaSize.width,
              height: mediaSize.height * 2.4 / 6,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.45),
                        BlendMode.darken,
                      ),
                      child: Image.file(
                        File(cafe.cafeImage),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              cafe.cafeName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 35,
                                letterSpacing: 2,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 6.0,
                                horizontal: 10.0,
                              ),
                              child: Text(
                                'Operation Hours: ${cafe.operationHours}',
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: cafe.isOpen ? Colors.green : Colors.red,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 4.0,
                                horizontal: 8.0,
                              ),
                              child: Text(
                                cafe.isOpen ? 'Open' : 'Closed',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 6.0,
                                horizontal: 70.0,
                              ),
                              child: FutureBuilder<List<Placemark>>(
                                future: placemarkFromCoordinates(
                                    latitude, longitude),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  } else if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  } else {
                                    final placemarks = snapshot.data;
                                    if (placemarks != null &&
                                        placemarks.isNotEmpty) {
                                      final firstPlacemark = placemarks.first;
                                      return Text(
                                        'Location: ${firstPlacemark.street}, ${firstPlacemark.locality}, ${firstPlacemark.administrativeArea}, ${firstPlacemark.country}',
                                        style: const TextStyle(
                                          fontSize: 16.0,
                                          color: Colors.white,
                                        ),
                                      );
                                    } else {
                                      return const Text('Address not found.');
                                    }
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 80.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.black,
                                        backgroundColor: Colors.white,
                                      ),
                                      icon: const Icon(Icons.map),
                                      label: const SizedBox.shrink(),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => MapView(
                                              initialLocation:
                                                  LatLng(latitude, longitude),
                                              cafeName: cafe.cafeName,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.yellow,
                                        backgroundColor: Colors.white,
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => RatingPage(
                                              cafeId: selectedCafeId!,
                                              studentId: widget.studentId,
                                            ),
                                          ),
                                        );
                                      },
                                      icon: Row(
                                        children: [
                                          const Icon(
                                            Icons.star,
                                            color: Colors.yellow,
                                          ),
                                          _buildAverageRating(cafe.cafeId!),
                                        ],
                                      ),
                                      label: const SizedBox.shrink(),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildCategoryLabels() {
    return FutureBuilder<List<MenuModel>>(
      future: menu,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          final items = snapshot.data ?? [];
          // Group menu items by category
          Map<String, List<MenuModel>> groupedItems = {};
          for (var item in items) {
            if (!groupedItems.containsKey(item.menuCategory)) {
              groupedItems[item.menuCategory] = [];
            }
            groupedItems[item.menuCategory]!.add(item);
          }

          // Extract category labels
          List<String> categories = groupedItems.keys.toList();

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Row(
              children: categories.map((category) {
                return GestureDetector(
                  onTap: () {
                    // Filter menu items by selected category
                    setState(() {
                      menu = handler
                          .getAllMenusByCafeId(widget.cafeId)
                          .then((menuList) {
                        return menuList
                            .where((menu) => menu.menuCategory == category)
                            .toList();
                      });
                    });
                  },
                  child: Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(right: 16.0),
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: myColor.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Text(
                      category,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }
      },
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search for menu...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        onChanged: (value) {
          // Call a method to handle menu search
          searchMenu(value);
        },
      ),
    );
  }

  void searchMenu(String query) {
    setState(() {
      menu = handler.getAllMenusByCafeId(widget.cafeId).then((menuList) {
        return menuList
            .where((menu) =>
                menu.menuName.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    });
  }

  Future<void> _refresh() async {
    setState(() {
      menu = handler.getAllMenusByCafeId(widget.cafeId);
      cafeFuture = handler.getCafeDetails(widget.cafeId);
    });
  }

  Widget _buildMenuList() {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: FutureBuilder<List<MenuModel>>(
        future: menu,
        builder:
            (BuildContext context, AsyncSnapshot<List<MenuModel>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isEmpty) {
            return const Center(child: Text("No menu available"));
          } else {
            final items = snapshot.data ?? [];

            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
              ),
              padding: const EdgeInsets.only(top: 8.0),
              itemCount: items.length,
              itemBuilder: (context, index) {
                // Check if the item is available
                if (items[index].isAvailable) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.6),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MenuDetailsPage(
                                    menuItem: items[index],
                                  ),
                                ),
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Image.file(
                                  File(items[index].menuImage),
                                  width: double.maxFinite,
                                  height:
                                      (MediaQuery.of(context).size.width / 2) *
                                          0.8,
                                  fit: BoxFit.cover,
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                  items[index].menuName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0,
                                  ),
                                ),
                                const SizedBox(height: 4.0),
                                Text(
                                  NumberFormat.currency(
                                    symbol: 'RM',
                                    decimalDigits: 2,
                                  ).format(items[index].menuPrice),
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13.0,
                                  ),
                                ),
                                const SizedBox(height: 4.0),
                                Text(
                                  items[index].menuCategory,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 8.0,
                          right: 8.0,
                          child: GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext dialogContext) {
                                  return AlertDialog(
                                    title: const Text('Add to Cart'),
                                    content: const Text(
                                      'Do you want to add this item to your cart?',
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(dialogContext)
                                              .pop(); // Close the dialog
                                        },
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          // Check if item is available before adding to cart
                                          if (items[index].isAvailable) {
                                            await db.addToCart(
                                              widget.studentId,
                                              items[index]
                                                  .menuId!, // Assuming menuId is the selected menu item
                                              widget.cafeId,
                                              1, // Assuming the quantity is 1
                                            );
                                            Navigator.of(dialogContext)
                                                .pop(); // Close the dialog

                                            // Show success snackbar with action to navigate to cart using the original context
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: const Text(
                                                    'Item successfully added to cart'),
                                                action: SnackBarAction(
                                                  label: 'View Cart',
                                                  onPressed: () {
                                                    // Navigate to the view cart page
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            ViewCartPage(
                                                          studentId:
                                                              widget.studentId,
                                                        ), // Replace with your cart page
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            );
                                          } else {
                                            // Show error message if item is not available
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'This item is not available'),
                                              ),
                                            );
                                          }
                                        },
                                        child: const Text('Add'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: const BoxDecoration(
                                color: Colors.deepPurple,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  // Render a disabled item if it's not available
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.6),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.file(
                            File(items[index].menuImage),
                            width: double.maxFinite,
                            height:
                                (MediaQuery.of(context).size.width / 2) * 0.8,
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            items[index].menuName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            NumberFormat.currency(
                              symbol: 'RM',
                              decimalDigits: 2,
                            ).format(items[index].menuPrice),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 13.0,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            items[index].menuCategory,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 13.0,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          const Text(
                            'Not Available',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildAverageRating(int cafeId) {
    return FutureBuilder<double?>(
      future: handler.calculateAverageRating(cafeId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          final averageRating = snapshot.data;
          return Text(
            averageRating != null ? averageRating.toStringAsFixed(1) : 'N/A',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          );
        }
      },
    );
  }
}
