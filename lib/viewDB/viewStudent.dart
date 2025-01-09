// ignore_for_file: file_names, library_private_types_in_public_api, deprecated_member_use

import 'package:fypfinal/AdminView/ViewSelectionPage.dart';
import 'package:fypfinal/Models/student.dart';
import 'package:fypfinal/SQLite/sqlite.dart';
import 'package:flutter/material.dart';
import 'package:fypfinal/appStyle.dart';

class ViewStudentPage extends StatefulWidget {
  const ViewStudentPage({super.key});

  @override
  _ViewStudentPageState createState() => _ViewStudentPageState();
}

class _ViewStudentPageState extends State<ViewStudentPage> {
  late List<Student> students;
  final DatabaseHelper db = DatabaseHelper();
  late Color myColor;
  late Size mediaSize;
  late TextEditingController studentName;
  late TextEditingController studentEmail;
  late TextEditingController studentPassword;

  @override
  void initState() {
    super.initState();
    students = [];
    refreshStudent();
    studentName = TextEditingController();
    studentEmail = TextEditingController();
    studentPassword = TextEditingController();
  }

  @override
  void dispose() {
    studentName.dispose();
    studentEmail.dispose();
    studentPassword.dispose();
    super.dispose();
  }

  Future<void> refreshStudent() async {
    try {
      final List<Student> studentList = await db.getAllStudents();
      setState(() {
        students = studentList;
      });
    } catch (e) {
      // Handle the error as needed (e.g., show an error message)
    }
  }

  @override
  Widget build(BuildContext context) {
    myColor = AppStyles.primaryColor(context);
    mediaSize = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ViewSelectionPage()),
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
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title
                const SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      'Students List',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // Student List
                Expanded(
                  child: _buildStudentList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStudentList() {
    return RefreshIndicator(
      onRefresh: refreshStudent,
      child: ListView.builder(
        itemCount: students.length,
        itemBuilder: (context, index) {
          return ExpansionTile(
            title: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Container(
                    color: Colors.grey,
                    width: 50,
                    height: 50,
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16), // Add space between image and text
                white(students[index].studentName),
              ],
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStudentDetails(students[index]),
                    const SizedBox(height: 16), // Add some space
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            if (students[index].studentId != null) {
                              _deleteStudent(students[index].studentId!);
                            }
                          },
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.white, // Set icon color to white
                          ),
                          label: white('Delete'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.red, // Set background color to red
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildUpdateButton(students[index]),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget white(String text) {
    return Text(
      text,
      style: const TextStyle(color: Colors.white),
    );
  }

  Widget _buildStudentDetails(Student student) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        white('ID: ${student.studentId}'),
        white('Name: ${student.studentName}'),
        white('Email: ${student.studentEmail}'),
        // Add more details or customize as needed
      ],
    );
  }

  Future<void> _deleteStudent(int studentId) async {
    final confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this student?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, false); // User canceled deletion
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, true); // User confirmed deletion
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final result = await db.deleteStudent(studentId);
      if (result > 0) {
        // If deletion is successful, refresh the student list
        refreshStudent();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Student deleted successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete student')),
        );
      }
    }
  }

  Widget _buildUpdateButton(Student student) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton.icon(
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
                              // Now update method
                              db
                                  .updateStudent(
                                studentName.text,
                                studentEmail.text,
                                studentPassword.text,
                                student.studentId!,
                              )
                                  .whenComplete(() {
                                refreshStudent();
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
                    title: const Text("Update Student"),
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
                              return "Password is required";
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
          icon: const Icon(Icons.edit, color: Colors.white),
          label: white('Edit'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple, // Set background color to red
          ),
        ),
      ],
    );
  }
}
