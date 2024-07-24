import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class InvoiceModel {
  String? customerName;
  int? id;
  String? customerPhone;
  int? status;
  List<ItemAmount>? amounts = [];
  String? userName;
  DateTime? addedDate;
  String? repairNote;

  InvoiceModel(
      {this.customerName,
      this.customerPhone,
      this.status,
      this.amounts,
      this.userName,
      this.addedDate,
      this.repairNote,
      this.id});

  InvoiceModel.fromJson(map) {
    this.customerName = map["customerName"];
    this.customerPhone = map["customerPhone"];

    this.status = map["status"];
    for (var i in map["amounts"]) {
      this.amounts!.add(ItemAmount.fromJson(i));
    }
    this.userName = map["userName"];
    this.id = int.parse(map["id"].toString());
    this.addedDate = map["addedDate"].toDate();
    this.repairNote = map["repairNote"];
  }

  Map<String, dynamic> toJson(InvoiceModel invoice) {
    List amountsResult = [];
    for (var i in invoice.amounts!) {
      amountsResult.add(ItemAmount().toJson(i));
    }
    return {
      "customerName": invoice.customerName,
      "customerPhone": invoice.customerPhone,
      "status": invoice.status,
      "id": invoice.id,
      "amounts": amountsResult,
      "userName": invoice.userName,
      "addedDate": Timestamp.fromDate(invoice.addedDate!),
      "repairNote": invoice.repairNote,
    };
  }
}

class ItemAmount {
  String? model;
  String? problem;
  double? amountMoney;

  ItemAmount({this.problem, this.model, this.amountMoney});

  ItemAmount.fromJson(map) {
    this.model = map["model"];
    this.problem = map["problem"];
    this.amountMoney = map["amountMoney"];
  }

  Map<String, dynamic> toJson(ItemAmount item) {
    return {
      "model": item.model,
      "problem": item.problem,
      "amountMoney": item.amountMoney,
    };
  }
}

class ItemAmountControllers {
  TextEditingController? modelController;
  TextEditingController? problemController;
  TextEditingController? amountMoneyController;

  ItemAmountControllers(
      {this.problemController,
      this.modelController,
      this.amountMoneyController});
}
