import 'package:flutter/material.dart';
import 'package:unclesamhfadmin/screens/login.dart';
import 'package:unclesamhfadmin/screens/admin.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() {
  runApp(UncleSam());
}

class UncleSam extends StatefulWidget {
  @override
  UncleSamState createState() => UncleSamState();
}

class UncleSamState extends State<UncleSam> {
  bool loggedIn = false;

  @override
  void initState() {
    super.initState();
    _isSignedIn();
  }

  void _isSignedIn() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    bool isLoggedIn = await googleSignIn.isSignedIn();
    if (isLoggedIn) {
      setState(() {
        loggedIn = true;
      });
    } else {
      setState(() {
        loggedIn = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: loggedIn ? Admin() : Login(),
    );
  }
}
