import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uuid/uuid.dart';

class Announcements extends StatefulWidget {
  @override
  _AnnouncementsState createState() => _AnnouncementsState();
}

class _AnnouncementsState extends State<Announcements> {
  GlobalKey<FormState> _formkey = new GlobalKey<FormState>();
  TextEditingController _textEditingController=TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Announcement',
          style: TextStyle(color: Colors.black),
        ),
        elevation: 0.1,
      ),
      body: Form(
        key:_formkey,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextFormField(
                controller: _textEditingController,
                decoration: InputDecoration(
                  hintText: 'Announcement',
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'You must enter a product name';
                  } else {
                    if (value.length > 150) {
                      return 'Product name can\'t have more than 100 letters';
                    }
                  }
                  return null;
                },
              ),
            ),
            FlatButton(
              color: Colors.red[600],
              textColor: Colors.white,
              child: Text('Post'),
              onPressed: () {
                _validateAndUpload();
              },
            )
          ],
        ),
      ),
    );
  }

  _validateAndUpload(){
    if(_formkey.currentState.validate()){
      var id=Uuid();
      String announcementid=id.v1();
      try{
        Firestore.instance.collection('announcements').document(announcementid).setData({
          'announcement': _textEditingController.text
        });
        Fluttertoast.showToast(msg: "Successfully posted announcement.");
      }
      catch(e){
        Fluttertoast.showToast(msg: "Couldn't post announcement.");
      }

      Navigator.pop(context);
    }
  }
}
