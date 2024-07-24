import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:tv_repair/constants/constatns.dart';

// ignore: must_be_immutable
class Loader extends StatelessWidget {
  bool showLoading;

  Loader({Key? key, this.showLoading = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: showLoading,
      child: Container(
        color: primaryColor(.5),
        child: Center(
          child: SizedBox(
            child: Lottie.asset("assets/loading.json", width: 150, height: 150),
          ),
        ),
      ),
    );
  }
}
