import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tv_repair/checkConnection/checkConnection.dart';
import 'package:tv_repair/screens/noConnection.dart';
import 'package:url_launcher/url_launcher.dart';

Future setMyToken(String myToken) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  return preferences.setString("myToken", myToken);
}

var formatter = NumberFormat('#,###.###');

Future getMyToken() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  return preferences.get("myToken");
}

Codec<String, String> stringToBase64 = utf8.fuse(base64);

String encode(credential) {
  return stringToBase64.encode(credential);
}

String decode(credential) {
  return stringToBase64.decode(credential);
}

void launchTelephoneURL(url) async {
  if (!await launch("tel://$url")) throw 'Could not launch $url';
}

areYouSure(context, Function function,
    {required title, Widget? content}) async {
  if (await checkConnection()) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: Text(title),
            content: content,
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Cancel")),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    function();
                  },
                  child: Text("Yes")),
            ],
          );
        });
  } else {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => NoConnection()));
  }
}
