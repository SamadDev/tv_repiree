import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';
import 'package:tv_repair/checkConnection/checkConnection.dart';
import 'package:tv_repair/constants/constatns.dart';


// ignore: must_be_immutable
class NoConnection extends StatelessWidget {
  const NoConnection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Material(
      child: Scaffold(
        body: ListView(
          children: <Widget>[
            Lottie.asset(
              "assets/no-connection.json",
              fit: BoxFit.cover,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.5,
            ),
            SizedBox(
              height: 14,
            ),
            Center(
              child: Text(
                "No Connection!",
                style: TextStyle(color: Colors.grey, fontSize: 22),
              ),
            ),
            SizedBox(
              height: 22,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: new BoxDecoration(
                    borderRadius: new BorderRadius.all(Radius.circular(60.0)),
                    color: primaryColor(1.0),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: new BorderRadius.all(Radius.circular(60.0)),
                    child: InkWell(
                      borderRadius: new BorderRadius.all(Radius.circular(60.0)),
                      onTap: () async {
                        if (await checkConnection()) {
                          Navigator.pop(context);
                        } else {}
                      },
                      child: Center(
                        child: Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          child: Text(
                            "Retry",
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
