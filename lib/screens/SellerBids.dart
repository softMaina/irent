import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

  bidCard(category, title, price, bid_price, bid_date) {
    return Center(
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.album),
              title: Text(title),
              subtitle: Text('From category: ${category}'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text(
                  'List Price ',
                  style: TextStyle(
                    color: Colors.black54,
                  ),
                ),
                Text(
                  '${price} /',
                  style: TextStyle(
                      color: Theme.of(context).buttonColor,
                      fontWeight: FontWeight.bold),
                ),
                TextButton(
                  child: Text('For Ksh ${bid_price}'),
                  onPressed: () {
                    /* ... */
                  },
                ),
                const SizedBox(width: 8),
                TextButton(
                  child: const Text('AWARD'),
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
          title: Text('Offers For Your Posts'),
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              for (int i = 0; i < this.results.length; i++)
                bidCard(
                    this.results[i]['category'],
                    this.results[i]["title"],
                    this.results[i]["price"],
                    this.results[i]["bid_price"],
                    this.results[i]["bid_date"])
            ],
          ),
        ));
  }
}
