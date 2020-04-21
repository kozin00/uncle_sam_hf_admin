import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

import '../db/category.dart';
import '../db/product.dart';

class UpdateProducts extends StatefulWidget {
  final String id;

  UpdateProducts(this.id);

  @override
  _UpdateProductsState createState() => _UpdateProductsState();
}

class _UpdateProductsState extends State<UpdateProducts> {
  List<DocumentSnapshot> productDetails = <DocumentSnapshot>[];

  CategoryService _categoryService = new CategoryService();
  ProductService _productService = new ProductService();

  GlobalKey<FormState> _formkey = new GlobalKey<FormState>();
  TextEditingController productnamecontroller = new TextEditingController();
  TextEditingController priceController = new TextEditingController();
  TextEditingController saleController = new TextEditingController();
  TextEditingController quantityController = new TextEditingController();
  TextEditingController requiredController = new TextEditingController();
  TextEditingController descriptionController = new TextEditingController();
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

  void getProductDetails() async {
    var data = await _productService.getProduct(widget.id);
    setState(() {
      productDetails = data;
      _currentCategory = productDetails[0].data['category'];
    });
    print(productDetails[0].data['description']);
  }

  @override
  void initState() {
    _getCategories();
    getProductDetails();
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
                        controller: productnamecontroller,
                        decoration: InputDecoration(
                          hintText: productDetails[0].data['name'],
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
                          padding:
                              const EdgeInsets.fromLTRB(10.0, 8.0, 8.0, 8.0),
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
                      padding: const EdgeInsets.only(right: 350.0),
                      child: Text(
                        'Quantity: ',
                        style: TextStyle(color: Colors.red[600]),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 12.0, right: 12.0, bottom: 12.0),
                      child: TextFormField(
                        controller: quantityController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: '${productDetails[0].data['quantity']}',
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 365.0),
                      child: Text(
                        'Price: ',
                        style: TextStyle(color: Colors.red[600]),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 12.0, right: 12.0, bottom: 12.0),
                      child: TextFormField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: '${productDetails[0].data['price']}',
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 370.0),
                      child: Text(
                        'Sale: ',
                        style: TextStyle(color: Colors.red[600]),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 12.0, right: 12.0, bottom: 12.0),
                      child: TextFormField(
                        controller: saleController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Enter the new sale price',
                        ),
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
                                hintText: productDetails[0]
                                    .data['required']
                                    .join(',')) ??
                            '',
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
                            hintText: productDetails[0].data['description'] ?? ''),
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

    setState(() {
      categories = data;
      categoriesDropDown = getCategoriesDropDown();
      _currentCategory = " ";
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

  void _selectImage(Future<File> pickImage, int imageNumber) async {
    File tempImg = await pickImage;
    switch (imageNumber) {
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
      return Container(
        child: productDetails[0].data['images'][0][1] == null
            ? Container()
            : Image.network(productDetails[0].data['images'][0],
                fit: BoxFit.fill, width: double.infinity),
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
      return Container(
        child: productDetails[0].data['images'][0] == null
            ? Container()
            : Image.network(productDetails[0].data['images'][1],
                fit: BoxFit.fill, width: double.infinity),
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
    double sale;

    if (requiredController.text.isNotEmpty)
      productDetails[0].data['required'] = requiredController.text.split(',');
    if (productnamecontroller.text.isNotEmpty)
      productDetails[0].data['name'] = productnamecontroller.text;
    if (priceController.text.isNotEmpty)
      productDetails[0].data['price'] = priceController.text;
    if (descriptionController.text.isNotEmpty)
      productDetails[0].data['description'] = descriptionController.text;
    if (quantityController.text.isNotEmpty)
      productDetails[0].data['quantity'] = quantityController.text;
    productDetails[0].data['category'] = _currentCategory;

    if (saleController.text.isEmpty) {
      sale = 0;
    } else {
      sale = double.parse(saleController.text);
    }

    if (_image1 != null && _image2 != null) {
      String ImageUrl1;
      String ImageUrl2;
      final FirebaseStorage storage = FirebaseStorage.instance;
      final String picture1 =
          "${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";
      StorageUploadTask task1 = storage.ref().child(picture1).putFile(_image1);

      final String picture2 =
          "2${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";
      StorageUploadTask task2 = storage.ref().child(picture2).putFile(_image2);

      StorageTaskSnapshot snapshot1 =
          await task1.onComplete.then((snapshot) => snapshot);
      await task2.onComplete.then((snapshot2) async {
        ImageUrl1 = await snapshot1.ref.getDownloadURL();
        ImageUrl2 = await snapshot2.ref.getDownloadURL();
        List<String> imageList = [ImageUrl1, ImageUrl2];

        _productService.updateProduct(
          productName: productDetails[0].data['name'],
          price: productDetails[0].data['price'],
          quantity: productDetails[0].data['quantity'],
          images: imageList,
          sale: sale,
          description: productDetails[0].data['description'],
          productid: productDetails[0].data['id'],
          category: productDetails[0].data['category'],
          required: productDetails[0].data['required'],
        );
      }).then((value) {
        return null;
      });
    } else {
      _productService.updateProduct(
        productid: productDetails[0].data['id'],
        productName: productDetails[0].data['name'],
        price: productDetails[0].data['price'],
        quantity: productDetails[0].data['quantity'],
        images: productDetails[0].data['images'],
        sale: sale,
        description: productDetails[0].data['description'],
        category: productDetails[0].data['category'],
        required: productDetails[0].data['required'],
      );
    }
    Navigator.pop(context);
    Fluttertoast.showToast(msg: 'product updated');
  }
}
