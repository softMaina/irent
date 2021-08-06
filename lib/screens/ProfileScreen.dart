import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:irent/screens/EditProfile.dart';
import 'package:irent/screens/SignupScreen.dart';
import 'package:irent/screens/ViewBidReport.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:path/path.dart' as Path;
import 'package:sqflite/sqflite.dart';

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
  CollectionReference users = FirebaseFirestore.instance.collection("users");
  CollectionReference tokens = FirebaseFirestore.instance.collection("tokens");

  GoogleSignIn _googleSignIn = GoogleSignIn(scopes: <String>['email']);
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  bool completed=false;
  String contact;

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      setState(() {
        _currentUser = account;
      });
    });
    _googleSignIn.signInSilently();
    checkUser();
  }

  _saveDeviceToken() async {
    // Get the current user
    String uid = _currentUser.email;
    // FirebaseUser user = await _auth.currentUser();

    // Get the token for this device
    String fcmToken = await messaging.getToken();

    // Save it to Firestore
    if (fcmToken != null) {
      users
          .doc(uid)
          .update({'token':fcmToken});

      await tokens.add({
        'token': fcmToken,
        'user': _currentUser.email
      }).then((value) => {
      print('saved device token')
      });

    }
  }

  updateProfileData(){
    if(_currentUser != null){
      users.doc(_currentUser.email).set({
        'username': _currentUser.displayName,
        'email': _currentUser.email,
        'picture':'',
        'contact':'',
        'id_no':'',
        'full_names':''
      }).then((value) =>{
        _saveDeviceToken()
      });
    }
  }

  Future<void> _handleSignOut() {
    _googleSignIn.disconnect();
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => SignupScreen()));
  }

  profile() {
    if (_currentUser != null) {
      updateProfileData();
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
                            fontSize: 22),
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              child: Text('Rating ', style: TextStyle(fontSize: 20, color: Colors.white70),),
                            ),
                            RatingBarIndicator(
                              rating: 4.5,
                              itemBuilder: (context, index) => Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              itemCount: 5,
                              itemSize: 25.0,
                              direction: Axis.horizontal,
                            ),
                          ]),
                      this.completed ?
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              child: Text('Tel: ${this.contact}', style: TextStyle(color: Colors.white, fontSize: 20),),
                            ),
                            Row(
                              children: [
                                Center(
                                  child: Icon(Icons.check_circle, size: 20, color: Colors.yellow,),
                                ),
                                Center(
                                  child: Text('Profile Completed', style: TextStyle(color: Colors.white, fontSize: 18),),
                                )
                              ],
                            ),
                          ],
                        ),
                      ) : Container(child: Row(
                        children: [
                          Center(
                            child: Text("Please Complete Profile", style: TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.w500),),
                          )
                        ],
                      )),
                      Container(
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                primary: Colors.cyanAccent,
                                elevation: 1,
                                padding: EdgeInsets.symmetric(horizontal: 80, vertical: 5)
                            ),

                            onPressed: () {
                              Navigator.push(
                                  context, MaterialPageRoute(builder: (context) => EditProfile()));
                            },
                            child: Text(
                              "Edit Profile",
                              style:
                              TextStyle(color: Theme.of(context).backgroundColor, fontSize: 18),
                            )),
                      ),
                      Container(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.deepOrange,
                            elevation: 1,
                            padding: EdgeInsets.symmetric(horizontal: 80, vertical: 10)
                          ),

                            onPressed: () {
                              _handleSignOut();
                            },
                            child: Text(
                              "LOGOUT",
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

  viewPostReport(id) {
    // open a page viewing all the bids, deactivate bid
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => ViewBidReport(id)));
  }

  updateUserData(){
    // a person must update user profile
  }
  
  removeItem(id){
   mybids.doc(id).delete();
  }


  checkUser() async {
    // full_name, id_no, phone_number, township
    int count;
    List<Map> list;
    var databasePath = await getDatabasesPath();
    String path = Path.join(databasePath, 'user.db');

    Database database = await openDatabase(path, version: 1);

    await database.transaction((txn) async {
      list = await txn.rawQuery('SELECT * FROM user');
    });
    if(list.length > 0){
      this.setState(() {
        this.completed = true;
        this.contact = list[0]['contact'];
      });
    }
  }

  uploads() {
    return Container(
      margin: EdgeInsets.fromLTRB(10, 5, 0, 5),
      child: Row(
        children: [
         _currentUser != null ? Expanded(
              child: StreamBuilder<QuerySnapshot>(
                  stream: myuploads
                      .where('posted_by',
                          isEqualTo: _currentUser.email.toString())
                      // .orderBy('price', descending: true)
                      // .limit(3)
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
                                leading: Icon(
                                  Icons.money,
                                  color: Colors.lightBlueAccent,
                                ),
                                title: Text(
                                  data['title'],
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle:
                                    Text(data['post_category'].toString()),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Text(
                                    '@',
                                    style: TextStyle(
                                        color:
                                            Theme.of(context).backgroundColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 25),
                                  ),
                                  Text(
                                    data['price'].toString(),
                                    style: TextStyle(
                                        color:
                                            Theme.of(context).backgroundColor,
                                        fontWeight: FontWeight.w300,
                                        fontSize: 18),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    child: const Text(
                                      'View Report',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w300,
                                          fontSize: 18),
                                    ),
                                    onPressed: () {
                                      /* ... */
                                      viewPostReport(doc.id);
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
                  })) : Container(
           child: Center(
             child: Text('Loading Current User'),
           ),
         )
        ],
      ),
    );
  }

  purchases() {
    return Container(
      margin: EdgeInsets.fromLTRB(10, 5, 0, 5),
      child: Row(
        children: [
       _currentUser != null ?   Expanded(
              child: StreamBuilder<QuerySnapshot>(
                  stream: mybids
                      .where('bid_by', isEqualTo: _currentUser.email.toString())
                      .orderBy("date")
                      .limitToLast(4)
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

                        return FutureBuilder<QuerySnapshot>(
                            future: myuploads
                            .where("post_id", isEqualTo: data["post_id"])
                            .get(),
                        builder:
                        (BuildContext context, AsyncSnapshot<QuerySnapshot> shot) {

                        if (shot.hasError) {
                        return Text("Something went wrong");
                        }

                        if (shot.connectionState == ConnectionState.done) {
                          return ListView.builder(
                            shrinkWrap: true,
                            itemCount: shot.data.size,
                            itemBuilder: (context, index) {
                              return Column(
                                children: <Widget>[
                                  Card(
                                    color: Colors.lightGreen,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        ListTile(
                                          leading: Icon(
                                            Icons.money,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                          title: Text(
                                            shot.data.docs[index].get('title'),
                                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 25),
                                          ),
                                          subtitle:
                                          Text(shot.data.docs[index].get('post_category')),
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: <Widget>[
                                            Text(
                                              '@  Ksh',
                                              style: TextStyle(
                                                  color:
                                                  Theme.of(context).backgroundColor,
                                                  fontWeight: FontWeight.w300,
                                                  fontSize: 20),
                                            ),
                                            Text(
                                              data['price'].toString(),
                                              style: TextStyle(
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18),
                                            ),
                                            const SizedBox(width: 8),
                                            ElevatedButton(
                                              style: ButtonStyle(
                                                backgroundColor: MaterialStateProperty.all(Colors.deepOrangeAccent)
                                              ),
                                              child: const Text(
                                                'Remove Bid',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w300,
                                                    fontSize: 18),
                                              ),
                                              onPressed: () {
                                                removeItem(doc.id);
                                              },
                                            ),
                                            const SizedBox(width: 8),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
                                  // Widget to display the list of project
                                ],
                              );
                            },
                          );
                        }

                        return Center(
                          child: Container(
                            child: CircularProgressIndicator(),
                          ),
                        );
                        }
                        );
                      }).toList(),
                    );

                  })) : Center(
         child: Container(
           child: Text('Fetching User Purchases'),
         ),
       )
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
                    Divider(color: Colors.white)
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
      body: SingleChildScrollView(
        child: Center(
            child: Column(
          children: [
            profile(),
            categoryTitle("Items You've Posted"),
            uploads(),
            categoryTitle("Items You've Bid On"),
            purchases()
          ],
        )),
      ),
    );
  }
}
