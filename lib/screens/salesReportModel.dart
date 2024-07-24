import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:pdf/pdf.dart' as po;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:tv_repair/constants/constatns.dart';
import 'package:tv_repair/constants/helper_functions.dart';
import 'package:tv_repair/firebase_functions/firebase_functions.dart';
import 'package:tv_repair/model/businessModel.dart';
import 'package:tv_repair/model/invoiceModel.dart';
import 'package:tv_repair/screens/tvModelList.dart';
import 'package:tv_repair/widgets/invoiceDetailItem.dart';
import 'package:tv_repair/widgets/textInputItem.dart';

class SalesReportModel extends StatefulWidget {
  const SalesReportModel({Key? key}) : super(key: key);

  @override
  _SalesReportModelState createState() => _SalesReportModelState();
}

class _SalesReportModelState extends State<SalesReportModel> {
  DateTime firstDate = DateTime.now();
  DateTime lastDate = DateTime.now();

  bool showLoading = true;

  Future<QuerySnapshot?>? invoicesFuture;
  List<InvoiceModel> invoices = [];
  double totalInvoices = 0.0;

  TextEditingController modelController = TextEditingController();

  List<TableRow> amountsTable = [];
  List<pw.TableRow> amountsTablePrint = [];

  Widget? printButton = SizedBox();

  getInvoices() async {
    setState(() {
      setState(() {
        showLoading = true;
      });
      invoicesFuture =
          FireBaseHelperFunctions().getAllInvoicesFuture(2).then((value) {
        setState(() {
          invoices = [];
          amountsTable = [];
          amountsTablePrint = [];
          totalInvoices = 0.0;
        });
        amountsTablePrint.add(
          pw.TableRow(
            decoration: pw.BoxDecoration(
                border: pw.TableBorder(
                    bottom: pw.BorderSide(),
                    top: pw.BorderSide.none,
                    left: pw.BorderSide.none,
                    right: pw.BorderSide.none)),
            children: [
              pw.Padding(
                  padding: pw.EdgeInsets.only(bottom: 10),
                  child: pw.Text(
                    "Num",
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                        color: po.PdfColor.fromHex('#090909'),
                        fontWeight: pw.FontWeight.bold),
                  )),
              pw.Text(
                "Model",
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                    color: po.PdfColor.fromHex('#090909'),
                    fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(
                "Problem",
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                    color: po.PdfColor.fromHex('#090909'),
                    fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(
                "Amount",
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                    color: po.PdfColor.fromHex('#090909'),
                    fontWeight: pw.FontWeight.bold),
              ),
            ],
          ),
        );
        amountsTable.add(
          TableRow(
            decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey[300]!))),
            children: [
              Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text(
                    "Num",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.black87, fontWeight: FontWeight.bold),
                  )),
              Text(
                "Model",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black87, fontWeight: FontWeight.bold),
              ),
              Text(
                "Problem",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black87, fontWeight: FontWeight.bold),
              ),
              Text(
                "Amount",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black87, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
        int counter = 0;
        for (int i = 0; i < value.docs.length; i++) {
          InvoiceModel invoice = InvoiceModel.fromJson(value.docs[i]);
          if (invoice.addedDate!.isAfter(firstDate) &&
              invoice.addedDate!.isBefore(lastDate)) {
            for (int j = 0; j < invoice.amounts!.length; j++) {
              if (invoice.amounts![j].model!
                  .toLowerCase()
                  .contains(modelController.text.toLowerCase())) {
                setState(() {
                  counter++;
                  amountsTablePrint.add(pw.TableRow(children: [
                    pw.Padding(
                        padding: pw.EdgeInsets.only(bottom: 10, top: 10),
                        child: pw.Text(
                          "$counter",
                          textAlign: pw.TextAlign.center,
                        )),
                    pw.Padding(
                        padding: pw.EdgeInsets.only(bottom: 10, top: 10),
                        child: pw.Text(
                          "${invoice.amounts![j].model}",
                          textAlign: pw.TextAlign.center,
                        )),
                    pw.Padding(
                        padding: pw.EdgeInsets.only(bottom: 10, top: 10),
                        child: pw.Text(
                          "${invoice.amounts![j].problem}",
                          textAlign: pw.TextAlign.center,
                        )),
                    pw.Padding(
                        padding: pw.EdgeInsets.only(bottom: 10, top: 10),
                        child: pw.Text(
                          "${formatter.format(invoice.amounts![j].amountMoney)} IQD",
                          textAlign: pw.TextAlign.center,
                        )),
                  ]));
                  amountsTable.add(TableRow(children: [
                    Padding(
                        padding: EdgeInsets.only(bottom: 10, top: 10),
                        child: Text(
                          "$counter",
                          textAlign: TextAlign.center,
                        )),
                    Padding(
                      padding: EdgeInsets.only(bottom: 10, top: 10),
                      child: Text(
                        "${invoice.amounts![j].model}",
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 10, top: 10),
                      child: Text(
                        "${invoice.amounts![j].problem}",
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 10, top: 10),
                      child: Text(
                        "${formatter.format(invoice.amounts![j].amountMoney)} IQD",
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ]));
                  totalInvoices += invoice.amounts![j].amountMoney!;
                });
              }
            }
            setState(() {
              printButton = IconButton(
                  onPressed: () async {
                    setState(() {
                      showLoading = true;
                    });
                    BusinessModel? business;
                    await FireBaseHelperFunctions()
                        .getAllBusinessFuture()
                        .then((value) {
                      if (value.docs.isNotEmpty) {
                        setState(() {
                          business = BusinessModel.fromJson(value.docs[0]);
                          setState(() {
                            showLoading = false;
                          });
                        });
                      }
                    });
                    _printDocument(business, amountsTablePrint);
                  },
                  icon: Icon(Icons.print));
            });
          }
        }
        setState(() {
          showLoading = false;
        });
        return value;
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    firstDate = DateTime(lastDate.year, lastDate.month - 1, lastDate.day);
    getInvoices();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Sales Report Model"),
          actions: [showLoading ? SizedBox() : printButton!],
        ),
        floatingActionButton: getReportButton(),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          showDatePicker(
                                  context: context,
                                  initialDate: lastDate,
                                  firstDate: DateTime(1998),
                                  lastDate:
                                      DateTime.now().add(Duration(days: 70000)))
                              .then((value) {
                            if (value != null) {
                              if (value.isAfter(lastDate)) {
                                ScaffoldMessenger.of(this.context)
                                    .showSnackBar(SnackBar(
                                  content: Text(
                                      "First date must be less than last date",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  backgroundColor: Colors.red,
                                ));
                              } else {
                                setState(() {
                                  firstDate = value;
                                });
                              }
                            }
                          });
                        },
                        child: ListTile(
                          title: Text(
                            "First Date",
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            firstDate.toString().split(" ")[0],
                            style: TextStyle(
                              color: Colors.black87,
                            ),
                          ),
                          trailing: Icon(
                            Icons.date_range,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          showDatePicker(
                                  context: context,
                                  initialDate: lastDate,
                                  firstDate: DateTime(1998),
                                  lastDate:
                                      DateTime.now().add(Duration(days: 70000)))
                              .then((value) {
                            if (value != null) {
                              if (value.isBefore(firstDate)) {
                                ScaffoldMessenger.of(this.context)
                                    .showSnackBar(SnackBar(
                                  content: Text(
                                      "Last date must be grater than first date",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  backgroundColor: Colors.red,
                                ));
                              } else {
                                setState(() {
                                  lastDate = value;
                                });
                              }
                            }
                          });
                        },
                        child: ListTile(
                          title: Text(
                            "Last Date",
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            lastDate.toString().split(" ")[0],
                            style: TextStyle(
                              color: Colors.black87,
                            ),
                          ),
                          trailing: Icon(
                            Icons.date_range,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Stack(
                    children: [
                      TextInputItem(
                        title: "Model",
                        hint: "enter model name",
                        controller: modelController,
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Row(
                          children: [
                            IconButton(
                                onPressed: () async {
                                  var result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => TVModelList()));
                                  if (result != null) {
                                    setState(() {
                                      modelController.text =
                                          result.name.toString();
                                    });
                                  }
                                },
                                icon: Icon(
                                  Icons.import_contacts,
                                  color: secondaryColor(1.0),
                                )),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              if (!showLoading)
                Column(
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Report Information:",
                              style: TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16),
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            InvoiceDetailItem(
                              title: "Total Amount",
                              rowLayout: true,
                              data: "${formatter.format(totalInvoices)} IQD",
                            ),
                            InvoiceDetailItem(
                              title: "Models Number",
                              rowLayout: true,
                              data: "${amountsTable.length - 1}",
                            ),
                          ],
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
                            Text(
                              "Items:",
                              style: TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Table(
                              columnWidths: {0: FractionColumnWidth(.12)},
                              children: amountsTable,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 80,
                    )
                  ],
                )
              else
                Column(
                  children: [
                    SizedBox(
                      height: 50,
                    ),
                    SizedBox(
                      child: Lottie.asset("assets/loading.json",
                          width: 150, height: 150),
                    ),
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }

  Widget getReportButton() {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        getInvoices();
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: secondaryColor(1.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "Get Report",
            style: TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }

  void _printDocument(BusinessModel? business, amountsTablePrint) async {
    Printing.layoutPdf(
      onLayout: (pageFormat) async {
        final doc = pw.Document(deflate: zlib.encode);
        var sig1;
        if (business != null) {
          var imageProvider = NetworkImage('${business.logo}');
          sig1 = await flutterImageProvider(imageProvider);
        }
        doc.addPage(
          pw.MultiPage(
              pageTheme: pw.PageTheme(theme: pw.ThemeData()),
              maxPages: 500,
              footer: (context) => pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        business == null
                            ? pw.SizedBox()
                            : pw.Text("${business.footer}",
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    color: po.PdfColor.fromHex('#090909'))),
                        pw.SizedBox(height: 20),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            business == null
                                ? pw.SizedBox()
                                : pw.Column(
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Text("Address: ",
                                          style: pw.TextStyle(
                                              fontWeight: pw.FontWeight.bold)),
                                      pw.Text("${business.address}",
                                          style: pw.TextStyle(
                                              fontWeight: pw.FontWeight.bold,
                                              color: po.PdfColor.fromHex(
                                                  '#090909'))),
                                    ],
                                  ),
                          ],
                        ),
                      ]),
              build: (pw.Context context) => [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              business == null
                                  ? pw.SizedBox()
                                  : pw.Column(
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.start,
                                      children: [
                                          pw.Container(
                                            child: pw.Image(sig1,
                                                fit: pw.BoxFit.cover,
                                                height: 50,
                                                width: 70),
                                          ),
                                          pw.SizedBox(
                                            height: 4,
                                          ),
                                          pw.Text("${business.title}",
                                              style: pw.TextStyle(
                                                  fontWeight:
                                                      pw.FontWeight.bold,
                                                  fontSize: 16,
                                                  color: po.PdfColor.fromHex(
                                                      '#090909'))),
                                        ]),
                            ]),
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              "Report Information:",
                              style: pw.TextStyle(
                                  color: po.PdfColor.fromHex('#090909'),
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 16),
                            ),
                            pw.Row(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text(
                                    "Total Amount: ",
                                    style: pw.TextStyle(
                                      color: po.PdfColor.fromHex('#090909'),
                                      fontSize: 14,
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                  pw.Text(
                                    "${formatter.format(totalInvoices)} IQD",
                                    style: pw.TextStyle(
                                      color: po.PdfColor.fromHex('#090909'),
                                      fontSize: 14,
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                ]),
                            pw.Row(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text(
                                    "Models Number: ",
                                    style: pw.TextStyle(
                                      color: po.PdfColor.fromHex('#090909'),
                                      fontSize: 14,
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                  pw.Text(
                                    "${amountsTablePrint.length - 1}",
                                    style: pw.TextStyle(
                                      color: po.PdfColor.fromHex('#090909'),
                                      fontSize: 14,
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                ]),
                            pw.Row(children: [
                              pw.Text("Date: ",
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold)),
                              pw.Text(
                                  "${firstDate.toString().split(" ")[0]} - ${lastDate.toString().split(" ")[0]}",
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      color: po.PdfColor.fromHex('#090909'))),
                            ]),
                          ],
                        ),
                      ],
                    ),
                    pw.Divider(),
                    pw.Text(
                      "Items:",
                      style: pw.TextStyle(
                          color: po.PdfColor.fromHex('#090909'),
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 16),
                    ),
                    pw.SizedBox(
                      height: 10,
                    ),
                    pw.Table(
                      columnWidths: {0: pw.FractionColumnWidth(.12)},
                      children: amountsTablePrint,
                    ),
                  ]),
        );
        return doc.save();
      },
    );
  }
}
