// ignore_for_file: file_names, library_private_types_in_public_api, deprecated_member_use, use_build_context_synchronously

import 'package:fypfinal/Auth/studentRegister.dart';
import 'package:fypfinal/Auth/userSelection.dart';
import 'package:fypfinal/SQLite/sqlite.dart';
import 'package:fypfinal/appStyle.dart';
import 'package:fypfinal/studentView/studentCafePage.dart';
import 'package:flutter/material.dart';

class StudentLogin extends StatefulWidget {
  const StudentLogin({super.key});

  @override
  _StudentLoginState createState() => _StudentLoginState();
}

class _StudentLoginState extends State<StudentLogin> {
  late Color myColor;
  late Size mediaSize;
  TextEditingController studentEmailController = TextEditingController();
  TextEditingController studentPasswordController = TextEditingController();
  bool rememberUser = false;
  final formKey = GlobalKey<FormState>();
  bool isVisible = false;
  final db = DatabaseHelper();

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
        return false; // Prevent closing
      },
      child: Stack(
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
            "Student Login",
            style: AppStyles.welcomeText(context),
          ),
          _buildGreyText("Please login with your information"),
          const SizedBox(height: 40),
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
          _buildRememberForgot(),
          const SizedBox(height: 20),
          _buildLoginButton(),
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

  Widget _buildInputField(
    TextEditingController controller, {
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    bool obscureText = isPassword;
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return TextFormField(
          controller: controller,
          decoration: InputDecoration(
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        obscureText = !obscureText;
                      });
                    },
                  )
                : null,
          ),
          obscureText: obscureText,
          validator: validator,
        );
      },
    );
  }

  Widget _buildRememberForgot() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Row(
          children: [
            _buildGreyText("Not registered yet?"),
          ],
        ),
        TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const StudentRegister()),
              );
            },
            child: const Text("Register now"))
      ],
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: () async {
        if (formKey.currentState!.validate()) {
          String studentEmail = studentEmailController.text.trim();
          String studentPassword = studentPasswordController.text.trim();
          int? studentId = await db.studentLogin(studentEmail, studentPassword);

          if (studentId != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StudentCafePage(
                  studentId: studentId,
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Invalid username or password'),
                duration: Duration(seconds: 2),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
      style: AppStyles.loginButtonStyle(myColor),
      child: const Text("LOGIN"),
    );
  }
}
