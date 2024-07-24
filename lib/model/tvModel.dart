import 'package:cloud_firestore/cloud_firestore.dart';

class TVModel {
  String? name;
  DateTime? addedDate;

  TVModel({this.name,this.addedDate});

  TVModel.fromJson(map) {
    this.name = map["name"];
    this.addedDate = map["addedDate"].toDate();
  }

  Map<String, dynamic> toJson(TVModel tv) {
    return {
      "name": tv.name,
      "addedDate": Timestamp.fromDate(tv.addedDate!)
    };
  }
}
