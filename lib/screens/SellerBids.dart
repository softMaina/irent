import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;
FirebaseAuth auth = FirebaseAuth.instance;

class SellerBids extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SellerBidsState();
}

class _SellerBidsState extends State<SellerBids> {
  GoogleSignInAccount _currentUser;
  CollectionReference myuploads =
      FirebaseFirestore.instance.collection("uploads");
  CollectionReference products =
      FirebaseFirestore.instance.collection("products");
  
  CollectionReference rents = FirebaseFirestore.instance.collection("rented");

  List<dynamic> results = [];
  GoogleSignIn _googleSignIn = GoogleSignIn(scopes: <String>['email']);

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      setState(() {
        _currentUser = account;
      });
      print(_currentUser.email);
      getPostnBids();
    });
    _googleSignIn.signInSilently();
  }

  getPostnBids() async {
    var bidsMap = new Map<String, dynamic>();
    await myuploads
        .where('posted_by', isEqualTo: _currentUser.email.toString())
        .get()
        .then((QuerySnapshot qsnapshot) {
      // for each document, take the category_id and post_id and get the data
      qsnapshot.docs.forEach((doc) async {
        // get category_id
        await products
            .doc(doc.get('post_category_id'))
            .collection("posts")
            .doc(doc.get('post_id'))
            .collection("bids")
            .get()
            .then((QuerySnapshot qs) {
          qs.docs.forEach((bids) {
            bidsMap['category'] = doc.get('post_category');
            bidsMap['title'] = doc.get('title');
            bidsMap['price'] = doc.get('price');
            bidsMap['bid_price'] = bids.get('price');
            bidsMap['bid_date'] = bids.get('date');
            setState(() {
              this.results.add(bidsMap);
            });
          });
        });
      });
    });
    print(this.results);
  }

  String convertDateTimeDisplay(String date) {
    final DateFormat displayFormater = DateFormat('yyyy-MM-dd HH:mm:ss.SSS');
    final DateFormat serverFormater = DateFormat('dd-MM-yyyy');
    final DateTime displayDate = displayFormater.parse(date);
    final String formatted = serverFormater.format(displayDate);
    return formatted;
  }

  bidCard(category, title, price, bid_price, bid_date, return_date) {
    return Center(
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.album, color: Theme.of(context).buttonColor,size: 30,),
              title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 23),),
              subtitle: Text('From category: ${category}', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text(
                  'List Price ',
                  style: TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.w400
                  ),
                ),
                Text(
                  '${price} /',
                  style: TextStyle(
                      color: Theme.of(context).buttonColor,
                      fontWeight: FontWeight.bold, fontSize: 18),
                ),
                TextButton(
                  child: Text('For Ksh ${bid_price}',style: TextStyle(
                      color: Theme.of(context).backgroundColor,
                      fontWeight: FontWeight.bold, fontSize: 16)),
                  onPressed: () {
                    /* ... */
                  },
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  child: Text( convertDateTimeDisplay(return_date), style: TextStyle(fontWeight: FontWeight.bold),),
                  onPressed: () {
                    /* ... */
                  },
                ),
                const SizedBox(width: 8),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).backgroundColor,
          title: Text('Rented Items'),
          elevation: 0,
        ),
        body:  FutureBuilder<QuerySnapshot>(
              future: rents.get(),
              builder: (BuildContext context,AsyncSnapshot<QuerySnapshot> snapshot){
                if (snapshot.hasError) {
                  return Text("Something went wrong");
                }

                if (snapshot.connectionState == ConnectionState.done) {
                  return Container(
                    child: new ListView(
                      shrinkWrap: true,
                      children: snapshot.data.docs.map<Widget>((DocumentSnapshot document){
                        Map<String, dynamic> d = document.data() as Map<String, dynamic>;
                        return Container(
                          child: bidCard(d['title'],d['title'],d['posted_price'],d['price'],d['date'], d['return_date'])
                      );
                      }).toList(),
                    ),
                  );
                }

                return Center(
                  child: Container(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
            ) ,
      // Center(
      //     child: Container(
      //       child: Text('Fetching User Data..',style: TextStyle(color:Colors.white, fontWeight: FontWeight.bold, fontSize: 21),),
      //     ),
      //   ),

        );
  }
}
