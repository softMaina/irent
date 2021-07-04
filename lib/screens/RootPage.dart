import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:irent/screens/HomeScreen.dart';
import 'package:irent/screens/ProfileScreen.dart';
import 'package:irent/screens/SellerBids.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'UploadScreen.dart';

FirebaseAuth auth = FirebaseAuth.instance;

FirebaseMessaging messaging = FirebaseMessaging.instance;

GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: <String>[
    'email',
  ],
);

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.

  print("Handling a background message: ${message.messageId}");
}

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  'This channel is used for important notifications.', // description
  importance: Importance.max,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();


class RootPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  GoogleSignInAccount _currentUser;
  bool checkIn = false;
  PageController controller = PageController();
  int getPageIndex = 0;



  @override
  void initState() {

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification notification = message.notification;
      AndroidNotification android = message.notification?.android;

      // If `onMessage` is triggered with a notification, construct our own
      // local notification to show to users using the created channel.
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channel.description,
                icon: android.smallIcon,
                // other properties...
              ),
            ));
      }
    });
    super.initState();
  }

  whenPageChanges(int pageIndex) {
    setState(() {
      this.getPageIndex = pageIndex;
    });
  }

  onTapChangePage(int pageIndex) {
    controller.animateToPage(pageIndex,
        duration: Duration(milliseconds: 400), curve: Curves.bounceInOut);
  }

  Scaffold buildHomeScreen() {
    return Scaffold(
      body: PageView(
        children: <Widget>[HomeScreen(), ProfileScreen(), SellerBids()],
        controller: controller,
        onPageChanged: whenPageChanges,
        physics: NeverScrollableScrollPhysics(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Add your onPressed code here!
          await Future.delayed(Duration(milliseconds: 80));
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return UploadScreen();
              },
              fullscreenDialog: true,
            ),
          );
        },
        child: const Icon(Icons.add_circle_outline),
        backgroundColor: Theme.of(context).buttonColor,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: getPageIndex,
        elevation: 9,
        onTap: onTapChangePage,
        backgroundColor: Colors.lightBlue,
        selectedItemColor: Theme.of(context).buttonColor,
        // activeColor: Colors.white,
        // inactiveColor: Colors.white70,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(
                Icons.home_outlined,
                color: Colors.white,
              ),
              title: Text(
                "Home",
                style: TextStyle(color: Colors.white),
              )),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.person_outline_sharp,
                color: Colors.white,
                size: 40,
              ),
              title: Text(
                "Profile",
                style: TextStyle(color: Colors.white),
              )),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_basket_outlined, color: Colors.white),
              title: Text(
                "Orders",
                style: TextStyle(color: Colors.white),
              )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildHomeScreen();
  }
}

class PushNotification {
  PushNotification({
    this.title,
    this.body,
    this.dataTitle,
    this.dataBody,
  });

  String title;
  String body;
  String dataTitle;
  String dataBody;
}
