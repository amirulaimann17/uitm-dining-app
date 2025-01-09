import 'package:flutter/material.dart';
import 'package:fypfinal/Auth/userSelection.dart';
import 'package:fypfinal/appStyle.dart';
import 'package:fypfinal/cafeView/cafeOrderPage.dart';
import 'package:fypfinal/cafeView/cafeOrderHistoryPage.dart'; // Make sure to import the Orders History page

class CafeDrawer extends StatelessWidget {
  final int cafeId;

  const CafeDrawer({super.key, required this.cafeId});

  @override
  Widget build(BuildContext context) {
    AppStyles.primaryColor(context);
    return Drawer(
      child: Column(
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage("assets/bg.png"),
                fit: BoxFit.fill,
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
                  Icons.assignment,
                  color: Colors.black,
                ),
                SizedBox(width: 15),
                Text(
                  'Orders',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CafeOrderPage(cafeId: cafeId),
                ),
              );
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
                  'Orders History',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CafeOrderHistoryPage(cafeId: cafeId),
                ),
              );
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
                          Navigator.of(context).pop(); // Close the dialog
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          // Implement logout functionality here
                          Navigator.pop(context); // Close the drawer
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const UserSelection(), // Replace UserSelection with the appropriate screen
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
}
