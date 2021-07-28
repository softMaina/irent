import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:irent/widgets/makePayment.dart';
import 'package:mpesa_flutter_plugin/mpesa_flutter_plugin.dart';

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
  CollectionReference payments = FirebaseFirestore.instance.collection("payments");

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

  recordPayment(data){
    payments.add(data).then((value) => print('payment inserted in database')).catchError((error){
      print('an error occured recording payment');
    });
  }

  Future<void> lipaNaMpesa(price) async {
    dynamic transactionInitialisation;
    try {
      transactionInitialisation = await MpesaFlutterPlugin.initializeMpesaSTKPush(
          businessShortCode: "174379",
          transactionType: TransactionType.CustomerPayBillOnline,
          amount: double.parse(price),
          partyA:  "254741818156",
          partyB: "174379",
          callBackURL: Uri(scheme: "https",
              host: "mpesa-requestbin.herokuapp.com",
              path: "/1987v1m1"),
//This url has been generated from http://mpesa-requestbin.herokuapp.com/?ref=hackernoon.com for test purposes
          accountReference: "Irent",
          phoneNumber:  "254741818156",
          baseUri: Uri(scheme: "https", host: "sandbox.safaricom.co.ke"),
          transactionDesc: "purchase",
          passKey: "bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f78e6b72ada1ed2c919");

      var result = transactionInitialisation as Map<String, dynamic>;

      if(result.keys.contains("ResponseCode")){
        print('success');
      }

      print(result);
    }

    catch (e) {
      print("CAUGHT EXCEPTION: " + e.toString());
    }
  }

  Widget itemCard(title, rented_from, rented_on, return_on, price) {
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
                          child: Text(title, style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),)
                      ),
                      Container(
                          child: Text('Rented On ${rented_on.toString()}', style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w300),)
                      ),
                      Container(
                          child: Text('To Be Returned On ${return_on.toString()}', style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w300),)
                      ),
                      Container(
                          child: Text('Rented From ${rented_from}', style: TextStyle(
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
                      backgroundColor: MaterialStateProperty.all(Colors.green)
                    ),
                    child: Text('M-Pesa ${price}', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                    onPressed: (){
                        lipaNaMpesa(price);
                    },
                  ),
                ),
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
                  return itemCard(data['title'],data['rented_from'],data['date'],data['return_date'],data['price']);
                }).toList(),
              );
            }
        ));
  }
}