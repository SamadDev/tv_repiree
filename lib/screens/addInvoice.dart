import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tv_repair/constants/constatns.dart';
import 'package:tv_repair/constants/helper_functions.dart';
import 'package:tv_repair/firebase_functions/firebase_functions.dart';
import 'package:tv_repair/model/invoiceModel.dart';
import 'package:tv_repair/screens/customerList.dart';
import 'package:tv_repair/screens/tvModelList.dart';
import 'package:tv_repair/widgets/loader.dart';

import 'package:tv_repair/widgets/textInputItem.dart';

class AddInvoice extends StatefulWidget {
  const AddInvoice({Key? key, this.invoice, this.editMode = false})
      : super(key: key);
  final InvoiceModel? invoice;
  final bool editMode;

  @override
  _AddInvoiceState createState() => _AddInvoiceState(this.invoice);
}

class _AddInvoiceState extends State<AddInvoice> {
  TextEditingController cNameController = TextEditingController();
  TextEditingController cPhoneController = TextEditingController();
  TextEditingController repairNoteController = TextEditingController();

  List<ItemAmountControllers> itemAmountControllers = [];

  List<ItemAmount> amounts = [];

  final InvoiceModel? invoice;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  bool showLoading = false;

  _AddInvoiceState(this.invoice);

  @override
  void initState() {
    super.initState();
    if (widget.editMode == true) {
      setState(() {
        cNameController.text = invoice!.customerName!;
        cPhoneController.text = invoice!.customerPhone!;
        repairNoteController.text =
            invoice!.repairNote == null ? "" : invoice!.repairNote!;
        amounts = invoice!.amounts == null || invoice!.amounts!.length == 0
            ? []
            : invoice!.amounts!;
        if (invoice!.amounts != null) {
          for (int i = 0; i < invoice!.amounts!.length; i++) {
            itemAmountControllers.add(ItemAmountControllers(
                modelController:
                    TextEditingController(text: invoice!.amounts![i].model),
                amountMoneyController: TextEditingController(
                    text: invoice!.amounts![i].amountMoney.toString()),
                problemController:
                    TextEditingController(text: invoice!.amounts![i].problem)));
          }
        }
      });
    } else {
      setState(() {
        itemAmountControllers = [
          ItemAmountControllers(
              modelController: TextEditingController(),
              amountMoneyController: TextEditingController(),
              problemController: TextEditingController())
        ];
        amounts = [
          ItemAmount(
            model: "",
            problem: "",
            amountMoney: 0,
          )
        ];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              title: Text(widget.editMode ? "Update Invoice" : "New Invoice"),
            ),
            floatingActionButton: submitButton(),
            body: Form(
              key: _formKey,
              // autovalidate: _autoValidate,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView(
                  children: [
                    !widget.editMode
                        ? SizedBox()
                        : Visibility(
                            visible: invoice != null &&
                                (invoice!.status == 1 || invoice!.status == 2),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              child: Padding(
                                padding: const EdgeInsets.all(14.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Invoice Information:",
                                      style: TextStyle(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16),
                                    ),
                                    TextInputItem(
                                      title: "Repair Note",
                                      hint: "enter repair note",
                                      controller: repairNoteController,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Customer Information:",
                                  style: TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16),
                                ),
                                IconButton(
                                    onPressed: () async {
                                      var result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  CustomerList()));
                                      if (result != null) {
                                        print("$result");
                                        setState(() {
                                          cNameController.text =
                                              result.name.toString();
                                          cPhoneController.text =
                                              result.phone.toString();
                                        });
                                      }
                                    },
                                    icon: Icon(
                                      Icons.import_contacts,
                                      color: secondaryColor(1.0),
                                    ))
                              ],
                            ),
                            TextInputItem(
                              title: "Name",
                              hint: "enter customer name",
                              controller: cNameController,
                            ),
                            TextInputItem(
                              title: "Phone",
                              hint: "enter customer phone",
                              controller: cPhoneController,
                              keyboardType: TextInputType.number,
                            ),
                            SizedBox(height: 20,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Device Information:",
                                  style: TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16),
                                ),
                              ],
                            ),
                            ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: amounts.length,
                                itemBuilder: (context, index) {
                                  return Column(
                                    children: [
                                      Stack(
                                        children: [
                                          TextInputItem(
                                            title: "Model",
                                            hint: "enter model name",
                                            controller:
                                            itemAmountControllers[index]
                                                .modelController,
                                            onChange: (v) {
                                              setState(() {
                                                amounts[index].model = v;
                                              });
                                            },
                                          ),
                                          Positioned(
                                            top: 0,
                                            right: 0,
                                            child: Row(
                                              children: [
                                                IconButton(
                                                    onPressed: () async {
                                                      var result =
                                                      await Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder:
                                                                  (context) =>
                                                                  TVModelList()));
                                                      if (result != null) {
                                                        setState(() {
                                                          amounts[index].model =
                                                              result.name
                                                                  .toString();
                                                          itemAmountControllers[
                                                          index]
                                                              .modelController!
                                                              .text =
                                                              result.name
                                                                  .toString();
                                                        });
                                                      }
                                                    },
                                                    icon: Icon(
                                                      Icons.import_contacts,
                                                      color:
                                                      secondaryColor(1.0),
                                                    )),
                                                Visibility(
                                                  visible: index != 0,
                                                  child: IconButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          _autoValidate = false;
                                                          amounts.remove(
                                                              amounts[index]);
                                                          itemAmountControllers
                                                              .remove(
                                                              itemAmountControllers[
                                                              index]);
                                                        });
                                                      },
                                                      icon: Icon(
                                                        Icons.delete,
                                                        color: Colors.red,
                                                      )),
                                                )
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                      TextInputItem(
                                        title: "Problem",
                                        hint: "enter the problem",
                                        controller: itemAmountControllers[index]
                                            .problemController,
                                        // initialValue: amounts[index].problem,
                                        onChange: (v) {
                                          setState(() {
                                            amounts[index].problem = v;
                                          });
                                        },
                                      ),
                                      widget.editMode && invoice!.status == 2
                                          ? TextInputItem(
                                        title: "Amount",
                                        hint: "write amount of money",
                                        controller:
                                        itemAmountControllers[index]
                                            .amountMoneyController,
                                        // initialValue:
                                        //     "${invoice!.amounts![index].amountMoney}",
                                        keyboardType:
                                        TextInputType.number,
                                        onChange: (v) {
                                          setState(() {
                                            amounts[index].amountMoney =
                                                double.parse(v!);
                                          });
                                        },
                                      )
                                          : SizedBox(),
                                      Visibility(
                                          visible: index != amounts.length - 1,
                                          child: Divider(
                                            thickness: 1,
                                          )),
                                      Visibility(
                                        visible: index == amounts.length - 1,
                                        child: IconButton(
                                            onPressed: () {
                                              setState(() {
                                                _autoValidate = false;
                                                amounts.add(ItemAmount(
                                                    model: "",
                                                    problem: "",
                                                    amountMoney: 0));
                                                itemAmountControllers.add(
                                                    ItemAmountControllers(
                                                        modelController:
                                                        TextEditingController(),
                                                        amountMoneyController:
                                                        TextEditingController(),
                                                        problemController:
                                                        TextEditingController()));
                                              });
                                            },
                                            icon: Icon(
                                              Icons.add,
                                              color: secondaryColor(1.0),
                                            )),
                                      ),
                                    ],
                                  );
                                }),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Loader(showLoading: showLoading),
        ],
      ),
    );
  }

  Widget submitButton() {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        setState(() {
          _autoValidate = true;
        });
        if (_formKey.currentState!.validate()) {
          areYouSure(context, () async {
            setState(() {
              showLoading = true;
            });
            if (widget.editMode == true) {
              InvoiceModel invoice = InvoiceModel(
                  customerName: cNameController.text,
                  customerPhone: cPhoneController.text,
                  repairNote: repairNoteController.text,
                  userName: this.invoice!.userName,
                  amounts: amounts,
                  id: this.invoice!.id,
                  status: this.invoice!.status,
                  addedDate: this.invoice!.addedDate);
              FireBaseHelperFunctions().updateInvoice(invoice).then((value) {
                setState(() {
                  showLoading = false;
                  Navigator.pop(this.context, true);
                });
              });
            } else {
              InvoiceModel invoice = InvoiceModel(
                customerName: cNameController.text,
                customerPhone: cPhoneController.text,
                userName: _auth.currentUser == null
                    ? ""
                    : "${_auth.currentUser!.email!.split("@")[0].capitalize()}",
                amounts: amounts,
                status: 0,
                addedDate: DateTime.now(),
              );

              int? lastID;
              await FireBaseHelperFunctions()
                  .getLastInvoiceIDFuture()
                  .then((value) {
                lastID = int.parse(value.docs[0]["id"].toString()) + 1;
              });
              await FireBaseHelperFunctions().updateLastInvoiceID(lastID);
              invoice.id = lastID;
              FireBaseHelperFunctions().addNewInvoice(invoice).then((value) {
                setState(() {
                  showLoading = false;
                  Navigator.pop(this.context);
                });
              });
            }
          },
              title: widget.editMode
                  ? "Are you sure to update this form?"
                  : "Are you sure to submit this form?");
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: secondaryColor(1.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "Submit",
            style: TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}
