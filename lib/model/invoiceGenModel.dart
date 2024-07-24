import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class InvoiceGenModel {
  String? customerName;
  int? id;
  String? customerPhone;
  int? status;
  List<ItemAmountGen>? amounts = [];
  String? userName;
  DateTime? addedDate;

  InvoiceGenModel(
      {this.customerName,
      this.customerPhone,
      this.status,
      this.amounts,
      this.userName,
      this.addedDate,
      this.id});

  InvoiceGenModel.fromJson(map) {
    this.customerName = map["customerName"];
    this.customerPhone = map["customerPhone"];

    this.status = map["status"];
    for (var i in map["amounts"]) {
      this.amounts!.add(ItemAmountGen.fromJson(i));
    }
    this.userName = map["userName"];
    this.id = int.parse(map["id"].toString());
    this.addedDate = map["addedDate"].toDate();
  }

  Map<String, dynamic> toJson(InvoiceGenModel invoice) {
    List amountsResult = [];
    for (var i in invoice.amounts!) {
      amountsResult.add(ItemAmountGen().toJson(i));
    }
    return {
      "customerName": invoice.customerName,
      "customerPhone": invoice.customerPhone,
      "status": invoice.status,
      "id": invoice.id,
      "amounts": amountsResult,
      "userName": invoice.userName,
      "addedDate": Timestamp.fromDate(invoice.addedDate!),
    };
  }
}

class ItemAmountGen {
  double? amountMoney;
  String? title;

  ItemAmountGen({this.amountMoney,this.title});

  ItemAmountGen.fromJson(map) {
    this.amountMoney = map["amountMoney"];
    this.title = map["title"];
  }

  Map<String, dynamic> toJson(ItemAmountGen item) {
    return {
      "amountMoney": item.amountMoney,
      "title": item.title,
    };
  }
}

class ItemAmountGenControllers {

  TextEditingController? titleController;
  TextEditingController? amountMoneyController;

  ItemAmountGenControllers(
      {this.titleController,
      this.amountMoneyController});
}
