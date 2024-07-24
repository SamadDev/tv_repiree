import 'package:cloud_firestore/cloud_firestore.dart';

class BusinessModel {
  String? title;
  String? address;
  String? logo;
  String? footer;
  DateTime? addedDate;

  BusinessModel({this.title,this.address,this.logo,this.footer, this.addedDate});

  BusinessModel.fromJson(map) {
    this.title = map["title"];
    this.address = map["address"];
    this.logo = map["logo"];
    this.footer = map["footer"];
    this.addedDate = map["addedDate"].toDate();
  }

  Map<String, dynamic> toJson(BusinessModel business) {
    return {
      "title": business.title,
      "address": business.address,
      "logo": business.logo,
      "footer": business.footer,
      "addedDate": Timestamp.fromDate(business.addedDate!)
    };
  }
}
