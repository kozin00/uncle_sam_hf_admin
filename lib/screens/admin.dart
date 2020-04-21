import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

//import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:unclesamhfadmin/db/product.dart';
import 'package:unclesamhfadmin/screens/announcements.dart';
import 'package:unclesamhfadmin/screens/login.dart';
import 'package:unclesamhfadmin/screens/orders.dart';
import 'package:unclesamhfadmin/screens/transactionHistory.dart';
import 'package:unclesamhfadmin/screens/add_categories.dart';
import 'package:unclesamhfadmin/screens/update_products.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../db/category.dart';

import 'add_products.dart';

enum Page { dashboard, manage }

class Admin extends StatefulWidget {
  @override
  _AdminState createState() => _AdminState();
}

class _AdminState extends State<Admin> {
  String currentUserId;

  Page _selectedPage = Page.dashboard;
  MaterialColor active = Colors.red;
  MaterialColor notActive = Colors.grey;
  bool isLoading = false;
  int categoryNumber;
  int productsNumber;
  int usersNumber;

  final GoogleSignIn googleSignIn = GoogleSignIn();

  ProductService _productService = ProductService();
  CategoryService _categoryService = CategoryService();
  List<DocumentSnapshot> productsList = <DocumentSnapshot>[];
  List<DocumentSnapshot> categoriesList = <DocumentSnapshot>[];

  //final FirebaseMessaging firebaseMessaging = new FirebaseMessaging();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      new FlutterLocalNotificationsPlugin();
  TextEditingController categoryController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    getPrefs();
    getStatistics();
  }

  void getStatistics() async {
    List<DocumentSnapshot> categoryData =
        await _categoryService.getCategories();
    List<DocumentSnapshot> productsData = await _productService.getProducts();
    List<DocumentSnapshot> userData = await Firestore.instance
        .collection('users')
        .getDocuments()
        .then((snap) => snap.documents);
    setState(() {
      categoryNumber =  categoryData.length ?? 0;
      productsNumber = productsData.length ?? 0;
      usersNumber = userData.length ?? 0;
    });
  }

  void signOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    googleSignIn.signOut();

    Navigator.pushReplacement(context, CupertinoPageRoute(builder: (context) {
      return Login();
    }));
    Fluttertoast.showToast(msg: 'Signed Out Successfully');
  }

  Widget productsView() {
    return StreamBuilder(
      stream: Firestore.instance.collection('products').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Container();
        } else {
          var data = snapshot.data.documents;
          productsList = data;
          return productsList.length == 0
              ? Container(
                  child: Center(
                    child: Text("No products."),
                  ),
                )
              : ListView.builder(
                  itemCount: productsList.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(productsList[index].data['name']),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _removeProduct(productsList[index].data['name'],
                              productsList[index].data['id'], 0);
                        },
                      ),
                    );
                  });
        }
      },
    );
  }

  Widget CategoryView() {
    return StreamBuilder(
      stream: Firestore.instance.collection('categories').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Container();
        } else {
          categoriesList = snapshot.data.documents;
          return categoriesList.length == 0
              ? Container(
                  child: Center(
                    child: Text("No categories."),
                  ),
                )
              : ListView.builder(
                  itemCount: categoriesList.length,
                  itemBuilder: (context, index) {

                    return ListTile(
                      title: Text(categoriesList[index].data['Category']),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _removeProduct(categoriesList[index].data['Category'],
                              categoriesList[index].documentID, 1);
                        },
                      ),
                    );
                  });
        }
      },
    );
  }

  void _removeProduct(String productName, String id, int type) {
    var alert = AlertDialog(
      content: Text("Remove $productName from product list?"),
      actions: <Widget>[
        FlatButton(
          onPressed: () {
            switch (type) {
              case 0:
                _productService.deleteProduct(id);
                Navigator.pop(context);
                break;
              case 1:
                _categoryService.deleteProduct(id);
                Navigator.pop(context);
                break;
            }
          },
          child: Text("Yes"),
        ),
        FlatButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("No"),
        )
      ],
    );
    showDialog(context: context, builder: (_) => alert);
  }

  Widget updateProductsView() {
    return StreamBuilder(
      stream: Firestore.instance.collection('products').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Container();
        } else {
          var data = snapshot.data.documents;
          productsList = data;
          return productsList.length == 0
              ? Container(
                  child: Center(
                    child: Text("No products."),
                  ),
                )
              : ListView.builder(
                  itemCount: productsList.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                        onTap: () {
                          return Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => UpdateProducts(
                                      productsList[index].data['id'])));
                        },
                        child: Column(
                          children: <Widget>[
                            ListTile(
                              title: Text(productsList[index].data['name']),
                            ),
                            Divider(color: Colors.black38)
                          ],
                        ));
                  });
        }
      },
    );
  }

  void alertFunction(int type) {
    var function;
    switch (type) {
      case 0:
        function = productsView();
        break;
      case 1:
        function = CategoryView();
        break;
      case 2:
        function = updateProductsView();
        break;
    }

    var alert = AlertDialog(
        content: Container(
      width: 300,
      height: 300,
      child: function,
    ));
    showDialog(context: context, builder: (_) => alert);
  }

/*
  void registerNotification() {
    firebaseMessaging.requestNotificationPermissions();
    firebaseMessaging.configure(onMessage: (Map<String, dynamic> message) {
      showNotification(message['notification']);
      return;
    }, onResume: (Map<String, dynamic> message) {
      print('onResume: $message');
      return;
    }, onLaunch: (Map<String, dynamic> message) {
      return;
    });

    firebaseMessaging.getToken().then((token) {
      Firestore.instance
          .collection('admin')
          .document(currentUserId)
          .updateData({'pushToken': token});
    }).catchError((err) {
      Fluttertoast.showToast(msg: err.toString());
    });
  }

  void configLocalNotification() {
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void showNotification(message) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        Platform.isAndroid
            ? 'com.dfa.juicefactoryadmin'
            : 'com.dyutq.juicefactoryadmin',
        'Juice Factory',
        'Description',
        playSound: true,
        enableVibration: true,
        importance: Importance.Max,
        priority: Priority.High);
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(0, message['title'].toString(),
        message['body'].toString(), platformChannelSpecifics,
        payload: json.encode(message));
  }*/

  void getPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUserId = prefs.getString('id');
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: new AppBar(
        title: Row(
          children: <Widget>[
            Expanded(
              child: FlatButton.icon(
                  onPressed: () {
                    setState(() {
                      return _selectedPage = Page.dashboard;
                    });
                  },
                  icon: Icon(
                    Icons.dashboard,
                    color: _selectedPage == Page.dashboard ? active : notActive,
                  ),
                  label: Text('')),
            ),
            Expanded(
              child: FlatButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedPage = Page.manage;
                  });
                },
                icon: Icon(
                  Icons.sort,
                  color: _selectedPage == Page.manage ? active : notActive,
                ),
                label: Text(''),
              ),
            ),
            /*  Expanded(
              child: FlatButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedPage = Page.message;
                  });
                },
                icon: Icon(
                  Icons.mail,
                  color: _selectedPage == Page.message ? active : notActive,
                ),
                label: Text(' '),
              ),
            )*/
          ],
        ),
        elevation: 0.0,
        backgroundColor: Colors.white,
      ),
      body: _loadScreen(),
    );
  }

  Widget _loadScreen() {
    switch (_selectedPage) {
      case Page.dashboard:
        return Column(
          children: <Widget>[
            ListTile(
              subtitle: FlatButton.icon(
                onPressed: null,
                icon: Icon(
                  Icons.attach_money,
                  size: 30.0,
                  color: Colors.green,
                ),
                label: Text('0',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 30.0, color: Colors.green)),
              ),
              title: Text(
                'Revenue',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24.0, color: Colors.grey),
              ),
            ),
            Expanded(
              child: GridView(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                ),
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Card(
                      child: Column(
                        children: <Widget>[
                          Padding(
                              padding:
                                  const EdgeInsets.only(top: 12.0, right: 3.0),
                              child: Icon(
                                Icons.people,
                                size: 40.0,
                                color: Colors.grey,
                              )),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListTile(
                              title: Text(
                                'Users',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 20.0),
                              ),
                              subtitle: Text(
                                '$usersNumber',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: active, fontSize: 40.0),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: InkWell(
                      onTap: () {
                        alertFunction(1);
                      },
                      child: Card(
                        child: Column(
                          children: <Widget>[
                            Padding(
                                padding: const EdgeInsets.only(
                                    top: 12.0, right: 3.0),
                                child: Icon(Icons.category,
                                    size: 40.0, color: Colors.grey)),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListTile(
                                title: Text(
                                  'Categories',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 20.0),
                                ),
                                subtitle: Text(
                                  '$categoryNumber',
                                  textAlign: TextAlign.center,
                                  style:
                                      TextStyle(color: active, fontSize: 40.0),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: InkWell(
                      onTap: () {
                        alertFunction(0);
                      },
                      child: Card(
                        child: Column(
                          children: <Widget>[
                            Padding(
                                padding: const EdgeInsets.only(
                                    top: 12.0, right: 3.0),
                                child: Icon(Icons.track_changes,
                                    size: 40.0, color: Colors.grey)),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListTile(
                                title: Text(
                                  'Products',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 20.0),
                                ),
                                subtitle: Text(
                                  '$productsNumber',
                                  textAlign: TextAlign.center,
                                  style:
                                      TextStyle(color: active, fontSize: 40.0),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => Sold()));
                      },
                      child: Card(
                        child: Column(
                          children: <Widget>[
                            Padding(
                                padding: const EdgeInsets.only(
                                    top: 12.0, right: 3.0),
                                child: Icon(Icons.tag_faces,
                                    size: 40.0, color: Colors.grey)),
                            Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: StreamBuilder(
                                  stream: Firestore.instance
                                      .collection('sold')
                                      .snapshots(),
                                  builder: (context,
                                      AsyncSnapshot<QuerySnapshot> snapshot) {
                                    List<DocumentSnapshot> data =
                                        snapshot.data.documents;
                                    return ListTile(
                                      title: Text(
                                        'Sold',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 20.0),
                                      ),
                                      subtitle: Text(
                                        '${data.length}',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: active, fontSize: 40.0),
                                      ),
                                    );
                                  },
                                )),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => Orders()));
                      },
                      child: Card(
                        child: Column(
                          children: <Widget>[
                            Padding(
                                padding: const EdgeInsets.only(
                                    top: 12.0, right: 3.0),
                                child: Icon(Icons.shopping_cart,
                                    size: 40.0, color: Colors.grey)),
                            Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: StreamBuilder(
                                  stream: Firestore.instance
                                      .collection('orders')
                                      .snapshots(),
                                  builder: (context,
                                      AsyncSnapshot<QuerySnapshot> snapshot) {
                                    List<DocumentSnapshot> data =
                                        snapshot.data.documents;
                                    return ListTile(
                                      title: Text(
                                        'Orders',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 20.0),
                                      ),
                                      subtitle: Text(
                                        '${data.length}',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: active, fontSize: 40.0),
                                      ),
                                    );
                                  },
                                )),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: InkWell(
                      onTap: () {
                        signOut();
                      },
                      child: Card(
                        child: Column(
                          children: <Widget>[
                            SizedBox(
                              height: 35,
                            ),
                            Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ListTile(
                                  title: Icon(Icons.exit_to_app,
                                      size: 40.0, color: Colors.blue),
                                  subtitle: Text('Sign Out',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 20.0)),
                                )),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
        break;
      case Page.manage:
        return ListView(
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.add),
              title: Text("Add Product"),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AddProducts()));
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.edit),
              title: Text("Update Product"),
              onTap: () {
                alertFunction(2);
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.change_history),
              title: Text("Products list"),
              onTap: () {
                alertFunction(0);
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.add_circle),
              title: Text("Add category"),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AddCategories()));
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.category),
              title: Text("Category list"),
              onTap: () {
                alertFunction(1);
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.announcement),
              title: Text("Announcements"),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Announcements()));
              },
            ),
          ],
        );
        break;
      default:
        return Container();
    }
  }
}
