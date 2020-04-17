import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:uuid/uuid.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ProductService {

  Firestore _fireStore = Firestore.instance;
  String ref = 'products';
  Fluttertoast flutterToast = new Fluttertoast();

  void uploadProduct({String productName, List required, String category, String description,
              int quantity, List images, double price}) {
    var id = Uuid();
    String productId = id.v1();

    _fireStore.collection(ref).document(productId).setData({
      'name': productName,
      'id': productId,
      'category': category,
      'images': images,
      'price': price,
      'quantity': quantity,
      'required': required,
      'description': description,
    });
  }

  void updateProduct(
      {double sale, String productName, String productid, String description, List required,
                String category, int quantity, List images, double price}) {
    try {
      _fireStore.collection(ref).document(productid).updateData({
        'name': productName,
        'id': productid,
        'sale': sale,
        'category': category,
        'images': images,
        'quantity': quantity,
        'price': price,
        'description': description,
        'required': required
      });
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to update item.');
    }
  }

  void deleteProduct(String id) {
    try {
      _fireStore.collection(ref).document(id).delete();
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to remove item.');
    }
  }

  Future<List<DocumentSnapshot>> getProducts() =>
      _fireStore.collection(ref).getDocuments().then((snap) {
        return snap.documents;
      });


  Future<List<DocumentSnapshot>> getProduct(String productId) => _fireStore
          .collection(ref)
          .where('id', isEqualTo: productId)
          .getDocuments()
          .then((snap) {
        return snap.documents;
      });
}
