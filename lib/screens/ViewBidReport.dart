import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:transparent_image/transparent_image.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;
FirebaseAuth auth = FirebaseAuth.instance;

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

  CollectionReference rented = FirebaseFirestore.instance.collection("rented");

  _ViewBidReportState(String id) {
    this.id = id;
  }

  @override
  void initState() {
    super.initState();
    print(this.id);
  }

  rewardBid(id, price, user) async {
    if (this.date == null) {
      final snackBar = SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text('No Bid Price Specified'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }
    await rented.add({
      'price': price,
      'rented_to': user,
      'date': new DateTime.now(),
      'return_date': this.date,
      'rented_by': '',
      'post_id': '',
      'category_id': '',
      'title': '',
      'posted_price': ''
    }).then((docRef) async {
      // duplicate data to bids collection for easier search
      final snackBar = SnackBar(
        backgroundColor: Colors.greenAccent,
        content: Text('Item Rented Successfully'),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }).catchError((error) {
      final snackBar = SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text('Action Failed'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });
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
      body: Column(
        children: [
          Expanded(
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
                        Center(child: CircularProgressIndicator()),
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
                    SizedBox(
                      height: 300,
                      child: FutureBuilder(
                          future: FirebaseFirestore.instance
                              .collection("bids")
                              .where("post_id", isEqualTo: id)
                              .get(),
                          builder: (BuildContext context,
                              AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.hasError) {
                              return Text("Something went wrong");
                            }

                            if (snapshot.hasData) {
                              final PageController controller =
                                  PageController(initialPage: 0);
                              return PageView(
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
                                                rewardBid(doc.id, doc["price"],
                                                    doc["bid_by"]);
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
                                  }).toList());
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
    );
  }
}
