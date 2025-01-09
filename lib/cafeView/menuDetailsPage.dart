// ignore_for_file: file_names, library_private_types_in_public_api

import 'dart:io';

import 'package:fypfinal/Models/menu.dart';
import 'package:fypfinal/appStyle.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MenuDetailsPage extends StatefulWidget {
  final MenuModel menuItem;

  const MenuDetailsPage({super.key, required this.menuItem});

  @override
  _MenuDetailsPageState createState() => _MenuDetailsPageState();
}

class _MenuDetailsPageState extends State<MenuDetailsPage> {
  late Color myColor;
  late Size mediaSize;

  @override
  Widget build(BuildContext context) {
    myColor = AppStyles.primaryColor(context);
    mediaSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.transparent,
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
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildImage(),
                _buildDetailRow("Name", widget.menuItem.menuName),
                _buildDetailRow(
                  "Price",
                  NumberFormat.currency(
                    symbol: 'RM',
                    decimalDigits: 2,
                  ).format(widget.menuItem.menuPrice),
                ),
                _buildDetailRow("Description", widget.menuItem.menuDescription),
                _buildDetailRow("Category", widget.menuItem.menuCategory),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      // ignore: unnecessary_null_comparison
      child: widget.menuItem.menuImage != null
          ? Container(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(40.0),
                    child: Image.file(
                      File(widget.menuItem.menuImage),
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            )
          : Container(),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              "$label:",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
