import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:collection';
class CategoryService {
  Firestore _fireStore = Firestore.instance;
  String ref = 'categories';
  Fluttertoast flutterToast=new Fluttertoast();

  void createCategory(String name, String image) {
    var id = Uuid();
    String categoryId = id.v1();

    _fireStore.collection(ref).document(categoryId).setData({'Category': name,'images': image});
  }

  Future<List<DocumentSnapshot>> getCategories() =>
      _fireStore.collection(ref).getDocuments().then((snap) {
        return snap.documents;
      });

  Future<List<DocumentSnapshot>> getSuggestions(String suggestion) => _fireStore
          .collection(ref)
          .where('Category', isEqualTo: suggestion)
          .getDocuments()
          .then((snap) {
        return snap.documents;
      });

  void deleteProduct(String id){
    try{
      _fireStore.collection(ref).document(id).delete();
    }catch(e){
      Fluttertoast.showToast(msg: 'Failed to remove item.');
    }
  }
}
