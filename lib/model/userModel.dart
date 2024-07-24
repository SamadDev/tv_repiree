import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  double? type;
  String? name;
  String? password;
  DateTime? addedDate;

  UserModel({this.type, this.name, this.addedDate, this.password});

  UserModel.fromJson(map) {
    this.type = map["type"];
    this.name = map["name"];
    this.password = map["password"];
    this.addedDate = map["addedDate"].toDate();
  }

  Map<String, dynamic> toJson(UserModel user) {
    return {
      "type": user.type,
      "name": user.name,
      "password": user.password,
      "addedDate": Timestamp.fromDate(user.addedDate!)
    };
  }
}
