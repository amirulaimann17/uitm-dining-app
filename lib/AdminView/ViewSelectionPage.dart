import 'package:fypfinal/Auth/userSelection.dart';
import 'package:fypfinal/appStyle.dart';
import 'package:fypfinal/viewDB/viewCafe.dart';
import 'package:fypfinal/viewDB/viewOrder.dart'; // Import view order page
import 'package:fypfinal/viewDB/viewStudent.dart';
import 'package:flutter/material.dart';

class ViewSelectionPage extends StatefulWidget {
  const ViewSelectionPage({Key? key}) : super(key: key);

  @override
  State<ViewSelectionPage> createState() => _ViewSelectionPageState();
}

class _ViewSelectionPageState extends State<ViewSelectionPage> {
  late Color myColor;
  late Size mediaSize;

  @override
  Widget build(BuildContext context) {
    myColor = AppStyles.primaryColor(context);
    mediaSize = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const UserSelection()),
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
          appBar: AppBar(
            title: const Text(
              'Admin Dashboard',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.transparent,
            iconTheme: const IconThemeData(
              color: Colors.white,
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const UserSelection()),
                );
              },
            ),
          ),
          body: Stack(
            children: [
              Positioned(top: 80, child: _buildTop()),
              Positioned(bottom: 40, child: _buildBottom()), // Adjusted bottom position
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTop() {
    return SizedBox(
      width: mediaSize.width,
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.food_bank,
            size: 100,
            color: Colors.white,
          ),
          Text(
            "Administrator",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 35,
              letterSpacing: 2,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBottom() {
    return SizedBox(
      width: mediaSize.width,
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: _buildSelection(),
      ),
    );
  }

  Widget _buildSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          "Hi Admin!",
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        _buildGreyText("Which to view?"),
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStudentButton(),
            const SizedBox(width: 40),
            _buildCafeButton(),
          ],
        ),
        const SizedBox(height: 40), // Space added between rows
        _buildOrderButton(), // New button to view orders
      ],
    );
  }

  Widget _buildGreyText(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 15,
      ),
    );
  }

  Widget _buildStudentButton() {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Material(
            color: Colors.white,
            child: InkWell(
              onTap: () async {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ViewStudentPage(),
                  ),
                );
              },
              child: const SizedBox(
                width: 100,
                height: 100,
                child: Icon(
                  Icons.school,
                  size: 40,
                  color: Colors.deepPurple,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "View Students",
          style: TextStyle(color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildCafeButton() {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Material(
            color: Colors.white,
            child: InkWell(
              onTap: () async {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ViewCafesPage(),
                  ),
                );
              },
              child: const SizedBox(
                width: 100,
                height: 100,
                child: Icon(
                  Icons.store,
                  size: 40,
                  color: Colors.deepPurple,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "View Cafes",
          style: TextStyle(color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildOrderButton() {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Material(
            color: Colors.white,
            child: InkWell(
              onTap: () async {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ViewOrdersPage(),
                  ),
                );
              },
              child: const SizedBox(
                width: 100,
                height: 100,
                child: Icon(
                  Icons.shopping_bag,
                  size: 40,
                  color: Colors.deepPurple,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "View Orders",
          style: TextStyle(color: Colors.white),
        ),
      ],
    );
  }
}

