import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyRents extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MyRentsState();

}

class _MyRentsState extends State<MyRents> {
  // List Items I Have Rented

  /*
  * item title
  * item description
  * rented on
  * rented from
  * return date
  * */

  // actions
  /*
  *  mark item as returned
  * */

  GoogleSignInAccount _currentUser;
  CollectionReference myrents =
  FirebaseFirestore.instance.collection("rented");

  CollectionReference mybids = FirebaseFirestore.instance.collection("bids");

  final Stream<QuerySnapshot> _rentStream = FirebaseFirestore.instance.collection('rented').snapshots();

  GoogleSignIn _googleSignIn = GoogleSignIn(scopes: <String>['email']);

  void initState() {
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      setState(() {
        _currentUser = account;
      });
    });
    _googleSignIn.signInSilently();
    super.initState();
  }

  Widget itemCard() {
    return Card(
      margin: EdgeInsets.all(10),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Container(
              child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.asset('assets/paint.jpg')
              ),
            ),
            Padding(
              padding: EdgeInsets.all(6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          child: Text('Item Title', style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),)
                      ),
                      Container(
                          child: Text('Rented On', style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w300),)
                      ),
                      Container(
                          child: Text('To Be Returned On', style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w300),)
                      ),
                    ],
                  ),

                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Colors.deepOrangeAccent),
                      ),
                      onPressed: () {
                        print('Mark the item as returned to owner');
                      },
                      child: Text('Mark As Returned', style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 17),),
                    )
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        backgroundColor: Theme
            .of(context)
            .backgroundColor,
        appBar: AppBar(
          backgroundColor: Theme
              .of(context)
              .backgroundColor,
          title: Text('My Rentals'),
          foregroundColor: Theme
              .of(context)
              .backgroundColor,
          elevation: 0,
        ),
        body: StreamBuilder<QuerySnapshot>(
            stream: _rentStream,
            builder: (BuildContext context,
                AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text('Something went wrong');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Text("Loading");
              }

              return new ListView(
                children: snapshot.data.docs.map((DocumentSnapshot document) {
                  Map<String, dynamic> data = document.data() as Map<
                      String,
                      dynamic>;
                  return itemCard();
                }).toList(),
              );
            }
        ));
  }
}