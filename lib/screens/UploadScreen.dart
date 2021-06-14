import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../sizeConfig.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;
FirebaseAuth auth = FirebaseAuth.instance;

class UploadScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  GoogleSignInAccount _currentUser;

  GoogleSignIn _googleSignIn = GoogleSignIn(scopes: <String>['email']);

  String category = 'gardening';
  CollectionReference posts = FirebaseFirestore.instance.collection("products");
  CollectionReference uploads =
      FirebaseFirestore.instance.collection("uploads");
  var categories = new Map<String, String>();
  String item_name;
  int base_price;
  String location;
  String description;

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
    getCategories();
  }

  getCategories() async {
    await posts.get().then((QuerySnapshot qSnapshot) {
      qSnapshot.docs.forEach((doc) {
        print(doc.id);
        setState(() {
          this.categories[doc.id] = doc.get("category_name");
        });
      });
      print(this.categories.values.toList());
    });
  }

  // save data to firestore
  savePost() {
    String cat;
    cat = this.categories.keys.firstWhere(
        (k) => this.categories[k] == this.category,
        orElse: () => null);
    posts.doc(cat).collection("posts").add({
      'available': true,
      'title': item_name,
      'description': description,
      'location': location,
      'price': base_price,
      'posted_by': _currentUser.email
    }).then((docRef) {
      uploads.add({
        'post_category_id':cat,
        'post_category': category,
        'post_id': docRef.id,
        'title': item_name,
        'description': description,
        'location': location,
        'price': base_price,
        'posted_by': _currentUser.email
      });
      final snackBar = SnackBar(
        backgroundColor: Colors.greenAccent,
        content: Text('Posted!!'),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }).catchError((error){
      final snackBar = SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text('Failed To Post'),
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
        backgroundColor: Theme.of(context).backgroundColor,
        title: Text('Rent Out An Item'),
        elevation: 0,
      ),
      body:  SingleChildScrollView(
        child: Center(
          child: Container(
            margin: EdgeInsets.fromLTRB(0, 20, 0, 20),
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.9,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(bottom: 10),
                    child: Text('Select Category', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 20),)
                  ),
                  Container(
                      margin: EdgeInsets.only(bottom: 10),
                      width: MediaQuery.of(context).size.width * 0.8,
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(3)),
                      child: DropdownButton<String>(
                          dropdownColor: Colors.white,
                          value: category,
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.lightBlue,
                          ),
                          iconSize: 36,
                          elevation: 0,
                          style: TextStyle(color: Theme.of(context).backgroundColor, fontSize: 24),
                          underline: Container(
                              height: 2, color: Theme.of(context).buttonColor),
                          onChanged: (String newValue) {
                            setState(() {
                              category = newValue;
                            });
                          },
                          items: this
                              .categories
                              .values
                              .toList()
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                                value: value, child: Text(value));
                          }).toList())),
                  Container(
                    child: Column(
                      children: [
                        Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.blueAccent)
                            ),
                            height: 200,
                            margin: EdgeInsets.all(10),
                            child: Center(
                                child: Container(
                                  height: 100,
                                  width: 100,

                                  child: Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 50,
                                  ),
                                ))),
                        Container(
                            margin: EdgeInsets.only(bottom: 10),
                            child: Center(
                                child: SizedBox(
                                  width: 1000,
                                  height: 56,
                                  child: TextFormField(
                                    keyboardType: TextInputType.name,
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
                                      labelText: "Item Name",
                                      labelStyle: TextStyle(fontSize: 20),
                                      isDense: true,
                                      contentPadding: EdgeInsets.all(20.0),
                                    ),
                                    onChanged: (text) {
                                      setState(() {
                                        item_name = text;
                                      });
                                    },
                                  ),

                                ))),
                        Container(
                            margin: EdgeInsets.only(bottom: 10),
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
                                      labelText: "Base Price",
                                      labelStyle: TextStyle(fontSize: 20),
                                      isDense: true,
                                      contentPadding: EdgeInsets.all(20.0),

                                    ),
                                    onChanged: (text) {
                                      setState(() {
                                        base_price = int.parse(text);
                                      });
                                    },
                                  ),
                                ))),
                        Container(
                            margin: EdgeInsets.only(bottom: 10),
                            child: Center(
                                child: SizedBox(
                                  width: 1000,
                                  height: 56,
                                  child: TextFormField(
                                    keyboardType: TextInputType.name,
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
                                      labelText: "Location Of Item",
                                      labelStyle: TextStyle(fontSize: 20),
                                      isDense: true,
                                      contentPadding: EdgeInsets.all(20.0),
                                    ),
                                    onChanged: (text) {
                                      setState(() {
                                        location = text;
                                      });
                                    },
                                  ),
                                ))),

                        Container(
                            margin: EdgeInsets.only(bottom: 10),
                            child: Center(
                                child: SizedBox(
                                  width: 1000,
                                  height: 56,
                                  child: TextFormField(
                                    keyboardType: TextInputType.name,
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
                                      labelText: "Description",
                                      labelStyle: TextStyle(fontSize: 20),
                                      isDense: true,
                                      contentPadding: EdgeInsets.all(20.0),
                                    ),
                                    onChanged: (text) {
                                      setState(() {
                                        description = text;
                                      });
                                    },
                                  ),
                                ))),
                      ]
                    )
                  ),


                  SizedBox(
                      width: double.infinity,
                      height: 57,
                      child: RaisedButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5)),
                          color: Theme.of(context).buttonColor,
                          onPressed: () {
                            savePost();
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Post",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                  )),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: Colors.white,
                              )
                            ],
                          )))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
