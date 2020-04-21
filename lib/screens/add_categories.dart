import 'dart:io';
import 'dart:async';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter/material.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

import '../db/category.dart';

class AddCategories extends StatefulWidget {
  @override
  _AddCategoriesState createState() => _AddCategoriesState();
}

class _AddCategoriesState extends State<AddCategories> {
  CategoryService _categoryService = new CategoryService();

  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  TextEditingController categoryNameController = new TextEditingController();

  Color white = Colors.white;
  Color black = Colors.black;
  Color grey = Colors.grey;

  File _image1;

  bool _isLoading = false;

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
          'Add Category',
          style: TextStyle(color: black),
        ),
        elevation: 0.1,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          children: <Widget>[
            Stack(
              children: <Widget>[
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: 200,
                      height: 200,
                      child: OutlineButton(
                        borderSide:
                        (_image1 == null) ? BorderSide(color: grey.withOpacity(0.5), width: 2.5) : BorderSide(color: Colors.white),
                        onPressed: () {
                          _selectImage(
                              ImagePicker.pickImage(source: ImageSource.gallery, ),);
                        },
                        child: _displayImage1(),
                      ),
                    ),
                  ),
                ),
                _isLoading
                    ? Positioned(
                        child: Container(),
                      )
                    : Container()
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Enter a category name with a maximum of 20 characters',
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
                controller: categoryNameController,
                decoration: InputDecoration(
                  hintText: 'Category Name',
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'You must enter a category name';
                  } else {
                    if (value.length > 20) {
                      return 'Category name can\'t have more than 20 letters';
                    }
                  }
                  return null;
                },
              ),
            ),
            //select category

            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0),
              child: FlatButton(
                color: Colors.red,
                textColor: Colors.white,
                child: Text('Add Category'),
                onPressed: () {
                  _validateAndUpload();
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  void _selectImage(Future<File> pickImage) async {
    File tempImg = await pickImage;
    setState(() {
      _image1 = tempImg;
    });
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
      return Container(
        child: Image.file(
          _image1,
          fit: BoxFit.fitWidth,
          width: double.infinity,
        ),
      );
    }
  }


  void _validateAndUpload() async {
    if (_formKey.currentState.validate()) {

      if (_image1 != null) {
        setState(() {
          _isLoading = true;
        });

        String ImageUrl1;

        final FirebaseStorage storage = FirebaseStorage.instance;
        final String picture1 =
            "${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";
        StorageUploadTask task1 =
        storage.ref().child(picture1).putFile(_image1);
        await task1.onComplete.then((snapshot1) async {
          ImageUrl1 = await snapshot1.ref.getDownloadURL();


          _categoryService.createCategory(
            categoryNameController.text,
            ImageUrl1,
          );
        }).then((value) {
          setState(() {
            _isLoading = false;
          });

          return null;
        });
        Navigator.pop(context);
        _formKey.currentState.reset();

        Fluttertoast.showToast(msg: 'Category created');
      } else {
        Fluttertoast.showToast(msg: "Select an image");
      }
    }
  }
}

/*  void _validateAndUpload() async {
    if (_formKey.currentState.validate() && _image1 != null) {
      setState(() {
        _isLoading = true;
      });

      String imageUrl1;

      final FirebaseStorage storage = FirebaseStorage.instance;
      final String picture1 =
          "${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";
      StorageUploadTask task1 = storage.ref().child(picture1).putFile(_image1);
      await task1.onComplete.then((snapshot1) async {
        imageUrl1 = await snapshot1.ref.getDownloadURL();

        _categoryService.createCategory(
          categoryNameController.text,
          imageUrl1,
        );

      }).then((value) {
        setState(() {
          _isLoading = false;
        });
        return null;
      });
      _formKey.currentState.reset();
      Navigator.pop(context);
      Fluttertoast.showToast(msg: 'Category created');
    } else {
      Fluttertoast.showToast(msg: "Select an image");
    }
  }
}*/
