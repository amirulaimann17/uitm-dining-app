import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fypfinal/Models/order.dart';
import 'package:fypfinal/Models/student.dart';
import 'package:fypfinal/Models/menu.dart';
import 'package:fypfinal/SQLite/sqlite.dart';
import 'package:fypfinal/appStyle.dart';
import 'package:intl/intl.dart';

class CafeOrderPage extends StatefulWidget {
  final int cafeId;

  const CafeOrderPage({
    Key? key,
    required this.cafeId,
  });

  @override
  _CafeOrderPageState createState() => _CafeOrderPageState();
  static Widget buildOrderTile(Order order) {
    return _CafeOrderPageState()._buildOrderTile(order);
  }
}

class _CafeOrderPageState extends State<CafeOrderPage> {
  final DatabaseHelper db = DatabaseHelper();
  late Color myColor;
  late Size mediaSize;

  @override
  Widget build(BuildContext context) {
    myColor = AppStyles.primaryColor(context);
    mediaSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'Orders',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(
          color: Colors.white, // Change the icon color to white
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
          future: db.getOrdersByCafeId(widget.cafeId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.data == null || snapshot.data!.isEmpty) {
              return const Center(child: Text('No orders found.'));
            } else {
              final List<Order> orders = snapshot.data!;
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
    );
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
            Text(
              'Order ID: ${order.orderId}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Text(
              NumberFormat.currency(
                      symbol: 'Total Price: RM ', decimalDigits: 2)
                  .format(order.totalPrice),
            ),
            const SizedBox(height: 4.0),
            Text(
                'Order Date: ${DateFormat('yyyy-MM-dd').format(order.orderDate)}'),
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
            const SizedBox(height: 8.0),
            FutureBuilder<Student?>(
              future: db.getStudentDetails(order.studentId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error fetching student: ${snapshot.error}');
                } else {
                  final Student student = snapshot.data!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Student ID: ${student.studentId}'),
                      const SizedBox(height: 4.0),
                      Text('Name: ${student.studentName}'),
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
                              borderRadius: BorderRadius.circular(6),
                              child: Image.file(
                                File(menu.menuImage),
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(
                              width: 15,
                            ),
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
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'x${item.quantity}',
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                  Text(
                                    NumberFormat.currency(
                                            symbol: 'RM', decimalDigits: 2)
                                        .format(menu.menuPrice),
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
            _buildStatusButtons(order),
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

  Widget _buildStatusButtons(Order order) {
    List<String> statuses = [
      'Pending',
      'Received',
      'Ready for Pickup',
      'Completed'
    ];
    int currentIndex = statuses.indexOf(order.orderStatus);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
          onPressed: currentIndex > 0
              ? () =>
                  onUpdateOrderStatus(order.orderId, statuses[currentIndex - 1])
              : null,
          child: const Text('Previous Status'),
        ),
        ElevatedButton(
          onPressed: currentIndex < statuses.length - 1
              ? () =>
                  onUpdateOrderStatus(order.orderId, statuses[currentIndex + 1])
              : null,
          child: const Text('Next Status'),
        ),
      ],
    );
  }

  void onUpdateOrderStatus(int? orderId, String newStatus) async {
    if (orderId == null) return;
    try {
      await db.updateOrderStatus(orderId, newStatus);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order $orderId updated to $newStatus')),
      );
      setState(() {}); // Refresh the orders list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update order status: $e')),
      );
    }
  }
}
