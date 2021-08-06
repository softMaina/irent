import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:path/path.dart' as Path;
import 'package:sqflite/sqflite.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;
FirebaseAuth auth = FirebaseAuth.instance;

class EditProfile extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _EditProfile();
}

class _EditProfile extends State<EditProfile> {
  GoogleSignInAccount _currentUser;
  GoogleSignIn _googleSignIn = GoogleSignIn(scopes: <String>['email']);

  String category = 'Men';
  CollectionReference users = FirebaseFirestore.instance.collection("users");

  String phone_number;
  String id_no;
  String full_name;
  String location;

  var numberController = new TextEditingController();
  var idController = new TextEditingController();
  var nameController = new TextEditingController();
  var locationController = new TextEditingController();

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

      numberController.text = list[0]['contact'];
      idController.text = list[0]['idno'].toString();
      nameController.text = list[0]['name'];
      locationController.text = list[0]['location'];
    }
  }

  saveUserLocally(phone_number, id_no, full_name, location) async {
    // full_name, id_no, phone_number, township
    var databasePath = await getDatabasesPath();
    String path = Path.join(databasePath, 'user.db');

    Database database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute(
          'CREATE TABLE user (id INTEGER PRIMARY KEY, name TEXT, idno INTEGER, contact TEXT, complete INTEGER)');
    });

    await database.transaction((txn) async {
      int d1 = await txn.rawInsert(
          'INSERT INTO user (name, idno, contact,complete) VALUES(?, ? , ?, ?)',
          [full_name, id_no, phone_number, 1]);
    });
  }

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

  updateProfile() async {
    if (_currentUser != null) {
      await users.doc(_currentUser.email).update({
        'full_name': full_name,
        'id_no': id_no,
        'location': location,
        'phone_number': phone_number
      }).then((value) {
        final snackBar = SnackBar(
          backgroundColor: Colors.greenAccent,
          content: Text('Updated!!'),
        );
        saveUserLocally(phone_number, id_no, full_name, location);
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
        title: Text('Update Profile'),
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
                    controller: nameController,
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
                    controller: idController,
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
                    controller: numberController,
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
                        phone_number = text;
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
                    controller: locationController,
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
