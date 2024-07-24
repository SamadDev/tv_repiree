import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tv_repair/MainScreen.dart';
import 'package:tv_repair/constants/constatns.dart';
import 'package:tv_repair/widgets/customClipper.dart';
import 'package:tv_repair/widgets/loader.dart';

import 'homeScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController userNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  bool showLoading = false;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Stack(
      children: [
        Scaffold(
            body: Form(
          key: _formKey,
          // autovalidate: _autoValidate,
          child: Container(
            height: height,
            child: Stack(
              children: <Widget>[
                Positioned(
                  top: -MediaQuery.of(context).size.height * .15,
                  right: -MediaQuery.of(context).size.width * .4,
                  child: Container(
                      child: Transform.rotate(
                    angle: -pi / 3.5,
                    child: ClipPath(
                      clipper: ClipPainter(),
                      child: Container(
                        height: MediaQuery.of(context).size.height * .5,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xffE6E6E6),
                              secondaryColor(.6),
                              secondaryColor(1.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(height: height * .22),
                        Text('NGS',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            )),
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                              text: 'TV',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w700,
                                color: secondaryColor(1.0),
                              ),
                              children: [
                                TextSpan(
                                  text: 'Repair',
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 30),
                                ),
                              ]),
                        ),
                        SizedBox(height: 50),
                        Column(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    "Username",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  TextFormField(
                                      obscureText: false,
                                      controller: userNameController,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'please fill this field';
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                          border: InputBorder.none,
                                          fillColor: Color(0xfff3f3f4),
                                          filled: true))
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    "Password",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  TextFormField(
                                      obscureText: true,
                                      controller: passwordController,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'please fill this field';
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                          border: InputBorder.none,
                                          fillColor: Color(0xfff3f3f4),
                                          filled: true))
                                ],
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 20),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              userAd = 1;
                              _autoValidate = true;
                            });
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                showLoading = true;
                              });
                              _auth
                                  .signInWithEmailAndPassword(
                                      email: userNameController.text +
                                          "@tvRepair.com",
                                      password: passwordController.text)
                                  .then((value) {
                                if (value.user != null) {
                                  setState(() {
                                    showLoading = false;
                                  });
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MainScreen(),
                                    ),
                                  );
                                }
                              }).catchError((e) {
                                setState(() {
                                  showLoading = false;
                                });
                                if (e.code == 'user-not-found') {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content: Text(
                                      "User not found",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    backgroundColor: Colors.red,
                                  ));
                                } else if (e.code == 'wrong-password') {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content: Text("Wrong Password",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    backgroundColor: Colors.red,
                                  ));
                                }
                              });
                            }
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            padding: EdgeInsets.symmetric(vertical: 15),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5)),
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                      color: Colors.grey.shade200,
                                      offset: Offset(2, 4),
                                      blurRadius: 5,
                                      spreadRadius: 2)
                                ],
                                color: secondaryColor(1.0)),
                            child: Text(
                              'Login',
                              style:
                                  TextStyle(fontSize: 20, color: Colors.white),
                            ),
                          ),
                        ),
                        SizedBox(height: height * .055),
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 20),
                          padding: EdgeInsets.all(15),
                          alignment: Alignment.bottomCenter,
                          child: Text(
                            'Developed by JIASAZ company',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: primaryColor(1.0)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        )),
        Loader(showLoading: showLoading),
      ],
    );
  }
}
