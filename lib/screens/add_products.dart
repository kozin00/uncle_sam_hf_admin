import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

import '../db/category.dart';
import '../db/product.dart';

class AddProducts extends StatefulWidget {
  @override
  _AddProductsState createState() => _AddProductsState();
}

class _AddProductsState extends State<AddProducts> {
  CategoryService _categoryService = new CategoryService();
  ProductService _productService = new ProductService();

  GlobalKey<FormState> _formkey = new GlobalKey<FormState>();
  TextEditingController productNameController = new TextEditingController();
  TextEditingController priceController = new TextEditingController();
  TextEditingController quantityController = new TextEditingController();
  TextEditingController descriptionController = new TextEditingController();
  TextEditingController requiredController = new TextEditingController();


  List<DocumentSnapshot> categories = <DocumentSnapshot>[];
  List<DropdownMenuItem<String>> categoriesDropDown =
      <DropdownMenuItem<String>>[];

  String _currentCategory = "";

  Color white = Colors.white;
  Color black = Colors.black;
  Color grey = Colors.grey;
  int countRequired = 3;
  List<String> selectedSizes = <String>[];

  File _image1;
  File _image2;

  bool _isloading = false;

  @override
  void initState() {
    _getCategories();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        backgroundColor: white,
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Add Products',
          style: TextStyle(color: black),
        ),
        elevation: 0.1,
      ),
      body: Form(
        key: _formkey,
        child: SingleChildScrollView(
          child: _isloading
              ? Positioned(
                  child: Container(),
                )
              : Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              height: 200,
                              width: 100,
                              child: OutlineButton(
                                borderSide: BorderSide(
                                    color: grey.withOpacity(0.5), width: 2.5),
                                onPressed: () {
                                  _selectImage(
                                      ImagePicker.pickImage(
                                          source: ImageSource.gallery),
                                      1);
                                },
                                child: _displayImage1(),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              width: 100,
                              height: 200,
                              child: OutlineButton(
                                borderSide: BorderSide(
                                    color: grey.withOpacity(0.5), width: 2.5),
                                onPressed: () {
                                  _selectImage(
                                      ImagePicker.pickImage(
                                          source: ImageSource.gallery),
                                      2);
                                },
                                child: _displayImage2(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Enter a product name with 25 characters maximum',
                        style: TextStyle(
                          color: Colors.red[700],
                          fontSize: 14.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: TextFormField(
                        controller: productNameController,
                        decoration: InputDecoration(
                          hintText: 'Product Name',
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'You must enter a product name';
                          } else {
                            if (value.length > 25) {
                              return 'Product name can\'t have more than 25 letters';
                            }
                          }
                          return null;
                        },
                      ),
                    ),
                    //select category
                    Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Category: ',
                            style: TextStyle(color: Colors.red[600]),
                          ),
                        ),
                        DropdownButton(
                          items: categoriesDropDown,
                          onChanged: changeSelectedCategory,
                          value: _currentCategory,
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: TextFormField(
                        controller: quantityController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Quantity',
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'The product name must not be empty';
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: TextFormField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Price',
                          hintText: 'Price',
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'The product name must not be empty';
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 350.0),
                      child: Text(
                        'Required: ',
                        style: TextStyle(color: Colors.red[600]),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: TextFormField(
                        controller: requiredController,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                            hintText:
                                "Use a comma to separate different required items"),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'You must enter a required item';
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 315.0),
                      child: Text(
                        'Description: ',
                        style: TextStyle(color: Colors.red[600]),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: TextFormField(

                        controller: descriptionController,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,

                        decoration: InputDecoration(
                            hintText:
                            "Enter a description of the product"),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'You must enter a description of the product';
                          }
                          return null;
                        },

                      ),
                    ),
                    FlatButton(
                      color: Colors.red[600],
                      textColor: Colors.white,
                      child: Text('Add Product'),
                      onPressed: () {
                        _validateAndUpload();
                      },
                    )
                  ],
                ),
        ),
      ),
    );
  }

  _getCategories() async {
    List<DocumentSnapshot> data = await _categoryService.getCategories();
    print(data.length);
    setState(() {
      categories = data;
      categoriesDropDown = getCategoriesDropDown();
      _currentCategory = categories[0].data['Category'];
    });
  }

  List<DropdownMenuItem<String>> getCategoriesDropDown() {
    List<DropdownMenuItem<String>> items = new List();

    for (int i = categories.length - 1; i >= 0; i--) {
      setState(() {
        items.insert(
            0,
            DropdownMenuItem(
                child: Text('${categories[i].data['Category']}'),
                value: categories[i].data['Category']));
      });
    }
    return items;
  }

  changeSelectedCategory(String selectedCategory) {
    setState(() {
      _currentCategory = selectedCategory;
    });
  }

  void _selectImage(Future<File> pickImage, int ImageNumber) async {
    File tempImg = await pickImage;
    switch (ImageNumber) {
      case 1:
        setState(() {
          _image1 = tempImg;
        });
        break;
      case 2:
        setState(() {
          _image2 = tempImg;
        });
        break;
    }
  }

  Widget _displayImage1() {
    if (_image1 == null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(14, 50, 14, 50),
        child: Icon(
          Icons.add,
          color: grey,
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          child: Image.file(
            _image1,
            fit: BoxFit.fill,
            width: double.infinity,
          ),
        ),
      );
    }
  }

  Widget _displayImage2() {
    if (_image2 == null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(14, 50, 14, 50),
        child: Icon(
          Icons.add,
          color: grey,
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
            child: Image.file(
          _image2,
          fit: BoxFit.fill,
        )),
      );
    }
  }

  void _validateAndUpload() async {
    if (_formkey.currentState.validate()) {
      if (_image1 != null && _image2 != null) {
        String imageUrl1;
        String imageUrl2;

        List<String> requiredList = requiredController.text.split(',');

        final FirebaseStorage storage = FirebaseStorage.instance;
        final String picture1 =
            "${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";
        StorageUploadTask task1 =
            storage.ref().child(picture1).putFile(_image1);

        final String picture2 =
            "2${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";
        StorageUploadTask task2 =
            storage.ref().child(picture2).putFile(_image2);

        StorageTaskSnapshot snapshot1 =
            await task1.onComplete.then((snapshot) => snapshot);
        await task2.onComplete.then((snapshot2) async {
          imageUrl1 = await snapshot1.ref.getDownloadURL();
          imageUrl2 = await snapshot2.ref.getDownloadURL();
          List<String> imageList = [imageUrl1, imageUrl2];

          _productService.uploadProduct(
            productName: productNameController.text,
            price: double.parse(priceController.text),
            quantity: int.parse(quantityController.text),
            images: imageList,
            category: _currentCategory,
            required: requiredList,
            description: descriptionController.text
          );

        }).then((value) {
          return null;
        });
        _formkey.currentState.reset();
        Navigator.pop(context);
        Fluttertoast.showToast(msg: 'Product added');
      } else {
        Fluttertoast.showToast(
            msg: "Please enter at least on image to proceed");
      }
    }
  }
}
