import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart' as po;
import 'package:printing/printing.dart';
import 'package:tv_repair/constants/constatns.dart';
import 'package:tv_repair/constants/helper_functions.dart';
import 'package:tv_repair/firebase_functions/firebase_functions.dart';
import 'package:tv_repair/model/businessModel.dart';
import 'package:tv_repair/model/invoiceGenModel.dart';
import 'package:tv_repair/model/invoiceModel.dart';
import 'package:tv_repair/screens/addInvoice.dart';
import 'package:tv_repair/screens/addInvoiceGen.dart';
import 'package:tv_repair/widgets/invoiceDetailItem.dart';
import 'package:tv_repair/widgets/textInputItem.dart';

class InvoiceGenDetail extends StatefulWidget {
  const InvoiceGenDetail({Key? key, this.invoice}) : super(key: key);
  final InvoiceGenModel? invoice;

  @override
  _InvoiceGenDetailState createState() => _InvoiceGenDetailState(this.invoice);
}

class _InvoiceGenDetailState extends State<InvoiceGenDetail> {
  final InvoiceGenModel? invoice;

  _InvoiceGenDetailState(this.invoice);

  final oCcy = new NumberFormat("#,##0.00", "en_US");

  List<ItemAmountGen> amounts = [];
  List<ItemAmountGenControllers> itemAmountControllers = [];

  double totalAmount = 0.0;
  List<TableRow> amountsTable = [];
  List<pw.TableRow> amountsTablePrint = [];

  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  bool showLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

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
            "Title",
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

    for (int i = 0; i < invoice!.amounts!.length; i++) {
      amountsTablePrint.add(pw.TableRow(children: [
        pw.Padding(
            padding: pw.EdgeInsets.only(bottom: 10, top: 10),
            child: pw.Text(
              "${i + 1}",
              textAlign: pw.TextAlign.center,
            )),
        pw.Padding(
            padding: pw.EdgeInsets.only(bottom: 10, top: 10),
            child: pw.Text(
              "${invoice!.amounts![i].title}",
              textAlign: pw.TextAlign.center,
            )),
        pw.Padding(
            padding: pw.EdgeInsets.only(bottom: 10, top: 10),
            child: pw.Text(
              "${formatter.format(invoice!.amounts![i].amountMoney)} IQD",
              textAlign: pw.TextAlign.center,
            )),
      ]));
    }
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
            "Title",
            textAlign: TextAlign.center,
            style:
                TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
          ),
          Text(
            "Amount",
            textAlign: TextAlign.center,
            style:
                TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
    for (int i = 0; i < invoice!.amounts!.length; i++) {
      totalAmount += double.parse(invoice!.amounts![i].amountMoney.toString());
      amountsTable.add(TableRow(children: [
        Padding(
            padding: EdgeInsets.only(bottom: 10, top: 10),
            child: Text(
              "${i + 1}",
              textAlign: TextAlign.center,
            )),
        Padding(
          padding: EdgeInsets.only(bottom: 10, top: 10),
          child: Text(
            "${invoice!.amounts![i].title}",
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 10, top: 10),
          child: Text(
            "${formatter.format(invoice!.amounts![i].amountMoney)} IQD",
            textAlign: TextAlign.center,
          ),
        ),
      ]));
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
              title: Text("Invoice Detail"),
              actions: [
                IconButton(
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
                      _printDocument(business!);
                    },
                    icon: Icon(Icons.print)),
                IconButton(
                    onPressed: () async {
                      var result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AddInvoiceGen(
                                    invoice: invoice,
                                    editMode: true,
                                  )));
                      if (result == true) {
                        Navigator.pop(context);
                      }
                    },
                    icon: Icon(Icons.edit)),
                IconButton(
                    onPressed: () {
                      areYouSure(context, () {
                        this.setState(() {
                          showLoading = true;
                        });
                        FireBaseHelperFunctions()
                            .deleteInvoiceGen(invoice!)
                            .then((value) {
                          this.setState(() {
                            showLoading = false;
                            Navigator.pop(this.context);
                          });
                        });
                      }, title: "Are sure to delete this invoice?");
                    },
                    icon: Icon(Icons.delete))
              ],
            ),
            floatingActionButton: paidButton(),
            body: Padding(
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
                          Text(
                            "Invoice Information:",
                            style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w700,
                                fontSize: 16),
                          ),
                          SizedBox(
                            height: 6,
                          ),
                          InvoiceDetailItem(
                            title: "Invoice Number",
                            data: invoice!.id.toString(),
                          ),
                          InvoiceDetailItem(
                            title: "Added Date",
                            data: invoice!.addedDate.toString(),
                          ),
                          InvoiceDetailItem(
                            title: "Status",
                            data: invoice!.status == 0
                                ? "Pending"
                                : invoice!.status == 1
                                    ? "Repair"
                                    : "Paid",
                          ),
                          InvoiceDetailItem(
                            title: "Added By",
                            data: invoice!.userName,
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
                            "Customer Information:",
                            style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w700,
                                fontSize: 16),
                          ),
                          SizedBox(
                            height: 6,
                          ),
                          InvoiceDetailItem(
                            title: "Name",
                            data: invoice!.customerName,
                          ),
                          Row(
                            children: [
                              InvoiceDetailItem(
                                title: "Phone",
                                data: invoice!.customerPhone,
                              ),
                              Spacer(),
                              SizedBox(
                                width: 45,
                                height: 45,
                                child: FloatingActionButton(
                                    onPressed: () {
                                      launchTelephoneURL(
                                          "${invoice!.customerPhone}");
                                    },
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    child: Icon(
                                      Icons.call,
                                      size: 25,
                                    )),
                              )
                            ],
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
                            "Items Information:",
                            style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w700,
                                fontSize: 16),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Table(
                            columnWidths: {0: FractionColumnWidth(.12)},
                            children: amountsTable,
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Center(
                            child: Text(
                              "Total: ${formatter.format(totalAmount)} IQD",
                              style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
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

  Widget paidButton() {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        setState(() {
          showLoading = true;
        });
        InvoiceGenModel updateInvoice = invoice!;
        if (invoice!.status == 0) {
          updateInvoice.status = 1;
        } else if (invoice!.status == 1) {
          updateInvoice.status = 0;
        }
        FireBaseHelperFunctions().updateInvoiceGen(updateInvoice).then((value) {
          this.setState(() {
            showLoading = false;
          });
          Navigator.pop(this.context);
        });
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: secondaryColor(1.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "${invoice!.status == 0 ? "Make Unpaid" : "Make Paid"}",
            style: TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }

  void _printDocument(BusinessModel? business) async {
    Printing.layoutPdf(
      onLayout: (pageFormat) async {
        final doc = pw.Document(deflate: zlib.encode);

        var sig1;
        if (business != null) {
          var imageProvider = NetworkImage('${business.logo}');
          sig1 = await flutterImageProvider(imageProvider);
        }

        doc.addPage(
          pw.Page(
            pageTheme: pw.PageTheme(theme: pw.ThemeData()),
            build: (pw.Context context) => pw.Center(
              child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
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
                              pw.Text("Invoice",
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 22,
                                      color: po.PdfColor.fromHex('#090909'))),
                              pw.Row(children: [
                                pw.Text("Invoice No: ",
                                    style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold)),
                                pw.Text("${invoice!.id}",
                                    style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold,
                                        color: po.PdfColor.fromHex('#090909'))),
                              ]),
                              pw.Row(children: [
                                pw.Text("Date: ",
                                    style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold)),
                                pw.Text(
                                    "${invoice!.addedDate.toString().split(".")[0]}",
                                    style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold,
                                        color: po.PdfColor.fromHex('#090909'))),
                              ]),
                            ]),
                      ],
                    ),
                    pw.Divider(),
                    pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Row(children: [
                                  pw.Text("Customer Name: ",
                                      style: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold)),
                                  pw.Text("${invoice!.customerName}",
                                      style: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold,
                                          color:
                                              po.PdfColor.fromHex('#090909'))),
                                ]),
                                pw.Row(children: [
                                  pw.Text("Customer Phone: ",
                                      style: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold)),
                                  pw.Text("${invoice!.customerPhone}",
                                      style: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold,
                                          color:
                                              po.PdfColor.fromHex('#090909'))),
                                ]),
                                pw.SizedBox(
                                  height: 10,
                                ),
                                pw.Text("Items Information: ",
                                    style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold)),
                              ]),
                        ]),
                    pw.SizedBox(
                      height: 10,
                    ),
                    pw.Table(
                      border: pw.TableBorder(),
                      columnWidths: {1: pw.FractionColumnWidth(.12)},
                      children: amountsTablePrint,
                    ),
                    pw.SizedBox(
                      height: 30,
                    ),
                    pw.Center(
                      child: pw.Text(
                          "Total: ${formatter.format(totalAmount)} IQD",
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              color: po.PdfColor.fromHex('#090909'))),
                    ),
                    pw.Spacer(),
                    pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          business == null
                              ? pw.SizedBox()
                              : pw.Text("${business.footer}",
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      color: po.PdfColor.fromHex('#090909'))),
                          pw.SizedBox(height: 20),
                          pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [
                              business == null
                                  ? pw.SizedBox()
                                  : pw.Column(
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.start,
                                      children: [
                                        pw.Text("Address: ",
                                            style: pw.TextStyle(
                                                fontWeight:
                                                    pw.FontWeight.bold)),
                                        pw.Text("${business.address}",
                                            style: pw.TextStyle(
                                                fontWeight: pw.FontWeight.bold,
                                                color: po.PdfColor.fromHex(
                                                    '#090909'))),
                                      ],
                                    ),
                              pw.SizedBox(),
                              pw.Column(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text("Date: ",
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold)),
                                    pw.Text(
                                        "${invoice!.addedDate.toString().split(".")[0]}",
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            color: po.PdfColor.fromHex(
                                                '#090909'))),
                                  ]),
                            ],
                          ),
                        ]),
                  ]),
            ),
          ),
        );
        return doc.save();
      },
    );
  }
}
