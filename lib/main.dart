import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:irent/screens/SignupScreen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'helpers/message.dart';
import 'helpers/message_list.dart';
import 'helpers/permissions.dart';
import 'helpers/token_monitor.dart';


void main() async {
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
