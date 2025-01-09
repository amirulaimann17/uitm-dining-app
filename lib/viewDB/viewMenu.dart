// ignore_for_file: file_names, library_private_types_in_public_api

import 'package:fypfinal/Models/menu.dart';
import 'package:fypfinal/SQLite/sqlite.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ViewMenuPage extends StatefulWidget {
  const ViewMenuPage({super.key});

  @override
  _ViewMenuPageState createState() => _ViewMenuPageState();
}

class _ViewMenuPageState extends State<ViewMenuPage> {
  late List<MenuModel> menuTable;
  final DatabaseHelper db = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    refreshMenu();
  }

  Future<void> refreshMenu() async {
    final List<MenuModel> menuList = await db.getAllMenus();
    setState(() {
      menuTable = menuList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Menus'),
      ),
      body: RefreshIndicator(
        onRefresh: refreshMenu,
        child: ListView.builder(
          itemCount: menuTable.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(menuTable[index].menuName),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Menu ID: ${menuTable[index].menuId}'),
                  Text('Cafe ID: ${menuTable[index].cafeId}'),
                  Text(NumberFormat.currency(symbol: 'RM', decimalDigits: 2)
                      .format(menuTable[index].menuPrice)),
                  Text(menuTable[index].menuDescription),
                  Text(menuTable[index].menuCategory),
                  // Add more details or customize as needed
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
