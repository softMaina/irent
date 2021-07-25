import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:irent/screens/MyRents.dart';
import 'package:irent/widgets/CircularProgress.dart';
import 'package:transparent_image/transparent_image.dart';

import 'CatalogueScreen.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CollectionReference posts = FirebaseFirestore.instance.collection("products");

  final Stream<QuerySnapshot> _productsStream =
      FirebaseFirestore.instance.collection('products').limit(4).snapshots();

  @override
  void initState() {
    super.initState();
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

  viewMyRentals() async {
    await Future.delayed(Duration(milliseconds: 80));
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return MyRents();
        },
        fullscreenDialog: true,
      ),
    );
  }

  gestureGridCells(id, title, category, image, location, price) {
    return Container(
        child: GestureDetector(
      onTap: () => {_onItemTap(id, category)},
      child: Card(
        elevation: 2,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 300,
                height: 300,
                padding: const EdgeInsets.all(8.0),
                alignment: Alignment.center,
                child: Stack(
                  children: <Widget>[
                    Center(
                      child: FadeInImage.memoryNetwork(
                        placeholder: kTransparentImage,
                        image: image,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                          padding: EdgeInsets.all(3.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(title.toUpperCase(),
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold)),
                              Text(
                                '£ ${price}',
                                style: TextStyle(color: Colors.blueAccent, fontSize: 16, fontWeight: FontWeight.bold),
                              )
                            ],
                          )),
                      Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: Text(
                          'In  ${location}',
                          style: TextStyle(color: Colors.blueAccent, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      )
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
        margin: EdgeInsets.only(top: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                padding: EdgeInsets.fromLTRB(0, 7.0, 0, 7.0),
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
                width: MediaQuery.of(context).size.width * 0.97,
                child: SingleChildScrollView(
                    child: Column(
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                      Container(
                          padding: EdgeInsets.only(top:15),
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
                                  onTap: () => {
                                    viewMyRentals()
                                  },
                                  child: Container(
                                    width: 40,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: <Widget>[
                                        Align(
                                            child: Icon(
                                              Icons.addchart_outlined,
                                              color: Theme.of(context).buttonColor,
                                              size: 45.0,
                                              semanticLabel: 'Text to announce in accessibility modes',
                                            ),
                                        ),
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
                      Container(
                        child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('products')
                                .limit(4)
                                .snapshots(),
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (snapshot.hasError) {
                                return Text('Not Found');
                              }
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return CircularProgress();
                              }
                              return SizedBox(
                                height: 500,
                                child: new ListView(
                                    shrinkWrap: true,
                                    children: snapshot.data.docs
                                        .map<Widget>((DocumentSnapshot doc) {
                                      Map<String, dynamic> data =
                                          doc.data() as Map<String, dynamic>;
                                      return Container(
                                          child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          categoryTitle(data['category_name']),
                                          StreamBuilder<QuerySnapshot>(
                                              stream: FirebaseFirestore.instance
                                                  .collection('products')
                                                  .doc(doc.id)
                                                  .collection('posts')
                                                  .orderBy("location")
                                                  .limitToLast(4)
                                                  .snapshots(),
                                              builder: (BuildContext context,
                                                  AsyncSnapshot<QuerySnapshot>
                                                      snapshot) {
                                                if (snapshot.hasError) {
                                                  return Text('Not Found');
                                                }
                                                if (snapshot.connectionState ==
                                                    ConnectionState.waiting) {
                                                  return CircularProgress();
                                                }
                                                return SizedBox(
                                                  height: 400,
                                                  width: MediaQuery.of(context).size.width * 0.97,
                                                  child: new ListView(
                                                    scrollDirection: Axis.horizontal,
                                                    shrinkWrap: true,
                                                    children: snapshot.data.docs
                                                        .map<Widget>(
                                                            (DocumentSnapshot
                                                                document) {
                                                      Map<String, dynamic> d =
                                                          document.data() as Map<
                                                              String, dynamic>;
                                                      return Container(
                                                          child: gestureGridCells(
                                                              document.id,
                                                              d["title"],
                                                              doc.id,
                                                              d['image'], d['location'], d['price'])
                                                          );
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
                      ),
                    ])))));
  }
}
