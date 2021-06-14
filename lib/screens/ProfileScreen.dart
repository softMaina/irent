import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:irent/screens/SignupScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'RootPage.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;
FirebaseAuth auth = FirebaseAuth.instance;

class ProfileScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  GoogleSignInAccount _currentUser;
  CollectionReference myuploads =
      FirebaseFirestore.instance.collection("uploads");

  CollectionReference mybids = FirebaseFirestore.instance.collection("bids");

  GoogleSignIn _googleSignIn = GoogleSignIn(scopes: <String>['email']);

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      setState(() {
        _currentUser = account;
      });
      print(_currentUser);
    });
    _googleSignIn.signInSilently();
    getMyUploads();
  }

  Future<void> _handleSignOut() {
    _googleSignIn.disconnect();
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => SignupScreen()));
  }

  getMyBids() async {
    // check collection for bids /bids/bid_id/docs/ {item_title, bid_price, price, date, item_id, item_pic}
    await mybids
        .where('bid_by', isEqualTo: _currentUser)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        print(doc.id);
      });
    });
  }

  getMyUploads() async {
    // check collection for my uploads /uploads/user_email/{doc_id, doc_price}
    await myuploads
        .where('posted_by', isEqualTo: _currentUser)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        print(doc.id);
      });
    });
  }

  profile() {
    if (_currentUser != null) {
      return Container(
          margin: EdgeInsets.fromLTRB(10, 15, 0, 10),
          child: Row(children: [
            Container(
              height: 100,
              width: 100,
              child: GoogleUserCircleAvatar(
                identity: _currentUser,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(0),
              child: Container(
                  margin: EdgeInsets.fromLTRB(15.0, 0, 0, 10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentUser.email,
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 27),
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Chip(
                              label: Text('available'),
                              backgroundColor: Colors.greenAccent,
                              labelStyle: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            )
                          ]),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.6,
                        child: FlatButton(
                            color: Colors.redAccent,
                            onPressed: () {
                              _handleSignOut();
                            },
                            child: Text(
                              "Logout",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 26),
                            )),
                      )
                    ],
                  )),
            )
          ]));
    } else {
      return Text('no user account found');
    }
  }

  uploads() {
    return Container(
      margin: EdgeInsets.fromLTRB(10, 5, 0, 5),
      child: Row(
        children: [
          Expanded(
              child: StreamBuilder<QuerySnapshot>(
                  stream: myuploads
                      .where('posted_by', isEqualTo: _currentUser.email.toString())
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return Text('Not Found');
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text("Loading");
                    }

                    return new ListView(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: snapshot.data.docs
                          .map<Widget>((DocumentSnapshot doc) {
                        Map<String, dynamic> data =
                            doc.data() as Map<String, dynamic>;
                        return new Card(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              ListTile(
                                leading: Icon(Icons.money, color: Colors.lightBlueAccent,),
                                title: Text(data['title'], style: TextStyle(fontWeight: FontWeight.bold),),
                                subtitle: Text(data['post_category'].toString()),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Text('@',style: TextStyle(color: Theme.of(context).backgroundColor,fontWeight: FontWeight.bold, fontSize: 25),),
                                  Text(data['price'].toString(),style: TextStyle(color: Theme.of(context).backgroundColor,fontWeight: FontWeight.w300, fontSize: 18),),

                                  const SizedBox(width: 8),
                                  TextButton(
                                    child: const Text('DEACTIVATE POST', style: TextStyle(color: Colors.redAccent),),
                                    onPressed: () {
                                      /* ... */
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  }))
        ],
      ),
    );
  }

  purchases() {
    return Container(
      margin: EdgeInsets.fromLTRB(10, 5, 0, 5),
      child: Row(
        children: [
          Expanded(
              child: StreamBuilder<QuerySnapshot>(
                  stream: mybids
                      .where('bid_by', isEqualTo:
                  _currentUser.email.toString())
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return Text('Not Found');
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text("Loading");
                    }

                    return new ListView(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: snapshot.data.docs
                          .map<Widget>((DocumentSnapshot doc) {
                        Map<String, dynamic> data =
                        doc.data() as Map<String, dynamic>;
                        return new Card(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              ListTile(
                                leading: Icon(Icons.thumb_up_alt, color: Colors.orange,),
                                title: Text(data['post_id']),
                                subtitle: Text('For ${data['price'].toString()}'),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  const SizedBox(width: 8),
                                  TextButton(
                                    child: const Text('CANCEL',style: TextStyle(color: Colors.redAccent)),
                                    onPressed: () {
                                      /* ... */
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  }))
        ],
      ),
    );
  }

  categoryTitle(title) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                padding: EdgeInsets.fromLTRB(0, 10.0, 0, 7.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 18.0)),
                    Divider(
                        color: Colors.white
                    )
                  ],
                )),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Text('My Profile'),
        elevation: 0,
        backgroundColor: Theme.of(context).backgroundColor,
      ),
      body:SingleChildScrollView(
        child: Center(
            child: Column(
          children: [
            profile(),
            categoryTitle("Items You've Posted"),
            uploads(),
            categoryTitle("Items You've Bid On"),
            purchases()],
        )),
      ),
    );
  }
}

