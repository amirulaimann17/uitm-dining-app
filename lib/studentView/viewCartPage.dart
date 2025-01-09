import 'dart:io'; // Import dart:io for File
import 'package:flutter/material.dart';
import 'package:fypfinal/Models/cafe.dart';
import 'package:fypfinal/Models/order.dart';
import 'package:fypfinal/Models/orderItem.dart';
import 'package:fypfinal/SQLite/sqlite.dart';
import 'package:fypfinal/appStyle.dart';
import 'package:fypfinal/studentView/viewOrderPage.dart';
import 'package:intl/intl.dart';

class ViewCartPage extends StatefulWidget {
  final int studentId;

  const ViewCartPage({
    super.key,
    required this.studentId,
  });

  @override
  _ViewCartPageState createState() => _ViewCartPageState();
}

class _ViewCartPageState extends State<ViewCartPage> {
  final DatabaseHelper db = DatabaseHelper();
  late Color myColor;
  late Size mediaSize;
  bool isOrderSubmitted = false; // Add this state variable

  @override
  Widget build(BuildContext context) {
    myColor = AppStyles.primaryColor(context);
    mediaSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'View Cart',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.transparent,
      body: Container(
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
        child: _buildCart(),
      ),
    );
  }

  Widget _buildCart() {
    return SafeArea(
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: db.getCafeIdsInCart(widget.studentId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            final List<Map<String, dynamic>> cafeIdsList = snapshot.data ?? [];
            return ListView.builder(
              itemCount: cafeIdsList.length,
              itemBuilder: (context, index) {
                final cafeIdMap = cafeIdsList[index];
                final int cafeId = cafeIdMap['cafeId'];
                return _buildCafeTile(cafeId);
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildCafeTile(int cafeId) {
    return FutureBuilder<Cafes?>(
      future: db.getCafeDetails(cafeId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError || !snapshot.hasData) {
          return const Text(
            'Error retrieving cafe details',
            style: TextStyle(color: Colors.white),
          );
        } else {
          final cafeName = snapshot.data!.cafeName;
          return ExpansionTile(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.file(
                          File(snapshot.data!.cafeImage),
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cafeName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        _buildTotalItemCount(cafeId),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            children: [
              _buildMenuList(cafeId),
              const SizedBox(height: 10),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  // Submit order when button is pressed
                  await _submitOrder(cafeId);
                },
                child: const Text('Submit Order'),
              ),
            ],
          );
        }
      },
    );
  }

  Future<void> _submitOrder(int cafeId) async {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Submit'),
          content: const Text('Are you sure you want to submit this order?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Submit order when confirmed
                await _submitConfirmedOrder(cafeId);
                Navigator.of(dialogContext).pop(); // Close the dialog

                // Show success snackbar with action to navigate to order page using the original context
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Order successfully submitted'),
                    action: SnackBarAction(
                      label: 'View Order',
                      onPressed: () {
                        // Navigate to the view order page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ViewOrderPage(
                                    studentId: widget.studentId,
                                  )), // Replace with your order page
                        );
                      },
                    ),
                  ),
                );
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitConfirmedOrder(int cafeId) async {
    try {
      final List<Map<String, dynamic>> cartItems =
          await db.getMenuInCartByCafe(widget.studentId, cafeId);

      // Create order object
      final DateTime orderDate = DateTime.now();
      final double totalPrice = calculateTotalPrice(cartItems);

      final List<OrderItem> orderItems = cartItems.map((item) {
        return OrderItem(
          menuId: item['menuId'],
          quantity: item['quantity'],
          menuPrice: item['menuPrice'],
        );
      }).toList();

      final Order order = Order(
        studentId: widget.studentId,
        cafeId: cafeId,
        orderDate: orderDate,
        totalPrice: totalPrice,
        orderStatus: 'Pending',
        items: orderItems,
      );

      await db.insertOrder(order);
      await db.deleteCartByCafe(widget.studentId, cafeId);
      // Refresh UI
      setState(() {});
    } catch (error) {}
  }

  double calculateTotalPrice(List<Map<String, dynamic>> cartItems) {
    double totalPrice = 0;
    for (final item in cartItems) {
      totalPrice += item['menuPrice'] * item['quantity'];
    }
    return totalPrice;
  }

  Widget _buildTotalItemCount(int cafeId) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: db.getMenuInCartByCafe(widget.studentId, cafeId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else {
          int totalCount = 0;
          for (var item in snapshot.data!) {
            int quantity = item['quantity'] as int;
            totalCount += quantity;
          }
          return Text(
            '$totalCount items',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
            ),
          );
        }
      },
    );
  }

  Widget _buildMenuList(int cafeId) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: db.getMenuInCartByCafe(widget.studentId, cafeId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else {
          final List<Map<String, dynamic>> menuList = snapshot.data ?? [];

          // Create a map to consolidate menu items by their menuId
          Map<int, Map<String, dynamic>> consolidatedMenuItems = {};

          for (var item in menuList) {
            int menuId = item['menuId'] as int;
            if (consolidatedMenuItems.containsKey(menuId)) {
              consolidatedMenuItems[menuId]!['quantity'] +=
                  item['quantity'] as int;
            } else {
              consolidatedMenuItems[menuId] = Map<String, dynamic>.from(item);
            }
          }

          // Convert the map back to a list for display
          List<Map<String, dynamic>> consolidatedMenuList =
              consolidatedMenuItems.values.toList();

          return Column(
            children: consolidatedMenuList.map((menuItem) {
              int menuId = menuItem['menuId'] as int;
              int quantity = menuItem['quantity'] as int;
              return ListTile(
                title: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (menuItem['menuImage'] != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ClipOval(
                          child: Image.file(
                            File(menuItem['menuImage']),
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            menuItem['menuName'],
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '${NumberFormat.currency(symbol: 'RM', decimalDigits: 2).format(menuItem['menuPrice'])} each',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.remove,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            if (quantity > 1) {
                              db
                                  .updateCartItemQuantity(
                                widget.studentId,
                                menuId,
                                cafeId,
                                quantity - 1,
                              )
                                  .then((_) {
                                setState(() {
                                  // Rebuild the widget after updating the database
                                });
                              });
                            } else {
                              db
                                  .removeCartItem(
                                widget.studentId,
                                menuId,
                                cafeId,
                              )
                                  .then((_) {
                                setState(() {
                                  // Rebuild the widget after removing the item
                                });
                              });
                            }
                          },
                        ),
                        Text(
                          '$quantity',
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            db
                                .updateCartItemQuantity(
                              widget.studentId,
                              menuId,
                              cafeId,
                              quantity + 1,
                            )
                                .then((_) {
                              setState(() {
                                // Rebuild the widget after updating the database
                              });
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        }
      },
    );
  }
}
