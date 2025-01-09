import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fypfinal/AdminView/ViewSelectionPage.dart';
import 'package:fypfinal/Models/cafe.dart';
import 'package:fypfinal/Models/menu.dart';
import 'package:fypfinal/Models/order.dart';
import 'package:fypfinal/SQLite/sqlite.dart';
import 'package:intl/intl.dart';

class ViewOrdersPage extends StatefulWidget {
  const ViewOrdersPage({Key? key}) : super(key: key);

  @override
  _ViewOrdersPageState createState() => _ViewOrdersPageState();
}

class _ViewOrdersPageState extends State<ViewOrdersPage> {
  final DatabaseHelper db = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            'View Orders',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.transparent,
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: const AssetImage("assets/bg.png"),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.7),
                BlendMode.darken,
              ),
            ),
          ),
          child: FutureBuilder<List<Order>>(
            future: db.getAllOrders(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.data == null || snapshot.data!.isEmpty) {
                return const Center(child: Text('No orders found.'));
              } else {
                final List<Order> orders = snapshot.data!;
                orders.sort((a, b) => b.orderDate
                    .compareTo(a.orderDate)); // Sort orders by date descending
                return ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final Order order = orders[index];
                    return _buildOrderTile(order);
                  },
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    // Navigate back to ViewSelectionPage
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ViewSelectionPage()),
    );
    return true; // Return true to allow back navigation
  }

  Widget _buildOrderTile(Order order) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<Cafes?>(
              future: db.getCafeDetails(order.cafeId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error fetching cafe details: ${snapshot.error}');
                } else if (snapshot.data == null) {
                  return const Text('Cafe not found');
                } else {
                  final Cafes cafe = snapshot.data!;
                  return Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          File(cafe.cafeImage),
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cafe.cafeName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            'Order ID: ${order.orderId}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            NumberFormat.currency(
                              symbol: 'RM ',
                              decimalDigits: 2,
                            ).format(order.totalPrice),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            'Order Date: ${DateFormat('yyyy-MM-dd').format(order.orderDate)}',
                          ),
                          const SizedBox(height: 4.0),
                          Container(
                            decoration: BoxDecoration(
                              color: getStatusColor(order.orderStatus),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              order.orderStatus,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 8.0),
            ExpansionTile(
              title: const Text(
                'Items',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              children: order.items.map((item) {
                return FutureBuilder<MenuModel?>(
                  future: db.getMenuById(item.menuId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error fetching menu: ${snapshot.error}');
                    } else if (snapshot.data == null) {
                      return const Text('Menu not found');
                    } else {
                      final MenuModel menu = snapshot.data!;
                      return ListTile(
                        title: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                File(menu.menuImage),
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Menu ID: ${menu.menuId}',
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                  Text(
                                    menu.menuName,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'x${item.quantity}',
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                  Text(
                                    NumberFormat.currency(
                                      symbol: 'RM',
                                      decimalDigits: 2,
                                    ).format(menu.menuPrice),
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 8.0),
          ],
        ),
      ),
    );
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Received':
        return Colors.blue;
      case 'Ready for Pickup':
        return Colors.green;
      case 'Completed':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}
