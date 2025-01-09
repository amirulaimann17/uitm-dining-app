// ignore_for_file: file_names

import 'package:fypfinal/Auth/studentLogin.dart';
import 'package:fypfinal/Models/student.dart';
import 'package:fypfinal/SQLite/sqlite.dart';
import 'package:fypfinal/appStyle.dart';
import 'package:flutter/material.dart';

class StudentRegister extends StatefulWidget {
  const StudentRegister({super.key});

  @override
  State<StudentRegister> createState() => _StudentRegisterState();
}

class _StudentRegisterState extends State<StudentRegister> {
  late Color myColor;
  late Size mediaSize;
  TextEditingController studentNameController = TextEditingController();
  TextEditingController studentEmailController = TextEditingController();
  TextEditingController studentPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool isVisible = false;
  final db = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    myColor = AppStyles.primaryColor(context);
    mediaSize = MediaQuery.of(context).size;

    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        // Navigate to cafeLoginPage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const StudentLogin()),
        );
        return true; // Returning true to allow the back navigation
      },
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage("assets/bg.png"),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.5), BlendMode.darken),
              ),
            ),
          ),
          Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(
              children: [
                Positioned(top: 80, child: _buildTop()),
                Positioned(bottom: 0, child: _buildBottom()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTop() {
    return SizedBox(
      width: mediaSize.width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
        ],
      ),
    );
  }

  Widget _buildBottom() {
    return SizedBox(
      width: mediaSize.width,
      child: Opacity(
        opacity: 0.9,
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
    );
  }

  Widget _buildForm() {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Student Registration",
            style: AppStyles.welcomeText(context),
          ),
          _buildGreyText("Please fill in your information"),
          const SizedBox(height: 20),
          _buildGreyText("Name"),
          _buildInputField(
            studentNameController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Name is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildGreyText("Student Email"),
          _buildInputField(
            studentEmailController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Student Email is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildGreyText("Password"),
          _buildInputField(
            studentPasswordController,
            isPassword: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildRegisterButton(),
          const SizedBox(height: 20),
          _buildHaveAccount(),
        ],
      ),
    );
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
                MaterialPageRoute(builder: (context) => const StudentLogin()),
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
          String studentName = studentNameController.text.trim();
          String studentEmail = studentEmailController.text.trim();
          String studentPassword = studentPasswordController.text.trim();
          bool emailExists = await db.checkIfEmailExists(studentEmail);
          if (emailExists) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Email already exists'),
                duration: Duration(seconds: 3),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
          db
              .studentSignup(
            Student(
              studentName: studentName,
              studentEmail: studentEmail,
              studentPassword: studentPassword,
            ),
          )
              .whenComplete(() {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const StudentLogin()),
            );
          });
        }
      },
      style: AppStyles.loginButtonStyle(myColor),
      child: const Text("REGISTER"),
    );
  }
}
