import 'package:fypfinal/Auth/adminLogin.dart';
import 'package:fypfinal/Auth/cafeLogin.dart';
import 'package:fypfinal/Auth/studentLogin.dart';
import 'package:fypfinal/appStyle.dart';
import 'package:flutter/material.dart';

class UserSelection extends StatefulWidget {
  const UserSelection({super.key});

  @override
  State<UserSelection> createState() => _UserSelectionState();
}

class _UserSelectionState extends State<UserSelection> {
  @override
  @override
  Widget build(BuildContext context) {
    AppStyles.primaryColor(context);
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image:
                    AssetImage('assets/bg.png'), // Replace with your image path
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            color:
                Colors.black.withOpacity(0.7), // Adjust the opacity as needed
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/logo.png", // Replace with your logo asset path
                  width: 100, // Adjust width as needed
                  height: 100,
                ),
                const Row(
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
                const SizedBox(height: 40),
                _buildSelection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelection() {
    AppStyles.primaryColor(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Welcome!",
          style: TextStyle(
              color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold),
        ),
        const Text(
          "Which one are you?",
          style: TextStyle(color: Colors.white, fontSize: 15),
        ),
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStudentButton(),
            const SizedBox(width: 40),
            _buildCafeButton(),
          ],
        ),
        const SizedBox(height: 40),
        _buildAdminButton(),
      ],
    );
  }

  Widget _buildStudentButton() {
    AppStyles.primaryColor(context);
    return Column(
      children: [
        ClipOval(
          child: Material(
            color: Colors.white,
            child: InkWell(
              onTap: () async {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const StudentLogin()),
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
          "Student",
          style: TextStyle(color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildCafeButton() {
    AppStyles.primaryColor(context);
    return Column(
      children: [
        ClipOval(
          child: Material(
            color: Colors.white,
            child: InkWell(
              onTap: () async {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const CafeLogin()),
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
          "Cafe Owner",
          style: TextStyle(color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildAdminButton() {
    AppStyles.primaryColor(context);
    return Column(
      children: [
        ClipOval(
          child: Material(
            color: Colors.white,
            child: InkWell(
              onTap: () async {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AdminLoginPage()),
                );
              },
              child: const SizedBox(
                width: 100,
                height: 100,
                child: Icon(
                  Icons.admin_panel_settings,
                  size: 40,
                  color: Colors.deepPurple,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Administrator",
          style: TextStyle(color: Colors.white),
        ),
      ],
    );
  }
}
