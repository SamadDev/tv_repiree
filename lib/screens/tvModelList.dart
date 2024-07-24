import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:tv_repair/constants/constatns.dart';
import 'package:tv_repair/constants/helper_functions.dart';
import 'package:tv_repair/firebase_functions/firebase_functions.dart';
import 'package:tv_repair/model/customerModel.dart';
import 'package:tv_repair/model/tvModel.dart';
import 'package:tv_repair/widgets/searchItem.dart';
import 'package:tv_repair/widgets/textInputItem.dart';

class TVModelList extends StatefulWidget {
  const TVModelList({Key? key, this.fromDrawer = false}) : super(key: key);
  final bool fromDrawer;

  @override
  _TVModelListState createState() => _TVModelListState();
}

class _TVModelListState extends State<TVModelList> {
  TextEditingController searchController = TextEditingController();
  TextEditingController nameController = TextEditingController();

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
                  Text("TV Models"),
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
                      hint: "search for model",
                      onChange: (v) {
                        setState(() {});
                      },
                    )),
                SizedBox(
                  height: 6,
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                      stream: FireBaseHelperFunctions().getAllModel(),
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
                                  TVModel tvModel = TVModel.fromJson(
                                      snapshot.data!.docs[index]);
                                  return tvModel.name!.toLowerCase().contains(
                                          searchController.text.toLowerCase())
                                      ? Card(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12)),
                                          child: InkWell(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            onTap: widget.fromDrawer
                                                ? null
                                                : () {
                                                    Navigator.pop(
                                                        context, tvModel);
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
                                                        "${tvModel.name}",
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
                                                        "${tvModel.addedDate}",
                                                        style: TextStyle(
                                                          color: Colors.black87,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Column(
                                                    children: [
                                                      submitCustomer(
                                                          tvModel: tvModel,
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
                                                                  .deleteModel(
                                                                      tvModel)
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
                                                                    "Are sure to delete this model?");
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
      {bool editMode = false, TVModel? tvModel, IconData? icon}) {
    return IconButton(
        onPressed: () async {
          this.setState(() {
            _autoValidate = false;
            if (editMode) {
              nameController.text = tvModel!.name!;
            } else {
              nameController.text = "";
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
                        ? Text("Are you sure to edit this Model?")
                        : Text("Are you sure to add  this Model?"),
                    content: Form(
                      key: _formKey,
                      // autovalidate: _autoValidate,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextInputItem(
                            title: "Name",
                            hint: "write customer name",
                            controller: nameController,
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
                                TVModel UpdateTVModel = tvModel!;
                                UpdateTVModel.name = nameController.text;
                                FireBaseHelperFunctions()
                                    .updateModel(UpdateTVModel)
                                    .then((value) {
                                  this.setState(() {
                                    showLoading = false;
                                  });
                                });
                              } else {
                                TVModel newCustomer = TVModel(
                                    name: nameController.text,
                                    addedDate: DateTime.now());
                                FireBaseHelperFunctions()
                                    .addNewModel(newCustomer)
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
