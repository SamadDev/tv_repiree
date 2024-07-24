import 'package:flutter/material.dart';
import 'package:tv_repair/constants/constatns.dart';

// ignore: must_be_immutable
class InvoiceDetailItem extends StatelessWidget {
  final title;
  final String? data;
  bool rowLayout;

  InvoiceDetailItem({
    this.title,
    this.data,
    this.rowLayout = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: rowLayout ? 0 : 6,
      ),
      child: rowLayout
          ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                "$title:",
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                width: 6,
              ),
              Text(
                "${data == "" ? "N/A" : data.toString()}",
                style: TextStyle(
                  color: primaryColor(1.0),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ])
          : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                "$title:",
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text("${data == "" ? "N/A" : data.toString()}"),
            ]),
    );
  }
}
