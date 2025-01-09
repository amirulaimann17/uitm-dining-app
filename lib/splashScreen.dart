import 'dart:async';
import 'package:fypfinal/Auth/userSelection.dart';
import 'package:fypfinal/appStyle.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late Color myColor;
  late Size mediaSize;

  @override
  void initState() {
    super.initState();
    Timer(
      const Duration(seconds: 2),
      () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const UserSelection()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    myColor = AppStyles.primaryColor(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage("assets/bg.png"),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  myColor.withOpacity(0.2), // Adjust opacity as needed
                  BlendMode.dstATop,
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/logo.png", // Replace with your logo asset path
                  width: 150, // Adjust width as needed
                  height: 150,
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Palam",
                      style: TextStyle(
                        color: Colors.deepPurpleAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 50,
                        letterSpacing: 2,
                      ),
                    ),
                    Text(
                      "Cafes",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 50,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
