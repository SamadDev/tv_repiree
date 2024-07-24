import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerModel {
  String? name;
  int? phone;

  DateTime? addedDate;

  CustomerModel({this.name, this.phone, this.addedDate});

  CustomerModel.fromJson(map) {
    this.name = map["name"];
    this.phone = int.parse(map["phone"].toString());

    this.addedDate = map["addedDate"].toDate();
  }

  Map<String, dynamic> toJson(CustomerModel customer) {
    return {
      "name": customer.name,
      "phone": customer.phone,
      "addedDate": Timestamp.fromDate(customer.addedDate!)
    };
  }
}
