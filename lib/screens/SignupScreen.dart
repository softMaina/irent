import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert' show json;
import "package:http/http.dart" as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:irent/screens/HomeScreen.dart';
import 'package:irent/screens/RootPage.dart';
import 'package:irent/sizeConfig.dart';

GoogleSignIn _googleSignIn = GoogleSignIn(
  // Optional clientId
  // clientId: '479882132969-9i9aqik3jfjd7qhci1nqf0bm2g71rm1u.apps.googleusercontent.com',
  scopes: <String>[
    'email',
  ],
);

class SignupScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  GoogleSignInAccount _currentUser;
  String _contactText = '';

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      setState(() {
        _currentUser = account;
      });
    });
    _googleSignIn.signInSilently();
  }

  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
      Navigator.push(context, MaterialPageRoute(builder: (context)=> RootPage()));
    } catch (error) {
      print(error);
    }
  }

  Future<void> _handleSignOut() => _googleSignIn.disconnect();

  Widget _buildBody() {
    GoogleSignInAccount user = _currentUser;
    if (user != null){
      print(user.email);
      return RootPage();
    }else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            height: 100,
            width: 150,
            decoration: BoxDecoration(
              color: Colors.transparent,
              image: DecorationImage(
                image: AssetImage('assets/logo.png'),
                fit: BoxFit.cover,
              ),
            ),

          ),
          const Text("Welcome to iRent", style: TextStyle(
              color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              // background color
              primary: Colors.blueAccent,
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              textStyle: TextStyle(fontSize: 20),
            ),
            child: const Text('GOOGLE SIGNIN', style: TextStyle(fontSize: 25),),
            onPressed: _handleSignIn,
          ),
        ],
      );
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
          children: [
            Container(
              height: SizeConfig.screenHeight,
              width: SizeConfig.screenWidth,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/signup.jpg'),
                  fit: BoxFit.cover,
                ),
              ),

            ),
            ConstrainedBox(
              constraints: const BoxConstraints.expand(),
              child: _buildBody(),
            )
          ],
        ));
  }
}
