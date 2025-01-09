import 'dart:io';

import 'package:fypfinal/Models/menu.dart';
import 'package:fypfinal/SQLite/sqlite.dart';
import 'package:fypfinal/appStyle.dart';
import 'package:fypfinal/cafeView/cafeMenuPage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CreateMenu extends StatefulWidget {
  final int cafeId;
  const CreateMenu({required this.cafeId, super.key});

  @override
  State<CreateMenu> createState() => _CreateMenuState();
}

class _CreateMenuState extends State<CreateMenu> {
  late Color myColor;
  late Size mediaSize;
  TextEditingController menuNameController = TextEditingController();
  TextEditingController menuPriceController = TextEditingController();
  TextEditingController menuDescriptionController = TextEditingController();
  String? menuCategoryController;
  final formKey = GlobalKey<FormState>();
  final db = DatabaseHelper();
  final List<String> categories = [
    'Breakfast',
    'Lunch',
    'Dinner',
    'Drinks',
    'Dessert'
  ];
  XFile? _imageFile;

  @override
  Widget build(BuildContext context) {
    myColor = AppStyles.primaryColor(context);
    mediaSize = MediaQuery.of(context).size;
    return Container(
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
        body: Stack(children: [
          Positioned(bottom: 0, child: _buildBottom()),
        ]),
      ),
    );
  }

  Widget _buildBottom() {
    return SizedBox(
      width: mediaSize.width,
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
    );
  }

  Widget _buildForm() {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Create Menu",
            style: AppStyles.welcomeText(context),
          ),
          _buildGreyText("Please insert your menu details"),
          const SizedBox(height: 20),
          _buildGreyText("Menu Name"),
          _buildInputField(
            menuNameController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Menu Name is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildGreyText("Menu Price"),
          _buildInputField(
            menuPriceController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Menu Price is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildGreyText("Menu Description"),
          _buildInputField(
            menuDescriptionController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Menu Description is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildGreyText("Menu Category"),
          _buildDropdownField(),
          const SizedBox(height: 10),
          _buildImageInput(),
          const SizedBox(height: 20),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildImageInput() {
    return Center(
      child: Column(
        children: [
          _buildGreyText("Menu Image"),
          _imageFile != null
              ? Image.file(
                  File(_imageFile!.path),
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                )
              : Container(
                  height: 50,
                  width: 50,
                  color: Colors.grey[300],
                  child: Icon(Icons.image, color: Colors.grey[600]),
                ),
          TextButton(
            onPressed: _pickImage,
            child: Text(
              _imageFile == null ? "Select Image" : "Change Image",
              style: const TextStyle(
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final XFile? selectedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    setState(() {
      _imageFile = selectedImage;
    });
  }

  Widget _buildGreyText(String text) {
    return Text(
      text,
      style: AppStyles.greyText(context),
    );
  }

  Widget _buildInputField(TextEditingController controller,
      {String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: AppStyles.inputDecoration(""),
    );
  }

  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      value: menuCategoryController,
      items: categories.map((String option) {
        return DropdownMenuItem<String>(
          value: option,
          child: Text(option),
        );
      }).toList(),
      onChanged: (String? value) {
        setState(() {
          menuCategoryController = value;
        });
      },
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: () async {
        if (formKey.currentState!.validate()) {
          if (_imageFile != null) {
            final imageFile = File(_imageFile!.path);
            await db
                .createMenu(
              MenuModel(
                cafeId: widget.cafeId,
                menuName: menuNameController.text,
                menuPrice: double.parse(menuPriceController.text),
                menuDescription: menuDescriptionController.text,
                menuCategory: menuCategoryController!,
                menuImage: imageFile.path,
                isAvailable: true,
              ),
            )
                .whenComplete(() {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CafeMenuPage(cafeId: widget.cafeId),
                ),
              );
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Please select an image")),
            );
          }
        }
      },
      style: AppStyles.loginButtonStyle(myColor),
      child: const Text("SUBMIT"),
    );
  }
}
