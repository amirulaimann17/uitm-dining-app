// ignore_for_file: file_names, deprecated_member_use

import 'dart:io';
import 'package:fypfinal/Auth/userSelection.dart';
import 'package:fypfinal/Models/student.dart';
import 'package:fypfinal/studentView/customDrawer.dart';
import 'package:fypfinal/studentView/studentFavCafePage.dart';
import 'package:fypfinal/studentView/studentMenuPage.dart';
import 'package:flutter/material.dart';
import 'package:fypfinal/appStyle.dart';
import 'package:fypfinal/Models/cafe.dart';
import 'package:fypfinal/SQLite/sqlite.dart';

class StudentCafePage extends StatefulWidget {
  final int studentId;
  const StudentCafePage({required this.studentId, super.key, int? cafeId});

  @override
  State<StudentCafePage> createState() => _StudentCafePageState();
}

class _StudentCafePageState extends State<StudentCafePage> {
  late Color myColor;
  late Size mediaSize;
  int _currentIndex = 0;
  late DatabaseHelper handler;
  late Future<List<Cafes>> cafes;
  late Future<Student?> student;
  int? selectedCafeId;
  final db = DatabaseHelper();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final studentName = TextEditingController();
  final studentEmail = TextEditingController();
  final studentPassword = TextEditingController();

  @override
  void initState() {
    handler = DatabaseHelper();
    cafes = handler.getAllCafes();
    student = handler.getStudentDetails(widget.studentId);

    handler.initDB().whenComplete(() {
      cafes = getAllCafes();
    });
    super.initState();
  }

  Future<List<Cafes>> getAllCafes() {
    return handler.getAllCafes();
  }

  Future<Student?> getStudentDetails() {
    return handler.getStudentDetails(widget.studentId);
  }

  @override
  Widget build(BuildContext context) {
    myColor = AppStyles.primaryColor(context);
    mediaSize = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async {
        // Show confirmation dialog when back button is pressed
        return _showLogoutConfirmationDialog(context);
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const AssetImage("assets/bg.png"),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    myColor.withOpacity(0.2),
                    BlendMode.dstATop,
                  ),
                ),
              ),
            ),
            _buildTop(),
            IndexedStack(
              index: _currentIndex,
              children: [
                _buildCafeList(),
                FavoriteCafesPage(studentId: widget.studentId),
                _buildProfileDetails(),
              ],
            ),
            Positioned(
              bottom: 15,
              left: 10,
              right: 10,
              child: _buildBottomNavigationBar(),
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
          ],
        ),
        drawer: CustomDrawer(studentId: widget.studentId),
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

    return result ?? false; // Return false if showDialog returns null
  }

  Widget _buildTop() {
    return Positioned(
      top: 50,
      child: SizedBox(
        width: mediaSize.width,
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Palam",
                  style: TextStyle(
                    color: Colors.deepPurpleAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 35,
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  "Cafes",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 35,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.deepPurple.withOpacity(0.6),
        elevation: 0.0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Future<void> _refresh() async {
    setState(() {
      cafes = getAllCafes();
    });
  }

  Future<void> _refreshProfile() async {
    final updatedStudent = await getStudentDetails();
    setState(() {
      student = Future.value(updatedStudent);
    });
  }

  Widget _buildCafeList() {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const UserSelection()),
        );
        return false;
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 60.0),
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: Stack(
            children: [
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  Expanded(
                    child: FutureBuilder<List<Cafes>>(
                      future: cafes,
                      builder: (BuildContext context,
                          AsyncSnapshot<List<Cafes>> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                          return const Center(
                              child: Text("No cafes available"));
                        } else if (snapshot.hasError) {
                          return Center(child: Text(snapshot.error.toString()));
                        } else {
                          final items = snapshot.data ?? <Cafes>[];

                          return GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.7,
                            ),
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final cafe = items[index];
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  padding: const EdgeInsets.all(10.0),
                                  decoration: BoxDecoration(
                                    color: cafe.isOpen
                                        ? Colors.white
                                        : Colors.grey.withOpacity(0.95),
                                    borderRadius: BorderRadius.circular(12.0),
                                    boxShadow: cafe.isOpen
                                        ? [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.6),
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
                                            selectedCafeId = cafe.cafeId;
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    StudentMenuPage(
                                                  cafeId: selectedCafeId!,
                                                  studentId: widget.studentId,
                                                ),
                                              ),
                                            );
                                          }
                                        : null, // Disable tap if cafe is closed
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Stack(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              child: ColorFiltered(
                                                colorFilter: cafe.isOpen
                                                    ? const ColorFilter.mode(
                                                        Colors.transparent,
                                                        BlendMode.multiply)
                                                    : ColorFilter.mode(
                                                        Colors.black
                                                            .withOpacity(0.5),
                                                        BlendMode.darken),
                                                child: Image.file(
                                                  File(cafe.cafeImage),
                                                  width: double.maxFinite,
                                                  height:
                                                      (MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              2) -
                                                          32,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 8.0),
                                            FutureBuilder<bool>(
                                              future:
                                                  _isCafeFavorite(cafe.cafeId),
                                              builder: (BuildContext context,
                                                  AsyncSnapshot<bool>
                                                      snapshot) {
                                                if (snapshot.connectionState ==
                                                    ConnectionState.waiting) {
                                                  return const CircularProgressIndicator();
                                                } else if (snapshot.hasError) {
                                                  return const Icon(
                                                      Icons.favorite_border);
                                                } else {
                                                  final bool isFavorite =
                                                      snapshot.data ?? false;
                                                  return Positioned(
                                                    top: 8,
                                                    right: 8,
                                                    child: CircleAvatar(
                                                      backgroundColor:
                                                          Colors.white,
                                                      child: IconButton(
                                                        icon: Icon(
                                                          isFavorite
                                                              ? Icons.favorite
                                                              : Icons
                                                                  .favorite_border,
                                                          color: isFavorite
                                                              ? Colors.red
                                                              : null,
                                                        ),
                                                        onPressed: () {
                                                          if (isFavorite) {
                                                            _removeCafeFromFavorites(
                                                                cafe.cafeId!);
                                                          } else {
                                                            _addCafeToFavorites(
                                                                cafe.cafeId!);
                                                          }
                                                        },
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
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
                                        const SizedBox(height: 5.0),
                                        Text(
                                          cafe.operationHours,
                                          style: TextStyle(
                                            fontSize: 13.0,
                                            color: Colors.grey.withOpacity(0.8),
                                          ),
                                        ),
                                        Text(
                                          cafe.isOpen ? 'Open' : 'Closed',
                                          style: TextStyle(
                                            color: cafe.isOpen
                                                ? Colors.green
                                                : Colors.red,
                                            fontSize: 13.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _isCafeFavorite(int? cafeId) async {
    if (cafeId == null) {
      return false;
    }
    return await handler.isCafeFavorite(widget.studentId, cafeId);
  }

  void _addCafeToFavorites(int cafeId) async {
    await handler.addCafeToFavorites(widget.studentId, cafeId);
    _refresh();
  }

  void _removeCafeFromFavorites(int cafeId) async {
    await handler.removeCafeFromFavorites(widget.studentId, cafeId);
    _refresh();
  }

  Widget _buildProfileDetails() {
    return RefreshIndicator(
      onRefresh: _refreshProfile,
      child: FutureBuilder<Student?>(
        future: student,
        builder: (BuildContext context, AsyncSnapshot<Student?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.hasData && snapshot.data != null) {
            final student = snapshot.data!;
            return Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 160.0, horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Opacity(
                          opacity: 0.7, // Set the opacity value
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 50,
                            child: Text(
                              student.studentName.isNotEmpty
                                  ? student.studentName[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                color: Colors.deepPurple,
                                fontSize: 45,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    ListTile(
                      title: const Text('Student Name',
                          style: TextStyle(color: Colors.white)),
                      subtitle: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(student.studentName,
                            style: TextStyle(
                                color: Colors.black.withOpacity(0.5))),
                      ),
                    ),
                    ListTile(
                      title: const Text('Student ID',
                          style: TextStyle(color: Colors.white)),
                      subtitle: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(student.studentId.toString(),
                            style: TextStyle(
                                color: Colors.black.withOpacity(0.5))),
                      ),
                    ),
                    ListTile(
                      title: const Text('Student Email',
                          style: TextStyle(color: Colors.white)),
                      subtitle: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(student.studentEmail,
                            style: TextStyle(
                                color: Colors.black.withOpacity(0.5))),
                      ),
                    ),
                    ListTile(
                      title: const Text('Student Password',
                          style: TextStyle(color: Colors.white)),
                      subtitle: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(
                          '•' * student.studentPassword.length,
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.5),
                            letterSpacing: 2.0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildUpdateButton(student),
                  ],
                ),
              ),
            );
          } else {
            return const Text('No student details found');
          }
        },
      ),
    );
  }

  Widget _buildUpdateButton(Student student) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            setState(() {
              studentName.text = student.studentName;
              studentEmail.text = student.studentEmail;
              studentPassword.text = student.studentPassword;
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
                              //Now update method
                              handler
                                  .updateStudent(
                                studentName.text,
                                studentEmail.text,
                                studentPassword.text,
                                student.studentId!,
                              )
                                  .whenComplete(() {
                                _refreshProfile();
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
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        TextFormField(
                          controller: studentName,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Name is required";
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            labelText: "Name",
                          ),
                        ),
                        TextFormField(
                          controller: studentEmail,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Email is required";
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            labelText: "Email",
                          ),
                        ),
                        TextFormField(
                          controller: studentPassword,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "password is required";
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            labelText: "Password",
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
