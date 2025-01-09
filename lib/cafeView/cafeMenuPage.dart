// ignore_for_file: file_names, deprecated_member_use

import 'dart:io';
import 'package:fypfinal/Auth/userSelection.dart';
import 'package:fypfinal/Models/cafe.dart';
import 'package:fypfinal/Models/menu.dart';
import 'package:fypfinal/SQLite/sqlite.dart';
import 'package:fypfinal/cafeView/cafeDrawer.dart';
import 'package:fypfinal/cafeView/menuDetailsPage.dart';
import 'package:flutter/material.dart';
import 'package:fypfinal/appStyle.dart';
import 'package:fypfinal/cafeView/createMenu.dart';
import 'package:fypfinal/cafeView/updateCafeDetails.dart';
import 'package:fypfinal/mapView.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart';

class CafeMenuPage extends StatefulWidget {
  final int cafeId;
  const CafeMenuPage({required this.cafeId, super.key});

  @override
  State<CafeMenuPage> createState() => _CafeMenuPageState();
}

class _CafeMenuPageState extends State<CafeMenuPage> {
  late Color myColor;
  late Size mediaSize;
  int _currentIndex = 0;
  int _currentCategoryIndex = 0;
  late DatabaseHelper handler;
  late Future<List<MenuModel>> menu;
  final db = DatabaseHelper();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final menuName = TextEditingController();
  final menuPrice = TextEditingController();
  final menuDescription = TextEditingController();
  String? selectedCategory;
  final List<String> categories = [
    'Breakfast',
    'Lunch',
    'Dinner',
    'Drinks',
    'Dessert'
  ];

  String? menuImage;

  @override
  void initState() {
    handler = DatabaseHelper();
    menu = handler.getAllMenusByCafeId(widget.cafeId);

    handler.initDB().whenComplete(() {
      menu = getAllMenus();
    });
    super.initState();
  }

  Future<List<MenuModel>> getAllMenus() {
    return handler.getAllMenusByCafeId(widget.cafeId);
  }

  @override
  Widget build(BuildContext context) {
    myColor = AppStyles.primaryColor(context);
    mediaSize = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async {
        return _showLogoutConfirmationDialog(context);
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.transparent,
        drawer: CafeDrawer(cafeId: widget.cafeId),
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const AssetImage("assets/bg.png"),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    myColor.withOpacity(0.3),
                    BlendMode.dstATop,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 50,
              left: 10,
              child: GestureDetector(
                onTap: () {
                  _openDrawer();
                },
                child: const Icon(
                  Icons.menu,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
            _buildTop(isProfileTabActive: _currentIndex == 1),
            IndexedStack(
              index: _currentIndex,
              children: [
                _buildMenuList(),
                _buildProfile(),
              ],
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomNavigationBar(),
        floatingActionButton: _buildFloatingActionButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }

  void _openDrawer() {
    if (_scaffoldKey.currentState != null) {
      _scaffoldKey.currentState!.openDrawer();
    }
  }

  Future<bool> _showLogoutConfirmationDialog(BuildContext context) async {
    bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Log out and navigate back to user selection page
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const UserSelection()),
                );
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  Widget _buildTop({required bool isProfileTabActive}) {
    return FutureBuilder<Cafes?>(
      future: DatabaseHelper().getCafeDetails(widget.cafeId),
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
          return Positioned(
            top: 50,
            child: SizedBox(
              width: mediaSize.width,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    cafe.cafeName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 35,
                      letterSpacing: 2,
                    ),
                  ),
                  if (isProfileTabActive)
                    Positioned(
                      right: 0,
                      child: IconButton(
                        onPressed: () {
                          // Navigate to edit cafe details page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  UpdateCafeDetailsPage(cafeId: widget.cafeId),
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit),
                        color: Colors.white,
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

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      backgroundColor: Colors.white,
      selectedItemColor: Colors.deepPurple,
      unselectedItemColor: Colors.deepPurple.withOpacity(0.6),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.menu),
          label: 'Menu',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.coffee),
          label: 'Profile',
        ),
      ],
    );
  }

  Future<void> _refresh() async {
    setState(() {
      menu = getAllMenus();
    });
  }

  Widget _buildAvailabilityToggle(MenuModel menuItem) {
    return IconButton(
      icon: Icon(
        menuItem.isAvailable ? Icons.check_box : Icons.check_box_outline_blank,
        color: menuItem.isAvailable ? Colors.green : Colors.grey,
      ),
      onPressed: () {
        setState(() {
          menuItem.isAvailable = !menuItem.isAvailable;
        });
        handler.updateMenuAvailability(menuItem.menuId!, menuItem.isAvailable);
      },
    );
  }

  Widget _buildMenuList() {
    return Padding(
      padding: const EdgeInsets.only(top: 60.0), // Reduce top padding
      child: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<MenuModel>>(
          future: menu,
          builder:
              (BuildContext context, AsyncSnapshot<List<MenuModel>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            } else {
              final items = snapshot.data ?? <MenuModel>[];

              // Group menu items by category
              Map<String, List<MenuModel>> groupedItems = {};
              for (var item in items) {
                if (!groupedItems.containsKey(item.menuCategory)) {
                  groupedItems[item.menuCategory] = [];
                }
                groupedItems[item.menuCategory]!.add(item);
              }

              List<String> categories = groupedItems.keys.toList();

              return ListView(
                children: [
                  SizedBox(
                    height: 30,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          // Inside the GestureDetector onTap callback
                          onTap: () {
                            if (index < categories.length) {
                              // Add this condition to check bounds
                              setState(() {
                                _currentCategoryIndex = index;
                              });
                            }
                          },
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              categories[index],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20.0,
                                color: index == _currentCategoryIndex
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.5),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      if (_currentCategoryIndex < categories.length) {
                        String category = items[index].menuCategory;
                        if (category != categories[_currentCategoryIndex]) {
                          return const SizedBox();
                        } else {
                          MenuModel item = items[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: ListTile(
                                      leading: Image.file(
                                        File(item.menuImage),
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      ),
                                      title: Text(
                                        item.menuName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16.0,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            NumberFormat.currency(
                                              symbol: 'RM',
                                              decimalDigits: 2,
                                            ).format(item.menuPrice),
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 13.0,
                                            ),
                                          ),
                                          Text(
                                            item.menuCategory,
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 13.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                MenuDetailsPage(menuItem: item),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _buildUpdateButton(item),
                                      _buildDeleteButton(item),
                                      _buildAvailabilityToggle(item),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      } else {
                        return const SizedBox();
                      }
                    },
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildProfile() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(45.0, 60.0, 45.0, 45.0),
      child: Column(
        children: [
          Expanded(
            child: FutureBuilder<Cafes?>(
              future: DatabaseHelper().getCafeDetails(widget.cafeId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
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
                  return Padding(
                    padding: const EdgeInsets.only(top: 60.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20.0),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(40.0),
                          child: Image.file(
                            File(cafe.cafeImage),
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 6.0, horizontal: 10.0),
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
                                      return Center(
                                        // Center the text
                                        child: Text(
                                          'Location: ${firstPlacemark.street}, ${firstPlacemark.locality}, ${firstPlacemark.administrativeArea}, ${firstPlacemark.country}',
                                          style: const TextStyle(
                                            fontSize: 16.0,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign
                                              .center, // Center the text horizontally
                                        ),
                                      );
                                    } else {
                                      return const Center(
                                          child: Text('Address not found.'));
                                    }
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.map),
                              label: const Text('View on Map'),
                              onPressed: () {
                                // Navigate to the MapView page
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
                            const SizedBox(width: 10),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 10.0),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment
                                      .center, // Center the row horizontally
                                  children: [
                                    Text(
                                      'Operation Hours: ${cafe.operationHours}',
                                      style: const TextStyle(
                                        fontSize: 16.0,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Switch(
                                value: cafe.isOpen,
                                onChanged: (value) {
                                  setState(() {
                                    cafe.isOpen = value;
                                  });
                                  DatabaseHelper()
                                      .updateCafeStatus(cafe.cafeId, value);
                                },
                                activeColor: Colors.green,
                              ),
                            ),
                            Text(
                              cafe.isOpen ? 'Open' : 'Closed',
                              style: TextStyle(
                                color: cafe.isOpen ? Colors.green : Colors.red,
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign
                                  .center, // Center the text horizontally
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        // Navigate to the CreateMenu page
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => CreateMenu(cafeId: widget.cafeId)),
        );
      },
      shape: const CircleBorder(),
      elevation: 4.0,
      child: const Icon(Icons.add),
    );
  }

  Widget _buildDeleteButton(MenuModel menuItem) {
    return IconButton(
      icon: const Icon(Icons.delete),
      color: Colors.red,
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Confirm Deletion"),
              content: const Text("Are you sure you want to delete this menu?"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    handler.deleteMenu(menuItem.menuId!).whenComplete(() {
                      _refresh();
                      Navigator.pop(context);
                    });
                  },
                  child: const Text("Delete"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildUpdateButton(MenuModel menuItem) {
    return IconButton(
      icon: const Icon(Icons.edit),
      onPressed: () {
        setState(() {
          menuName.text = menuItem.menuName;
          menuPrice.text = NumberFormat.currency(symbol: 'RM', decimalDigits: 2)
              .format(menuItem.menuPrice);
          menuDescription.text = menuItem.menuDescription;
          selectedCategory = menuItem.menuCategory;
          // Set the initial value for the menuImage
          menuImage = menuItem.menuImage;
        });
        showDialog(
          context: context,
          builder: (context) {
            return SingleChildScrollView(
              child: AlertDialog(
                actions: [
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          double parsedPrice = double.tryParse(
                                  menuPrice.text.replaceAll("RM", "")) ??
                              0.0;
                          //Now update method
                          handler
                              .updateMenu(
                            menuName.text,
                            parsedPrice,
                            menuDescription.text,
                            selectedCategory,
                            menuImage,
                            menuItem.menuId!,
                          )
                              .whenComplete(() {
                            //After update, note will refresh
                            _refresh();
                            Navigator.pop(context);
                          });
                        },
                        child: const Text("Update"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("Cancel"),
                      ),
                    ],
                  ),
                ],
                title: const Text("Update menu"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: menuName,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Name is required";
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        label: Text("Menu Name"),
                      ),
                    ),
                    TextFormField(
                      controller: menuPrice,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Price is required";
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        label: Text("Price"),
                      ),
                    ),
                    TextFormField(
                      controller: menuDescription,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Description is required";
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        label: Text("Description"),
                      ),
                    ),
                    // Add an option to update the image
                    TextButton(
                      onPressed: _pickImage,
                      child: const Text("Update Image"),
                    ),
                    // Display the current image if available
                    menuImage != null
                        ? Image.file(
                            File(menuImage!),
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                          )
                        : const SizedBox(),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return "Category is required";
                        }
                        return null;
                      },
                      items: categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      decoration: const InputDecoration(
                        labelText: "Category",
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _pickImage() async {
    final XFile? selectedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    setState(() {
      menuImage = selectedImage?.path; // Set menuImage here
    });
  }
}
