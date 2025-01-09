import 'package:flutter/material.dart';
import 'package:fypfinal/AdminView/ViewSelectionPage.dart';
import 'package:fypfinal/Auth/userSelection.dart';
import 'package:fypfinal/SQLite/sqlite.dart';
import 'package:fypfinal/appStyle.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  _AdminLoginPageState createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  late Color myColor;
  late Size mediaSize;

  @override
  Widget build(BuildContext context) {
    myColor = AppStyles.primaryColor(context);
    mediaSize = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        // Navigate to cafeLoginPage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const UserSelection()),
        );
        return true; // Returning true to allow the back navigation
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
              padding: const EdgeInsets.all(16.0), child: _buildLogin()),
        ),
      ),
    );
  }

  Widget _buildLogin() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "Admin",
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 30),
          ),
          const Text(
            "Please Log In",
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w300, fontSize: 15),
          ),
          TextField(
            controller: _usernameController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Username',
              labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
            ),
          ),
          const SizedBox(height: 16.0),
          TextField(
            controller: _passwordController,
            style: const TextStyle(color: Colors.white),
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password',
              labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
            ),
          ),
          const SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () {
              _login();
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  void _login() async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showAlertDialog('Error', 'Please enter both username and password.');
      return;
    }

    // Call adminLogin method from DatabaseHelper
    int? adminId = await _databaseHelper.adminLogin(username, password);
    if (adminId != null) {
      // Navigate to admin view page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ViewSelectionPage()),
      );
    } else {
      _showAlertDialog('Error', 'Invalid username or password.');
    }
  }

  void _showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
