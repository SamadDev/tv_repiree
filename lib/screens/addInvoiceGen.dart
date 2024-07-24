import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tv_repair/constants/constatns.dart';
import 'package:tv_repair/constants/helper_functions.dart';
import 'package:tv_repair/firebase_functions/firebase_functions.dart';
import 'package:tv_repair/model/invoiceGenModel.dart';
import 'package:tv_repair/screens/customerList.dart';
import 'package:tv_repair/screens/tvModelList.dart';
import 'package:tv_repair/widgets/loader.dart';
import 'package:tv_repair/widgets/textInputItem.dart';

class AddInvoiceGen extends StatefulWidget {
  const AddInvoiceGen({Key? key, this.invoice, this.editMode = false})
      : super(key: key);
  final InvoiceGenModel? invoice;
  final bool editMode;

  @override
  _AddInvoiceGenState createState() => _AddInvoiceGenState(this.invoice);
}

class _AddInvoiceGenState extends State<AddInvoiceGen> {
  TextEditingController cNameController = TextEditingController();
  TextEditingController cPhoneController = TextEditingController();

  List<ItemAmountGenControllers> itemAmountControllers = [];

  List<ItemAmountGen> amounts = [];

  final InvoiceGenModel? invoice;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  bool showLoading = false;

  _AddInvoiceGenState(this.invoice);

  @override
  void initState() {
    super.initState();
    if (widget.editMode == true) {
      setState(() {
        cNameController.text = invoice!.customerName!;
        cPhoneController.text = invoice!.customerPhone!;
        amounts = invoice!.amounts == null || invoice!.amounts!.length == 0
            ? []
            : invoice!.amounts!;
        if (invoice!.amounts != null) {
          for (int i = 0; i < invoice!.amounts!.length; i++) {
            itemAmountControllers.add(ItemAmountGenControllers(
              titleController:
                  TextEditingController(text: invoice!.amounts![i].title),
              amountMoneyController: TextEditingController(
                  text: invoice!.amounts![i].amountMoney.toString()),
            ));
          }
        }
      });
    } else {
      setState(() {
        itemAmountControllers = [
          ItemAmountGenControllers(
            titleController: TextEditingController(),
            amountMoneyController: TextEditingController(),
          )
        ];
        amounts = [
          ItemAmountGen(
            title: "",
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
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Items:",
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
                                            title: "Title",
                                            hint: "enter title",
                                            controller:
                                                itemAmountControllers[index]
                                                    .titleController,
                                            onChange: (v) {
                                              setState(() {
                                                amounts[index].title = v;
                                              });
                                            },
                                          ),
                                          Positioned(
                                            top: 0,
                                            right: 0,
                                            child: Visibility(
                                              visible: index != 0,
                                              child: IconButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      _autoValidate = false;
                                                      amounts.remove(
                                                          amounts[index]);
                                                      itemAmountControllers.remove(
                                                          itemAmountControllers[
                                                              index]);
                                                    });
                                                  },
                                                  icon: Icon(
                                                    Icons.delete,
                                                    color: Colors.red,
                                                  )),
                                            ),
                                          )
                                        ],
                                      ),
                                      TextInputItem(
                                        title: "Amount",
                                        hint: "write amount of money",
                                        controller: itemAmountControllers[index]
                                            .amountMoneyController,
                                        // initialValue:
                                        //     "${invoice!.amounts![index].amountMoney}",
                                        keyboardType: TextInputType.number,
                                        onChange: (v) {
                                          setState(() {
                                            amounts[index].amountMoney =
                                                double.parse(v!);
                                          });
                                        },
                                      ),
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
                                                amounts.add(ItemAmountGen(
                                                    title: "", amountMoney: 0));
                                                itemAmountControllers.add(
                                                    ItemAmountGenControllers(
                                                  titleController:
                                                      TextEditingController(),
                                                  amountMoneyController:
                                                      TextEditingController(),
                                                ));
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
              InvoiceGenModel invoice = InvoiceGenModel(
                  customerName: cNameController.text,
                  customerPhone: cPhoneController.text,
                  userName: this.invoice!.userName,
                  amounts: amounts,
                  id: this.invoice!.id,
                  status: this.invoice!.status,
                  addedDate: this.invoice!.addedDate);
              FireBaseHelperFunctions().updateInvoiceGen(invoice).then((value) {
                setState(() {
                  showLoading = false;
                  Navigator.pop(this.context, true);
                });
              });
            } else {
              InvoiceGenModel invoice = InvoiceGenModel(
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
                  .getLastInvoiceGenIDFuture()
                  .then((value) {
                lastID = int.parse(value.docs[0]["id"].toString()) + 1;
              });
              await FireBaseHelperFunctions().updateLastInvoiceGenID(lastID);
              invoice.id = lastID;
              FireBaseHelperFunctions().addNewInvoiceGen(invoice).then((value) {
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
