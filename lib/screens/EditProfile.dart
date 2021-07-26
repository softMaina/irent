import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:google_sign_in/google_sign_in.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;
FirebaseAuth auth = FirebaseAuth.instance;

class EditProfile extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _EditProfile();

}

class _EditProfile extends State<EditProfile>{
  GoogleSignInAccount _currentUser;
  GoogleSignIn _googleSignIn = GoogleSignIn(scopes: <String>['email']);

  String category = 'Men';
  CollectionReference users = FirebaseFirestore.instance.collection("users");


  String phone_number;
  String id_no;
  String full_name;
  String location;

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      setState(() {
        _currentUser = account;
      });
    });
    _googleSignIn.signInSilently();
  }


  updateProfile() async{
    if (_currentUser != null) {
    await  users.doc(_currentUser.email).update({
        'full_name': full_name,
        'id_no': id_no,
        'location': location,
        'phone_number': phone_number
      }).then((value){

      final snackBar = SnackBar(
        backgroundColor: Colors.greenAccent,
        content: Text('Updated!!'),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      });
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).backgroundColor,
        elevation: 0,
        title: Text('Edit Profile'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Container(
              width: MediaQuery.of(context).size.width * 0.97,
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
                          labelText: "full name",
                          labelStyle: TextStyle(fontSize: 20),
                          isDense: true,
                          contentPadding: EdgeInsets.all(20.0),
                        ),
                        onChanged: (text) {
                          setState(() {
                            full_name = text;
                          });
                        },
                      ),
                    ))),
            Container(
                width: MediaQuery.of(context).size.width * 0.97,
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
                          labelText: "ID No",
                          labelStyle: TextStyle(fontSize: 20),
                          isDense: true,
                          contentPadding: EdgeInsets.all(20.0),
                        ),
                        onChanged: (text) {
                          setState(() {
                            id_no = text;
                          });
                        },
                      ),
                    ))),
            Container(
                width: MediaQuery.of(context).size.width * 0.97,
                margin: EdgeInsets.only(bottom: 10),
                child: Center(
                    child: SizedBox(
                      width: 1000,
                      height: 56,
                      child: TextFormField(
                        keyboardType: TextInputType.phone,
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
                          labelText: "Phone Number",
                          labelStyle: TextStyle(fontSize: 20),
                          isDense: true,
                          contentPadding: EdgeInsets.all(20.0),
                        ),
                        onChanged: (text) {
                          setState(() {
                            phone_number= text;
                          });
                        },
                      ),
                    ))),
            Container(
                width: MediaQuery.of(context).size.width * 0.97,
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
                          labelText: "Township",
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

            SizedBox(
                width: double.infinity,
                height: 57,
                child: RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                    color: Theme.of(context).buttonColor,
                    onPressed: () {
                      updateProfile();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Done",
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
    );
  }

}