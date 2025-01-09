import 'package:flutter/material.dart';
import 'package:fypfinal/Auth/userSelection.dart';
import 'package:fypfinal/appStyle.dart';
import 'package:fypfinal/studentView/studentOrderHistoryPage.dart';
import 'package:fypfinal/studentView/viewCartPage.dart';
import 'package:fypfinal/studentView/viewOrderPage.dart';
//import 'package:fypfinal/studentView/viewOrderPage.dart';

class CustomDrawer extends StatefulWidget {
  final int studentId;

  const CustomDrawer({Key? key, required this.studentId}) : super(key: key);

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  late Color myColor;

  @override
  Widget build(BuildContext context) {
    myColor = AppStyles.primaryColor(context);
    return Drawer(
      child: Column(
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage("assets/bg.png"),
                fit: BoxFit.fill, // Adjusted fit property
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.7),
                  BlendMode.darken,
                ),
              ),
            ),
            child: const Row(
              children: [
                Expanded(
                  child: Text(
                    'Menu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            title: const Row(
              children: [
                Icon(
                  Icons.shopping_cart,
                  color: Colors.black,
                ),
                SizedBox(width: 15),
                Text(
                  'View Cart',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewCartPage(
                    studentId: widget.studentId,
                  ),
                ),
              );
            },
          ),
          ListTile(
            title: const Row(
              children: [
                Icon(
                  Icons.assignment,
                  color: Colors.black,
                ),
                SizedBox(width: 15),
                Text(
                  'View Order',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            onTap: () {
              navigateToViewOrderPage(context, widget.studentId);
            },
          ),
          ListTile(
            title: const Row(
              children: [
                Icon(
                  Icons.history,
                  color: Colors.black,
                ),
                SizedBox(width: 15),
                Text(
                  'Order History',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            onTap: () {
              navigateToOrderHistoryPage(context, widget.studentId);
            },
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Confirm Logout'),
                    content: const Text('Are you sure you want to log out?'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const UserSelection(),
                            ),
                          );
                        },
                        child: const Text('Logout'),
                      ),
                    ],
                  );
                },
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              color: Colors.black.withOpacity(0.8),
              width: double.infinity,
              child: const Center(
                child: Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void navigateToViewOrderPage(BuildContext context, int studentId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewOrderPage(studentId: studentId),
      ),
    );
  }

  void navigateToOrderHistoryPage(BuildContext context, int studentId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentOrderHistoryPage(studentId: studentId),
      ),
    );
  }
}
