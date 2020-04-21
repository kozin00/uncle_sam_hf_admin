import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:unclesamhfadmin/screens/admin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final formkey = new GlobalKey<FormState>();

  SharedPreferences prefs;

  bool loading = false;
  bool isLoggedin = false;

  FirebaseUser currentUser;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: <Widget>[
        Container(
          height: double.infinity,
          color: Colors.black,
        ),
        Align(
          alignment: Alignment.center,
          child: Container(
            child: Column(children: <Widget>[
              SizedBox(
                height: 150,
              ),
         //     Image.asset('images/logo.jpg'),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(50.0, 0.0, 50.0, 8.0),
                      child: Material(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40.0),
                            side: BorderSide(color: Colors.grey[900])),
                        clipBehavior: Clip.antiAlias,
                        color: Colors.black38,
                        child: MaterialButton(
                          splashColor: Colors.white70,
                          onPressed: () {
                            _signIn();
                          },
                          highlightColor: Colors.white70,
                          elevation: 18.0,
                          child: Row(
                            children: <Widget>[

                              Padding(
                                padding: const EdgeInsets.only(left: 10.0),
                                child: Text(
                                  "Sign in with Google",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: Container(
            child: loading
                ? Container(
                    color: Colors.white.withOpacity(0.3),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                    ),
                  )
                : Container(),
          ),
        )
      ],
    ));
  }

  Future _signIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      loading = true;
    });

    GoogleSignInAccount googleUser = await googleSignIn.signIn();
    GoogleSignInAuthentication googleSignInAuthentication =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken);

    FirebaseUser firebaseUser = (await _firebaseAuth.signInWithCredential(credential)).user;

    if (firebaseUser != null) {
      final QuerySnapshot result = await Firestore.instance
          .collection('admin')
          .where('id', isEqualTo: firebaseUser.uid)
          .getDocuments();
      final List<DocumentSnapshot> documents = result.documents;
      if (documents.length == 0) {
        Firestore.instance
            .collection('admin')
            .document(firebaseUser.uid)
            .setData({
          'nickname': firebaseUser.displayName,
          'id': firebaseUser.uid,
        });

        String displayName = firebaseUser.displayName;

        String id = firebaseUser.uid;
        await prefs.setString('id', id);
        await prefs.setString('nickname', displayName);
      } else {
        await prefs.setString('id', documents[0]['id']);
        await prefs.setString('nickname', documents[0]['nickname']);
      }

      this.setState(() {
        this.loading = false;
      });

      Fluttertoast.showToast(msg: 'Sign in successful');
      Navigator.pushReplacement(context, CupertinoPageRoute(builder: (context) {
        return Admin();
      }));
    } else {
      this.setState(() {
        loading = false;
      });
      Fluttertoast.showToast(msg: "Sign in failed");
    }
  }
}
