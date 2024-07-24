import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:tv_repair/constants/constatns.dart';
import 'package:tv_repair/constants/helper_functions.dart';
import 'package:tv_repair/firebase_functions/firebase_functions.dart';
import 'package:tv_repair/model/customerModel.dart';
import 'package:tv_repair/widgets/searchItem.dart';
import 'package:tv_repair/widgets/textInputItem.dart';

class CustomerList extends StatefulWidget {
  const CustomerList({Key? key, this.fromDrawer = false}) : super(key: key);
  final bool fromDrawer;

  @override
  _CustomerListState createState() => _CustomerListState();
}

class _CustomerListState extends State<CustomerList> {
  TextEditingController searchController = TextEditingController();
  TextEditingController nameNoteController = TextEditingController();
  TextEditingController phoneNoteController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  bool showLoading = false;

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
              elevation: 0,
              title: Column(
                children: [
                  Text("Customers"),
                ],
              ),
              actions: [submitCustomer(icon: Icons.add)],
            ),
            body: Column(
              children: [
                Material(
                    color: primaryColor(1.0),
                    elevation: 2,
                    child: SearchItem(
                      searchController: searchController,
                      hint: "search for customer",
                      onChange: (v) {
                        setState(() {});
                      },
                    )),
                SizedBox(
                  height: 6,
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                      stream: FireBaseHelperFunctions().getAllCustomers(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data!.docs.length == 0) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  CupertinoIcons.search,
                                  size: 100,
                                  color: primaryColor(1.0),
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                                Text(
                                  "No Item Found",
                                  style: TextStyle(
                                      color: primaryColor(1.0),
                                      fontWeight: FontWeight.w500),
                                )
                              ],
                            );
                          }
                          return Scrollbar(
                            child: ListView.builder(
                                itemCount: snapshot.data!.docs.length,
                                itemBuilder: (context, index) {
                                  CustomerModel customer =
                                      CustomerModel.fromJson(
                                          snapshot.data!.docs[index]);
                                  return customer.name!.toLowerCase().contains(
                                              searchController.text
                                                  .toLowerCase()) ||
                                          customer.phone!
                                              .toString()
                                              .toLowerCase()
                                              .contains(searchController.text
                                                  .toLowerCase())
                                      ? Card(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12)),
                                          child: InkWell(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            onTap: widget.fromDrawer ? null:() {
                                              Navigator.pop(context, customer);
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(12.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        "${customer.name}",
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            color:
                                                                Colors.black87,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      SizedBox(
                                                        height: 6,
                                                      ),
                                                      Text(
                                                        "${customer.phone}",
                                                        style: TextStyle(
                                                          color: Colors.black87,
                                                        ),
                                                      ),
                                                      Text(
                                                        "${customer.addedDate}",
                                                        style: TextStyle(
                                                          color: Colors.black87,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Column(
                                                    children: [
                                                      submitCustomer(
                                                          customer: customer,
                                                          editMode: true,
                                                          icon: Icons.edit),
                                                      IconButton(
                                                          onPressed: () {
                                                            areYouSure(context,
                                                                () {
                                                              this.setState(() {
                                                                showLoading =
                                                                    true;
                                                              });
                                                              FireBaseHelperFunctions()
                                                                  .deleteCustomer(
                                                                      customer)
                                                                  .then(
                                                                      (value) {
                                                                this.setState(
                                                                    () {
                                                                  showLoading =
                                                                      false;
                                                                });
                                                              });
                                                            },
                                                                title:
                                                                    "Are sure to delete this customer?");
                                                          },
                                                          icon: Icon(
                                                              Icons.delete))
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                      : SizedBox();
                                }),
                          );
                        } else {
                          return Center(
                            child: SizedBox(
                              child: Lottie.asset("assets/loading.json",
                                  width: 150, height: 150),
                            ),
                          );
                        }
                      }),
                ),
              ],
            ),
          ),
          Visibility(
            visible: showLoading,
            child: Container(
              color: primaryColor(.5),
              child: Center(
                child: SizedBox(
                  child: Lottie.asset("assets/loading.json",
                      width: 150, height: 150),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget submitCustomer(
      {bool editMode = false, CustomerModel? customer, IconData? icon}) {
    return IconButton(
        onPressed: () async {
          this.setState(() {
            _autoValidate = false;
            if (editMode) {
              nameNoteController.text = customer!.name!;
              phoneNoteController.text = customer.phone!.toString();

            } else {
              nameNoteController.text = "";
              phoneNoteController.text = "";

            }
          });
          showDialog(
              context: context,
              builder: (context) {
                return StatefulBuilder(
                  builder: (context, setState) => AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    title: editMode
                        ? Text("Are you sure to edit this customer?")
                        : Text("Are you sure to add  this customer?"),
                    content: Form(
                      key: _formKey,
                      // autovalidate: _autoValidate,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextInputItem(
                            title: "Name",
                            hint: "write customer name",
                            controller: nameNoteController,
                          ),
                          TextInputItem(
                            title: "Phone",
                            hint: "write customer phone",
                            controller: phoneNoteController,
                          ),

                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text("Cancel")),
                      TextButton(
                          onPressed: () {
                            setState(() {
                              _autoValidate = true;
                            });
                            if (_formKey.currentState!.validate()) {
                              Navigator.pop(context);
                              this.setState(() {
                                showLoading = true;
                              });
                              if (editMode) {
                                CustomerModel updateCustomer = customer!;
                                updateCustomer.name = nameNoteController.text;
                                updateCustomer.phone =
                                    int.parse(phoneNoteController.text);

                                FireBaseHelperFunctions()
                                    .updateCustomer(updateCustomer)
                                    .then((value) {
                                  this.setState(() {
                                    showLoading = false;
                                  });
                                });
                              } else {
                                CustomerModel newCustomer = CustomerModel(
                                    name: nameNoteController.text,
                                    phone: int.parse(phoneNoteController.text),

                                    addedDate: DateTime.now());
                                FireBaseHelperFunctions()
                                    .addNewCustomer(newCustomer)
                                    .then((value) {
                                  this.setState(() {
                                    showLoading = false;
                                  });
                                });
                              }
                            }
                          },
                          child: Text("Yes")),
                    ],
                  ),
                );
              });
        },
        icon: Icon(icon));
  }
}
