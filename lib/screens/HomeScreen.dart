import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'BasketScreen.dart';
import 'CatalogueScreen.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CollectionReference posts = FirebaseFirestore.instance.collection("products");

  final Stream<QuerySnapshot> _productsStream =
      FirebaseFirestore.instance.collection('products').snapshots();

  @override
  void initState() {
    super.initState();
  }

  getPosts() async {
    await posts.get().then((QuerySnapshot qSnapshot) {
      qSnapshot.docs.forEach((doc) {
        print(doc.id);
        getItems(doc.id);
      });
    }).catchError((error) => {print(error)});
  }

  getItems(id) async {
    await posts
        .doc(id)
        .collection("posts")
        .get()
        .then((QuerySnapshot qSnapshot) {
      qSnapshot.docs.forEach((doc) {
        print(doc['title']);
      });
    });
  }

  _onItemTap(String id, String category) async {
    await Future.delayed(Duration(milliseconds: 80));
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return new CatalogueScreen(id, category);
        },
        fullscreenDialog: true,
      ),
    );
  }

  searchBar() {
    return Container(
        padding: EdgeInsets.fromLTRB(0.0, 9.0, 0.0, 9.0),
        margin: EdgeInsets.only(bottom: 15),
        child: Center(
          child: TextFormField(
            decoration: InputDecoration(
                border: new OutlineInputBorder(
                  borderRadius: const BorderRadius.all(
                    const Radius.circular(10.0),
                  ),
                  borderSide: BorderSide(
                    width: 0,
                    style: BorderStyle.none,
                  ),
                ),
                fillColor: Colors.white,
                filled: true,
                labelText: 'Search For Items'),
          ),
        ));
  }

  gestureGridCells(id,title,category) {
    return Container(
        child: GestureDetector(
            onTap: () => {_onItemTap(id,category)},
              child: Card(
                elevation: 1,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 45,
                        width: 45,
                        padding: EdgeInsets.all(3),
                        child: Center(child: Icon(Icons.favorite_border_sharp)),
                      ),
                      Padding(
                          padding: EdgeInsets.all(1.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                  padding: EdgeInsets.all(3.0),
                                  child: Text(title,
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 14.0))),
                            ],
                          ))
                    ],
                  ),
                ),
              ),
            ));
  }

  categoryTitle(title) {
    return Container(
      margin: EdgeInsets.only(top:20),
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            padding: EdgeInsets.fromLTRB(0, 10.0, 0, 7.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title.toUpperCase(),
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 22.0)),
                Text(
                  'TOP ITEMS',
                  style: TextStyle(
                      color: Colors.white60,
                      fontWeight: FontWeight.w400,
                      fontSize: 18.0),
                )
              ],
            )),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        body: Center(
            child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                child: SingleChildScrollView(
                    child: Column(
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                      Container(
                          padding: EdgeInsets.only(top: 30),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Hello',
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 20.0)),
                                    Text('Welcome to iRent',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.bold))
                                  ]),
                              Padding(
                                padding: EdgeInsets.all(5.0),
                                child: InkWell(
                                  onTap: () => {},
                                  child: Container(
                                    width: 40,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: <Widget>[
                                        Align(
                                            child: Icon(
                                          Icons.shopping_basket,
                                          size: 35,
                                          color: Theme.of(context).buttonColor,
                                        )),
                                        Align(
                                          alignment: Alignment.topRight,
                                          child: Container(
                                              padding: EdgeInsets.all(3),
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  shape: BoxShape.circle),
                                              child: Text('')),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )),
                      searchBar(),
                      StreamBuilder<QuerySnapshot>(
                          stream: _productsStream,
                          builder: (BuildContext context,
                              AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.hasError) {
                              return Text('Not Found');
                            }
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Text("Loading");
                            }

                            return Container(
                              child: new ListView(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                children: snapshot.data.docs
                                    .map<Widget>((DocumentSnapshot doc) {
                                  Map<String, dynamic> data =
                                      doc.data() as Map<String, dynamic>;
                                  return Container(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      categoryTitle(data['category_name']),
                                      StreamBuilder<QuerySnapshot>(
                                          stream: FirebaseFirestore.instance
                                              .collection('products')
                                              .doc(doc.id)
                                              .collection('posts')
                                              .snapshots(),
                                          builder: (BuildContext context,
                                              AsyncSnapshot<QuerySnapshot>
                                                  snapshot) {
                                            if (snapshot.hasError) {
                                              return Text('Not Found');
                                            }
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return Text("Loading");
                                            }
                                            return Container(
                                              child: new ListView(
                                                physics: NeverScrollableScrollPhysics(),
                                                shrinkWrap: true,
                                                children: snapshot.data.docs.map<
                                                        Widget>(
                                                    (DocumentSnapshot document) {
                                                  Map<String, dynamic> d =
                                                      document.data()
                                                          as Map<String, dynamic>;
                                                  return  Container(
                                                      child:gestureGridCells(document.id,
                                                          d["title"], doc.id));
                                                }).toList(),
                                              ),
                                            );
                                          })
                                    ],
                                  ));
                                }).toList(),
                              ),
                            );
                          }),
                    ])))));
  }
}
