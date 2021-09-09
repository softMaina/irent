import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:path/path.dart' as Path;
import 'package:sqflite/sqflite.dart';

class CatalogueScreen extends StatefulWidget {
  String id;
  String category;

  CatalogueScreen(this.id, this.category);

  @override
  State<StatefulWidget> createState() =>
      _CatalogueScreenState(this.id, this.category);
}

class _CatalogueScreenState extends State<CatalogueScreen> {
  GoogleSignInAccount _currentUser;

  GoogleSignIn _googleSignIn = GoogleSignIn(scopes: <String>['email']);

  Future item;
  String id;
  String category;
  int bid_price;

  _CatalogueScreenState(this.id, this.category);

  CollectionReference posts = FirebaseFirestore.instance.collection("products");
  CollectionReference bids = FirebaseFirestore.instance.collection("bids");

  checkUser() async {
    // full_name, id_no, phone_number, township
    int count;
    var databasePath = await getDatabasesPath();
    String path = Path.join(databasePath, 'user.db');

    Database database = await openDatabase(path, version: 1);

    await database.transaction((txn) async {
      // List<Map> list = await txn.rawQuery('SELECT * FROM users');
     count = Sqflite
          .firstIntValue(await database.rawQuery('SELECT COUNT(*) FROM user'));
    });

    if(count > 0 ){
      return true;
    }else{
      return false;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      setState(() {
        _currentUser = account;
      });
    });
    _googleSignIn.signInSilently();
    item = posts.doc(category).collection('posts').doc(id).get();
  }

  checkIfAlreadyBid() {}

  checkIfItemIsAvailable() {}


  bidItem() async {
    // bool userExists = checkUser();
    if (this.bid_price == null) {
      final snackBar = SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text('Please Complete Profile And Enter Bid Price'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }
    await posts
        .doc(category)
        .collection("posts")
        .doc(id)
        .collection("bids")
        .add({
      'price': this.bid_price,
      'bid_by': _currentUser.email,
      'date': new DateTime.now(),
    }).then((docRef) async {
      // duplicate data to bids collection for easier search
      await bids.add({
        'post_category_id': category,
        'post_id': id,
        'price': this.bid_price,
        'date': new DateTime.now(),
        'bid_by': _currentUser.email,
        'returned': false
      });
      final snackBar = SnackBar(
        backgroundColor: Colors.greenAccent,
        content: Text('Bid Placed Successfully'),
      );
      this.bid_price = 0;
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      Navigator.pop(context);
    }).catchError((error) {
      final snackBar = SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text('Bid Failed'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });
  }

  recordUserBids() {}

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).backgroundColor,
          title: Text('Place Your Bid'),
          elevation: 0,
        ),
        body: FutureBuilder<DocumentSnapshot>(
          future: this.item,
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text("Something went horribly wrong");
            }
            if (snapshot.hasData && !snapshot.data.exists) {
              return Text("Document does not exist");
            }

            if (snapshot.connectionState == ConnectionState.done) {
              Map<String, dynamic> data =
                  snapshot.data.data() as Map<String, dynamic>;
              return SingleChildScrollView(
                child: Center(
                  child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: Theme.of(context).backgroundColor)

                      ),
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: MediaQuery.of(context).size.width * 1.7,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height * 0.35,
                            margin: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.blueAccent)),
                            child: Stack(
                              children: <Widget>[
                                Center(
                                  child: FadeInImage.memoryNetwork(
                                    placeholder: kTransparentImage,
                                    image: data['image'],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.all(9),
                            child: Row(
                              children: [
                                Text(''),
                                Text(
                                  data['title'].toUpperCase(),
                                  style: TextStyle(
                                      fontSize: 26,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600),
                                )
                              ],
                            ),
                          ),
                          Container(
                              margin: EdgeInsets.all(8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    color: Theme.of(context).buttonColor,
                                    size: 22,
                                  ),
                                  Text(
                                    data['location'],
                                    style: TextStyle(
                                        fontSize: 24, color: Colors.white),
                                  ),
                                ],
                              )),
                          Container(
                            margin: EdgeInsets.all(8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Ksh ',
                                  style: TextStyle(
                                      color: Theme.of(context).buttonColor,
                                      fontSize: 20),
                                ),
                                Text(
                                  data['price'].toString(),
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 27),
                                ),
                              ],
                            ),
                          ),
                          Container(
                              margin: EdgeInsets.all(8),
                              child: Center(
                                  child: SizedBox(
                                width: 1000,
                                height: 56,
                                child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    border: new OutlineInputBorder(
                                      borderRadius: const BorderRadius.all(
                                        const Radius.circular(5.0),
                                      ),
                                      borderSide: BorderSide(
                                        width: 0,
                                        style: BorderStyle.none,
                                      ),
                                    ),
                                    fillColor: Colors.white,
                                    filled: true,
                                    labelText: "Your Bid Price",
                                    labelStyle: TextStyle(fontSize: 20),
                                    isDense: true,
                                    contentPadding: EdgeInsets.all(20.0),
                                  ),
                                  onChanged: (text) {
                                    setState(() {
                                      bid_price = int.parse(text);
                                    });
                                  },
                                ),
                              ))),
                          Container(
                              height: 50,
                              margin: EdgeInsets.only(top: 15),
                              child: RaisedButton(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5)),
                                  color: Theme.of(context).buttonColor,
                                  onPressed: () {
                                    bidItem();
                                  },
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Bid Starting: ${data["price"]} ksh",
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.white,
                                          )),
                                      Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        color: Colors.white,
                                      )
                                    ],
                                  ))),
                        ],
                      )),
                ),
              );
            }

            return Center(
              child: Container(
                child: CircularProgressIndicator(value: 10,),
              ),
            );
          },
        ));
  }
}
