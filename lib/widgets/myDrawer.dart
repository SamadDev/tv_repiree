import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tv_repair/constants/constatns.dart';
import 'package:tv_repair/constants/helper_functions.dart';
import 'package:tv_repair/firebase_functions/firebase_functions.dart';
import 'package:tv_repair/main.dart';
import 'package:tv_repair/model/userModel.dart';
import 'package:tv_repair/screens/businessScreen.dart';
import 'package:tv_repair/screens/customerList.dart';
import 'package:tv_repair/screens/salesReport.dart';
import 'package:tv_repair/screens/salesReportModel.dart';
import 'package:tv_repair/screens/tvModelList.dart';
import 'package:tv_repair/screens/usersListScreen.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({Key? key}) : super(key: key);

  @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: double.infinity,
                color: primaryColor(1.0),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8.0, horizontal: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 50,
                      ),
                      Container(
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, color: Colors.white),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Icon(
                              Icons.person,
                              size: 50,
                              color: primaryColor(1.0),
                            ),
                          )),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "${_auth.currentUser!.email!.split("@")[0].capitalize()}",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                  top: 50,
                  right: 10,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    color: Colors.white,
                  ))
            ],
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(vertical: 10),
              children: [
                Visibility(
                  visible: userAd == userA,
                  child: Column(
                    children: [
                      InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => UserList()));
                          },
                          child: ListTile(
                            leading: Icon(
                              CupertinoIcons.person_alt,
                              color: primaryColor(1.0),
                            ),
                            title: Text(
                              "Users",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          )),
                      Divider(),
                      InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SalesReport()));
                          },
                          child: ListTile(
                            leading: Icon(
                              CupertinoIcons.money_dollar_circle_fill,
                              color: primaryColor(1.0),
                            ),
                            title: Text(
                              "Sales Report",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          )),
                      Divider(),
                      InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SalesReportModel()));
                          },
                          child: ListTile(
                            leading: Icon(
                              CupertinoIcons.money_dollar_circle_fill,
                              color: primaryColor(1.0),
                            ),
                            title: Text(
                              "Sales Report Model",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          )),
                      Divider(),
                      InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => BusinessScreen()));
                          },
                          child: ListTile(
                            leading: Icon(
                              Icons.business_center,
                              color: primaryColor(1.0),
                            ),
                            title: Text(
                              "Business",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          )),
                      Divider(),
                    ],
                  ),
                ),
                InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CustomerList(
                                    fromDrawer: true,
                                  )));
                    },
                    child: ListTile(
                      leading: Icon(
                        Icons.person,
                        color: primaryColor(1.0),
                      ),
                      title: Text(
                        "Customers",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    )),
                Divider(),
                InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TVModelList(
                                    fromDrawer: true,
                                  )));
                    },
                    child: ListTile(
                      leading: Icon(
                        Icons.tv,
                        color: primaryColor(1.0),
                      ),
                      title: Text(
                        "TV Models",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    )),
                Divider(),
                InkWell(
                    onTap: () {
                      areYouSure(context, () {
                        _auth.signOut().then((value) {
                          HotRestartController.performHotRestart(context);
                        });
                      }, title: "Are you sure to logout");
                    },
                    child: ListTile(
                      leading: Icon(
                        Icons.logout,
                        color: primaryColor(1.0),
                      ),
                      title: Text(
                        "Logout",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    )),
              ],
            ),
          )
        ],
      ),
    );
  }
}
