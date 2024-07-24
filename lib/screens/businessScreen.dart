import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:tv_repair/constants/constatns.dart';
import 'package:tv_repair/constants/helper_functions.dart';
import 'package:tv_repair/firebase_functions/firebase_functions.dart';
import 'package:tv_repair/model/businessModel.dart';
import 'package:tv_repair/screens/addBusiness.dart';
import 'package:tv_repair/widgets/loader.dart';

class BusinessScreen extends StatefulWidget {
  const BusinessScreen({Key? key}) : super(key: key);

  @override
  _BusinessScreenState createState() => _BusinessScreenState();
}

class _BusinessScreenState extends State<BusinessScreen> {
  bool showLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
                title: Text("Business Information"),
              ),
              body: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: StreamBuilder<QuerySnapshot>(
                      stream: FireBaseHelperFunctions().getAllBusiness(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data!.docs.isEmpty) {
                            return Center(
                              child: Column(
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
                              ),
                            );
                          }
                          return Scrollbar(
                            child: ListView.builder(
                                itemCount: snapshot.data!.docs.length,
                                itemBuilder: (context, index) {
                                  BusinessModel business =
                                      BusinessModel.fromJson(
                                          snapshot.data!.docs[index]);
                                  return Card(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    child: IntrinsicHeight(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 10,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                color: Colors.green),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(12.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Text(
                                                            "Title:",
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                color: Colors
                                                                    .black87,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          SizedBox(
                                                            width: 8,
                                                          ),
                                                          Text(
                                                            "${business.title}",
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .black87,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: 6,
                                                      ),
                                                      Row(
                                                        children: [
                                                          Text(
                                                            "Address:",
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                color: Colors
                                                                    .black87,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          SizedBox(
                                                            width: 8,
                                                          ),
                                                          Text(
                                                            "${business.address}",
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .black87,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: 6,
                                                      ),
                                                      Row(
                                                        children: [
                                                          Text(
                                                            "Footer:",
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                color: Colors
                                                                    .black87,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          SizedBox(
                                                            width: 8,
                                                          ),
                                                          Text(
                                                            "${business.footer}",
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .black87,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: 6,
                                                      ),
                                                      Row(
                                                        children: [
                                                          Text(
                                                            "Added Date:",
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                color: Colors
                                                                    .black87,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          SizedBox(
                                                            width: 8,
                                                          ),
                                                          Text(
                                                            "${business.addedDate.toString().split(".")[0]}",
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .black87,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: 6,
                                                      ),
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            "Logo:",
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                color: Colors
                                                                    .black87,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          SizedBox(
                                                            height: 6,
                                                          ),
                                                          business.logo == null || business.logo == "" ? SizedBox():SizedBox(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                .7,
                                                            child:
                                                                Image.network(
                                                              "${business.logo}",
                                                              fit: BoxFit
                                                                  .contain,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  IconButton(
                                                      onPressed: () async {
                                                        var result = await Navigator
                                                            .push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            AddBusiness(
                                                                              business: business,
                                                                              editMode: true,
                                                                            )));
                                                      },
                                                      icon: Icon(Icons.edit)),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
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
                      })),
              floatingActionButton: StreamBuilder<QuerySnapshot>(
                  stream: FireBaseHelperFunctions().getAllBusiness(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data!.docs.length == 0) {
                        return FloatingActionButton(
                          onPressed: _addBusiness,
                          backgroundColor: secondaryColor(1.0),
                          child: Icon(Icons.add),
                        );
                      } else {
                        BusinessModel business =
                            BusinessModel.fromJson(snapshot.data!.docs[0]);
                        return FloatingActionButton(
                          onPressed: () async {
                            areYouSure(context, () {
                              this.setState(() {
                                showLoading = true;
                              });
                              FireBaseHelperFunctions()
                                  .deleteBusiness(business)
                                  .then((value) {
                                this.setState(() {
                                  showLoading = false;
                                });
                              });
                            }, title: "Are sure to delete this business?");
                          },
                          backgroundColor: Colors.red,
                          child: Icon(Icons.remove),
                        );
                      }
                    } else {
                      return SizedBox();
                    }
                  })),
          Loader(
            showLoading: showLoading,
          )
        ],
      ),
    );
  }

  _addBusiness() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => AddBusiness()));
  }
}
