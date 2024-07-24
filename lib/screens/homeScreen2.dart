import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:lottie/lottie.dart';
import 'package:tv_repair/constants/constatns.dart';
import 'package:tv_repair/constants/helper_functions.dart';
import 'package:tv_repair/firebase_functions/firebase_functions.dart';
import 'package:tv_repair/model/invoiceGenModel.dart';
import 'package:tv_repair/model/invoiceModel.dart';
import 'package:tv_repair/model/userModel.dart';
import 'package:tv_repair/screens/addInvoice.dart';
import 'package:tv_repair/screens/addInvoiceGen.dart';
import 'package:tv_repair/screens/invoiceDetail.dart';
import 'package:tv_repair/screens/invoiceDetailGen.dart';
import 'package:tv_repair/widgets/loader.dart';
import 'package:tv_repair/widgets/myDrawer.dart';

class HomeScreen2 extends StatefulWidget {
  HomeScreen2({Key? key}) : super(key: key);

  @override
  _HomeScreen2State createState() => _HomeScreen2State();
}

class _HomeScreen2State extends State<HomeScreen2> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController searchController = TextEditingController();
  bool openSearch = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool showLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FireBaseHelperFunctions()
        .getUserByIDFuture(_auth.currentUser!.email!.split("@")[0])
        .then((value) {
      UserModel user = UserModel.fromJson(value.docs[0].data());
      setState(() {
        userAd = user.type!;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        DefaultTabController(
          length: 2,
          child: Scaffold(
            key: _scaffoldKey,
            drawer: MyDrawer(),
            appBar: AppBar(
              leading: IconButton(
                icon: Icon(CupertinoIcons.list_bullet),
                onPressed: () {
                  _scaffoldKey.currentState!.openDrawer();
                },
              ),
              title: openSearch
                  ? Container(
                      height: 50,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          autofocus: true,
                          controller: searchController,
                          onChanged: (v) {
                            setState(() {});
                          },
                          decoration: InputDecoration(
                              hintText: "search for invoice",
                              border: InputBorder.none),
                        ),
                      ),
                    )
                  : Text("NGS"),
              actions: [
                IconButton(
                  icon: Icon(openSearch ? Icons.clear : Icons.search),
                  onPressed: () {
                    setState(() {
                      openSearch = !openSearch;
                    });
                    if (openSearch == false) {
                      setState(() {
                        searchController.text = "";
                      });
                    }
                  },
                ),
              ],
              bottom: TabBar(
                indicatorColor: Colors.transparent,
                indicatorWeight: 4,
                labelColor: Colors.white,
                isScrollable: false,
                unselectedLabelColor: Colors.grey[400],
                labelStyle:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                labelPadding:
                    EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                tabs: [Text("Paid"), Text("Not Paid")],
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TabBarView(
                children: [
                  _invoiceList(
                    FireBaseHelperFunctions().getAllInvoicesGen(0),
                  ),
                  _invoiceList(
                    FireBaseHelperFunctions().getAllInvoicesGen(1),
                  ),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: _addInvoice,
              backgroundColor: secondaryColor(1.0),
              tooltip: 'Increment',
              child: Icon(Icons.add),
            ), // This trailing comma makes auto-formatting nicer for build methods.
          ),
        ),
        Loader(
          showLoading: showLoading,
        )
      ],
    );
  }

  Widget _invoiceList(stream) {
    return StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            print("lengthhhhrhh ${snapshot.data!.docs.length}");
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
                        color: primaryColor(1.0), fontWeight: FontWeight.w500),
                  )
                ],
              );
            }
            return Scrollbar(
              child: ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    InvoiceGenModel invoice =
                        InvoiceGenModel.fromJson(snapshot.data!.docs[index]);
                    return invoice.customerName!.toLowerCase().contains(
                                searchController.text.toLowerCase()) ||
                            invoice.customerPhone!
                                .toString()
                                .toLowerCase()
                                .contains(
                                    searchController.text.toLowerCase()) ||
                            invoice.id!
                                .toString()
                                .toLowerCase()
                                .contains(searchController.text.toLowerCase())
                        ? Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => InvoiceGenDetail(
                                              invoice: invoice,
                                            )));
                              },
                              child: IntrinsicHeight(
                                child: Slidable(
                                  endActionPane: ActionPane(
                                    motion: const ScrollMotion(),
                                    children: [
                                      SlidableAction(
                                        onPressed: (context) {
                                          setState(() {
                                            showLoading = true;
                                          });
                                          InvoiceGenModel updateInvoice =
                                              invoice;
                                          if (invoice.status == 0) {
                                            updateInvoice.status = 1;
                                          } else if (invoice.status == 1) {
                                            updateInvoice.status = 0;
                                          }
                                          FireBaseHelperFunctions()
                                              .updateInvoiceGen(updateInvoice)
                                              .then((value) {
                                            this.setState(() {
                                              showLoading = false;
                                            });
                                          });
                                        },
                                        backgroundColor: secondaryColor(1.0),
                                        foregroundColor: Colors.white,
                                        label:
                                            "${invoice.status == 0 ? "Not Paid" : "Paid"}",
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 10,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            color: invoice.status == 0
                                                ? Colors.green
                                                : Colors.red),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          Icons.person,
                                                          size: 22,
                                                        ),
                                                        SizedBox(
                                                          width: 4,
                                                        ),
                                                        Text(
                                                          "${invoice.customerName}",
                                                          style: TextStyle(
                                                              fontSize: 16,
                                                              color: Colors
                                                                  .black87,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: 6,
                                                    ),
                                                    Row(
                                                      children: [
                                                        itemData(Icons.title,
                                                            "${invoice.amounts![0].title}"),
                                                        itemData(
                                                            Icons.phone,
                                                            "${invoice.customerPhone}"),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 4.0),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      "${invoice.id.toString()}",
                                                      style: TextStyle(
                                                          color:
                                                              primaryColor(1.0),
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    SizedBox(
                                                      height: 4,
                                                    ),
                                                    Text(
                                                      "${invoice.addedDate.toString().split(" ")[0]}",
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                          color: Colors.black87,
                                                          fontSize: 12),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
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
        });
  }

  Widget itemData(IconData icon, String data) {
    return Expanded(
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: Colors.grey[700],
          ),
          SizedBox(
            width: 4,
          ),
          Expanded(
            child: Text(
              "$data",
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _addInvoice() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => AddInvoiceGen()));
  }
}
