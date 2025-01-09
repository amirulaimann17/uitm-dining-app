// ignore_for_file: file_names, avoid_init_to_null

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:fypfinal/Auth/cafeLogin.dart';
import 'package:fypfinal/Models/cafe.dart';
import 'package:fypfinal/SQLite/sqlite.dart';
import 'package:fypfinal/appStyle.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:geocoding/geocoding.dart';

class CafeRegisterPage extends StatefulWidget {
  const CafeRegisterPage({super.key});

  @override
  State<CafeRegisterPage> createState() => _CafeRegisterPageState();
}

class _CafeRegisterPageState extends State<CafeRegisterPage> {
  late Color myColor;
  late Size mediaSize;
  TextEditingController cafeNameController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;

  final formKey = GlobalKey<FormState>();
  final db = DatabaseHelper();
  late XFile? _imageFile = null;
  LatLng _selectedLocation = const LatLng(3.2011, 101.4480);
  final loc.Location location = loc.Location();
  late GoogleMapController _mapController;
  bool isMapExpanded = false;
  bool isScrollingMap = false;

  @override
  void initState() {
    super.initState();
    _startTime = const TimeOfDay(hour: 8, minute: 0);
    _endTime = const TimeOfDay(hour: 18, minute: 0);
  }

  @override
  Widget build(BuildContext context) {
    myColor = AppStyles.primaryColor(context);
    mediaSize = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        // Navigate to cafeLoginPage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CafeLogin()),
        );
        return true; // Returning true to allow the back navigation
      },
      child: Container(
        decoration: BoxDecoration(
          color: myColor,
          image: DecorationImage(
            image: const AssetImage("assets/bg.png"),
            fit: BoxFit.cover,
            colorFilter:
                ColorFilter.mode(myColor.withOpacity(0.2), BlendMode.dstATop),
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Card(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: _buildForm(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Cafe Registration",
            style: AppStyles.welcomeText(context),
          ),
          _buildGreyText("Please fill in your cafe information"),
          const SizedBox(height: 20),
          _buildGreyText("Cafe Name"),
          _buildInputField(
            cafeNameController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Cafe Name is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 15),
          _buildGreyText("Username"),
          _buildInputField(
            usernameController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Username is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 15),
          _buildGreyText("Password"),
          _buildInputField(
            passwordController,
            isPassword: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          _buildMapInput(),
          const SizedBox(height: 10),
          _buildOperationHoursInput(),
          const SizedBox(height: 10),
          _buildImageInput(),
          const SizedBox(height: 10),
          _buildRegisterButton(),
          const SizedBox(height: 10),
          _buildHaveAccount(),
        ],
      ),
    );
  }

  Widget _buildMapInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildGreyText("Select Cafe Location"),
        GestureDetector(
          onTap: () {
            setState(() {
              isMapExpanded = !isMapExpanded;
            });
          },
          onVerticalDragStart: (_) {
            setState(() {
              isScrollingMap = true;
            });
          },
          onVerticalDragEnd: (_) {
            setState(() {
              isScrollingMap = false;
            });
          },
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: isMapExpanded ? 400 : 200,
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _selectedLocation,
                    zoom: 15,
                  ),
                  onMapCreated: (controller) {
                    setState(() {
                      _mapController = controller;
                      _updateCurrentLocation();
                    });
                  },
                  onTap: _selectLocationOnMap,
                  markers: {
                    Marker(
                      markerId: const MarkerId("selectedLocation"),
                      position: _selectedLocation,
                      draggable: true,
                      onDragEnd: (newPosition) {
                        setState(() {
                          _selectedLocation = newPosition;
                        });
                      },
                    ),
                  },
                  gestureRecognizers: isScrollingMap
                      ? <Factory<OneSequenceGestureRecognizer>>{}
                      : <Factory<OneSequenceGestureRecognizer>>{
                          Factory<OneSequenceGestureRecognizer>(
                            () => EagerGestureRecognizer(),
                          ),
                        },
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      color: Colors.white.withOpacity(0.8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: searchController,
                                decoration: const InputDecoration(
                                  hintText: 'Search Address',
                                  border: InputBorder.none,
                                ),
                                onChanged: (value) {},
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.search),
                              onPressed: _searchLocation,
                            ),
                            IconButton(
                              icon: const Icon(Icons.my_location),
                              onPressed: _updateCurrentLocation,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _searchLocation() async {
    String address = searchController.text;
    if (address.isNotEmpty) {
      try {
        List<Location> locations = await locationFromAddress(address);
        if (locations.isNotEmpty) {
          _moveCameraToLocation(locations.first);
        } else {}
      } catch (e) {}
    } else {}
  }

  void _moveCameraToLocation(Location location) {
    _mapController.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(location.latitude, location.longitude),
        18,
      ),
    );
  }

  void _updateCurrentLocation() async {
    bool serviceEnabled;
    loc.PermissionStatus permissionGranted;
    loc.LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        // Location service is not enabled
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == loc.PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != loc.PermissionStatus.granted) {
        // Permission denied
        return;
      }
    }

    locationData = await location.getLocation();
    setState(() {
      _selectedLocation =
          LatLng(locationData.latitude!, locationData.longitude!);
    });
  }

  void _selectLocationOnMap(LatLng latLng) {
    setState(() {
      _selectedLocation = latLng;
    });
  }

  Widget _buildOperationHoursInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildGreyText(
            "Operation Hours"), // New label for operation hours input
        Row(
          children: [
            Expanded(
              child: ListTile(
                title: const Text("Start Time"),
                subtitle: Text(
                  _startTime.format(context),
                  style: const TextStyle(color: Colors.blue),
                ),
                onTap: () => _pickStartTime(context),
              ),
            ),
            Expanded(
              child: ListTile(
                title: const Text("End Time"),
                subtitle: Text(
                  _endTime.format(context),
                  style: const TextStyle(color: Colors.blue),
                ),
                onTap: () => _pickEndTime(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _pickStartTime(BuildContext context) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (pickedTime != null && pickedTime != _startTime) {
      setState(() {
        _startTime = pickedTime;
      });
    }
  }

  Future<void> _pickEndTime(BuildContext context) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (pickedTime != null && pickedTime != _endTime) {
      setState(() {
        _endTime = pickedTime;
      });
    }
  }

  Widget _buildImageInput() {
    return Center(
      child: Column(
        children: [
          _buildGreyText("Cafe Image"),
          _imageFile != null
              ? Image.file(
                  File(_imageFile!.path),
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                )
              : Container(
                  height: 50,
                  width: 50,
                  color: Colors.grey[300],
                  child: Icon(Icons.image, color: Colors.grey[600]),
                ),
          TextButton(
            onPressed: _pickImage,
            child: Text(
              _imageFile == null ? "Select Image" : "Change Image",
              style: const TextStyle(
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final XFile? selectedImage = await ImagePicker().pickImage(
      source: ImageSource
          .gallery, // You can also use ImageSource.camera for capturing a new photo
    );
    setState(() {
      _imageFile = selectedImage;
    });
  }

  Widget _buildGreyText(String text) {
    return Text(
      text,
      style: AppStyles.greyText(context),
    );
  }

  Widget _buildPurpleText(String text) {
    return Text(
      text,
      style: AppStyles.purpleText(context),
    );
  }

  Widget _buildInputField(TextEditingController controller,
      {bool isPassword = false, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      decoration: AppStyles.inputDecoration("", isPassword: isPassword),
      obscureText: isPassword,
      validator: validator,
    );
  }

  Widget _buildHaveAccount() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildGreyText("Already have an account?"),
        TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const CafeLogin()),
              );
            },
            child: _buildPurpleText("Login"))
      ],
    );
  }

  Widget _buildRegisterButton() {
    return ElevatedButton(
      onPressed: () async {
        if (formKey.currentState!.validate()) {
          String selectedLocation =
              "${_selectedLocation.latitude}, ${_selectedLocation.longitude}";
          if (_imageFile != null) {
            final imageFile = File(_imageFile!.path);
            final usernameExists =
                await db.checkUsernameExists(usernameController.text);
            if (usernameExists) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Username already exists. Please choose a different one.'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }
            db
                .cafeSignup(
              Cafes(
                cafeName: cafeNameController.text,
                cafeUsername: usernameController.text,
                cafePassword: passwordController.text,
                cafeLocation: selectedLocation,
                cafeImage: imageFile.path,
                operationHours:
                    '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}-${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}',
                isOpen: true,
              ),
            )
                .whenComplete(() {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CafeLogin()),
              );
            });
          } else {
            final pickedImage =
                await ImagePicker().pickImage(source: ImageSource.gallery);
            if (pickedImage != null) {
              final imageFile = File(pickedImage.path);
              final usernameExists =
                  await db.checkUsernameExists(usernameController.text);
              if (usernameExists) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Username already exists. Please choose a different one.'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              db
                  .cafeSignup(
                Cafes(
                  cafeName: cafeNameController.text,
                  cafeUsername: usernameController.text,
                  cafePassword: passwordController.text,
                  cafeLocation: selectedLocation,
                  cafeImage: imageFile.path,
                  operationHours:
                      '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}-${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}',
                  isOpen: true,
                ),
              )
                  .whenComplete(() {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CafeLogin()),
                );
              });
            }
          }
        }
      },
      style: AppStyles.loginButtonStyle(myColor),
      child: const Text("REGISTER"),
    );
  }
}
