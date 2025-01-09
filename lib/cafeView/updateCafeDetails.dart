import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fypfinal/Models/cafe.dart';
import 'package:fypfinal/SQLite/sqlite.dart';
import 'package:fypfinal/appStyle.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart' as loc;

class UpdateCafeDetailsPage extends StatefulWidget {
  final int cafeId;
  const UpdateCafeDetailsPage({super.key, required this.cafeId});

  @override
  _UpdateCafeDetailsPageState createState() => _UpdateCafeDetailsPageState();
}

class _UpdateCafeDetailsPageState extends State<UpdateCafeDetailsPage> {
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
  late final bool _scrollingEnabled = true;

  @override
  void initState() {
    super.initState();
    _startTime = const TimeOfDay(hour: 8, minute: 0);
    _endTime = const TimeOfDay(hour: 18, minute: 0);
    _fetchCafeDetails();
  }

  void _fetchCafeDetails() async {
    // Fetch cafe details using cafeId
    Cafes? cafe = await db.getCafeDetails(widget.cafeId);
    if (cafe != null) {
      cafeNameController.text = cafe.cafeName;
      usernameController.text = cafe.cafeUsername;
      passwordController.text = cafe.cafePassword;

      // Set initial selected location
      List<String> locationCoords = cafe.cafeLocation.split(',');
      _selectedLocation = LatLng(
        double.parse(locationCoords[0].trim()),
        double.parse(locationCoords[1].trim()),
      );

      // Set initial operation hours
      List<String> operationHours = cafe.operationHours.split('-');
      List<String> startTime = operationHours[0].split(':');
      List<String> endTime = operationHours[1].split(':');
      _startTime = TimeOfDay(
        hour: int.parse(startTime[0]),
        minute: int.parse(startTime[1]),
      );
      _endTime = TimeOfDay(
        hour: int.parse(endTime[0]),
        minute: int.parse(endTime[1]),
      );

      setState(() {});
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    myColor = AppStyles.primaryColor(context);
    mediaSize = MediaQuery.of(context).size;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: _buildForm(),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: formKey,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Update Cafe Details",
              style: AppStyles.welcomeText(context),
            ),
            _buildGreyText("Update your cafe information"),
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
            _buildUpdateButton(),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildMapInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildGreyText("Select Cafe Location"),
        SizedBox(
          height: 200, // Set the desired height for the map container
          child: Stack(
            children: [
              AbsorbPointer(
                absorbing: !_scrollingEnabled,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _selectedLocation, // Set the initial location
                    zoom: 15, // Set the initial zoom level
                  ),
                  onMapCreated: (controller) {
                    setState(() {
                      _mapController = controller;
                      _updateCurrentLocation();
                    });

                    // Optionally, you can move the camera to the initial location
                    _mapController.animateCamera(
                      CameraUpdate.newLatLng(_selectedLocation),
                    );
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
                ),
              ),
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(20), // Adjust the border radius
                  child: Container(
                    color: Colors.white
                        .withOpacity(0.8), // Adjust the transparency
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
      ],
    );
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
      source: ImageSource.gallery,
    );
    if (selectedImage != null) {
      setState(() {
        _imageFile = selectedImage;
      });
    }
  }

  Widget _buildGreyText(String text) {
    return Text(
      text,
      style: AppStyles.greyText(context),
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

  Widget _buildUpdateButton() {
    return ElevatedButton(
      onPressed: () async {
        if (formKey.currentState!.validate()) {
          // Get the cafe details from the form fields
          String selectedLocation =
              "${_selectedLocation.latitude}, ${_selectedLocation.longitude}";
          final imageFile = _imageFile != null ? File(_imageFile!.path) : null;

          // Create a new Cafes object with updated details
          Cafes updatedCafe = Cafes(
            cafeId: widget.cafeId, // Assuming widget.cafeId is available
            cafeName: cafeNameController.text,
            cafeUsername: usernameController.text,
            cafePassword: passwordController.text,
            cafeLocation: selectedLocation,
            cafeImage: imageFile!.path,
            operationHours:
                '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}-${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}',
            isOpen: true, // Assuming isOpen is always true
          );

          // Update the cafe details in the database using updateCafe method
          int rowsAffected = await db.updateCafe(updatedCafe);

          // Check if update was successful
          if (rowsAffected > 0) {
            // Cafe details updated successfully
            Navigator.pop(context);
          } else {
            // Update failed
            // You can show an error message here
          }
        }
      },
      style: AppStyles.loginButtonStyle(myColor),
      child: const Text("UPDATE"),
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
}
