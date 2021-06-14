import 'package:flutter/material.dart';
import 'package:irent/screens/BuyerHistory.dart';
import 'package:irent/screens/CatalogueScreen.dart';
import 'package:irent/screens/HomeScreen.dart';
import 'package:irent/screens/ProfileScreen.dart';
import 'package:irent/screens/RootPage.dart';
import 'package:irent/screens/SellerBids.dart';
import 'package:irent/screens/SignupScreen.dart';
import 'package:irent/screens/UploadScreen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Irent',
      theme: ThemeData(
        backgroundColor: Color(0xFF0061e2),
        buttonColor: Color(0xFFffa451),
        indicatorColor: Color(0xFFffc501),
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SignupScreen(),
    );
  }
}


