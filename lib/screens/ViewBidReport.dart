import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:intl/intl.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'dart:math';

FirebaseFirestore firestore = FirebaseFirestore.instance;
FirebaseAuth auth = FirebaseAuth.instance;
CollectionReference posts = FirebaseFirestore.instance.collection("products");

class ViewBidReport extends StatefulWidget {
  String id;

  ViewBidReport(String id) {
    this.id = id;
  }

  @override
  State<StatefulWidget> createState() => _ViewBidReportState(id);
}

class _ViewBidReportState extends State<ViewBidReport> {
  String id;
  String date;
  String title;
  String location;
  String post_category;
  String posted_by;
  String image;
  int initial_price;
  String category_id;
  Random random = new Random();

  CollectionReference rented = FirebaseFirestore.instance.collection("rented");
  CollectionReference uploads = FirebaseFirestore.instance.collection('uploads');

  _ViewBidReportState(String id) {
    this.id = id;
  }

  @override
  void initState() {
    super.initState();
  }

  getPostDetails(post_id){
    uploads.where('post_id', isEqualTo: post_id).limit(1).get().then((snapshot) => {
      snapshot.docs.forEach((element) {
        this.setState(() {
          this.title = element.get('title');
          this.location = element.get('location');
          this.posted_by = element.get('posted_by');
          this.initial_price = element.get('price');
          this.image = element.get('image');
          this.post_category = element.get('post_category');
          this.category_id = element.get('post_category_id');
        });
      })

    });
  }

  markAsUnAvailable(category_id, id){
    posts.doc(category_id).collection('posts').doc(id).update({
      'available':false
    });
  }

  rewardBid(id, post_category_id, price, user, post_id) async {
    if (this.date == null) {
      final snackBar = SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text('No Bid Price Specified'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }
    await getPostDetails(post_id);
    if(this.title != null) {
      await rented.add({
        'price': price,
        'rented_to': user,
        'date': new DateTime.now(),
        'return_date': this.date,
        'rented_from': this.posted_by,
        'post_id': post_id,
        'category': this.post_category,
        'title': this.title,
        'posted_price': this.initial_price,
        'category_id':this.category_id,
        'returned':false,
      }).then((docRef) async {
        // duplicate data to bids collection for easier search
        final snackBar = SnackBar(
          backgroundColor: Colors.greenAccent,
          content: Text('Item Rented Successfully'),
        );
        markAsUnAvailable(category_id, post_id);
        ScaffoldMessenger.of(context).showSnackBar(snackBar);

      }).catchError((error) {
        final snackBar = SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text('Action Failed'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).backgroundColor,
        title: Text("Post Report"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
                child: FutureBuilder<DocumentSnapshot>(
              future:
                  FirebaseFirestore.instance.collection("uploads").doc(id).get(),
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text("Something went wrong");
                }

                if (snapshot.hasData && !snapshot.data.exists) {
                  return Text("Document does not exist");
                }

                if (snapshot.connectionState == ConnectionState.done) {
                  Map<String, dynamic> data =
                      snapshot.data.data() as Map<String, dynamic>;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: <Widget>[
                          Center(
                            child: FadeInImage.memoryNetwork(
                              placeholder: kTransparentImage,
                              image: data['image'],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.all(10),
                        child: Text(
                          data["title"],
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.all(10),
                        child: Text(
                          "ksh ${data["price"].toString()}",
                          style: TextStyle(
                              color: Colors.white70,
                              fontSize: 20,
                              fontWeight: FontWeight.w400),
                        ),
                      ),

                      // Watch For Bids For This Posts
                      Container(
                        child: FutureBuilder(
                            future: FirebaseFirestore.instance
                                .collection("bids")
                                .where("post_id", isEqualTo: data['post_id'])
                                .get(),
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (snapshot.hasError) {
                                return Text("Something went wrong");
                              }

                              if (snapshot.hasData) {
                                final PageController controller =
                                    PageController(initialPage: 0);
                                return Container(
                                  height: 400,
                                  child: PageView(
                                      scrollDirection: Axis.horizontal,
                                      controller: controller,
                                      children:
                                          snapshot.data.docs.map<Widget>((doc) {

                                        return Container(
                                          margin: EdgeInsets.all(10),
                                          padding: EdgeInsets.all(7),
                                          width: MediaQuery.of(context).size.width *
                                              0.8,
                                          height: 100,
                                          color: Colors.blueAccent,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                "Bid By: ${doc["bid_by"]}",
                                                style: TextStyle(
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.w500),
                                              ),
                                              Text(
                                                "@ ${doc["price"].toString()}",
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold),
                                              ),
                                              Container(
                                                child: Row(
                                                  children: [
                                                    Text("User Ratings", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),),
                                                    RatingBarIndicator(
                                                      rating: random.nextDouble() * 4.8,
                                                      itemBuilder: (context, index) => Icon(
                                                        Icons.star,
                                                        color: Colors.amber,
                                                      ),
                                                      itemCount: 5,
                                                      itemSize: 25.0,
                                                      direction: Axis.horizontal,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Text(
                                                doc["date"].toDate().toString(),
                                                style: TextStyle(
                                                    color: Colors.white70),
                                              ),
                                              Container(
                                                  margin: EdgeInsets.only(top: 6),
                                                  width: double.infinity,
                                                  height: 45,
                                                  child: ElevatedButton(
                                                      onPressed: () {
                                                        DatePicker.showDatePicker(
                                                            context,
                                                            showTitleActions: true,
                                                            minTime: DateTime(
                                                                2021, 3, 5),
                                                            maxTime: DateTime(
                                                                2023, 6, 7),
                                                            onChanged: (date) {
                                                          print('change $date');
                                                        }, onConfirm: (date) {
                                                          setState(() {
                                                            this.date =
                                                                date.toString();
                                                          });
                                                        },
                                                            currentTime:
                                                                DateTime.now(),
                                                            locale: LocaleType.en);
                                                      },
                                                      style: ButtonStyle(
                                                        backgroundColor:
                                                            MaterialStateProperty
                                                                .all<Color>(Theme
                                                                        .of(context)
                                                                    .buttonColor),
                                                      ),
                                                      child: Text(
                                                        date == null
                                                            ? 'Set Return By Date'
                                                            : date,
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 21),
                                                      ))),
                                              Container(
                                                margin: EdgeInsets.only(top: 10),
                                                width: double.infinity,
                                                height: 45,
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    rewardBid(doc.id, doc['post_category_id'],doc["price"],
                                                        doc["bid_by"],data['post_id']);
                                                  },
                                                  child: Text(
                                                    "Award Item To Bidder",
                                                    style: TextStyle(fontSize: 20),
                                                  ),
                                                  style: ButtonStyle(
                                                    backgroundColor:
                                                        MaterialStateProperty.all<
                                                            Color>(Colors.black),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        );
                                      }).toList()),
                                );
                              }
                              return Text('Loading');
                            }),
                      )
                    ],
                  );
                }

                return Text("loading");
              },
            ))
          ],
        ),
      ),
    );
  }
}
