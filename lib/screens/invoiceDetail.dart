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
import 'package:tv_repair/model/invoiceModel.dart';
import 'package:tv_repair/screens/addInvoice.dart';
import 'package:tv_repair/widgets/invoiceDetailItem.dart';
import 'package:tv_repair/widgets/textInputItem.dart';

class InvoiceDetail extends StatefulWidget {
  const InvoiceDetail({Key? key, this.invoice}) : super(key: key);
  final InvoiceModel? invoice;

  @override
  _InvoiceDetailState createState() => _InvoiceDetailState(this.invoice);
}

class _InvoiceDetailState extends State<InvoiceDetail> {
  final InvoiceModel? invoice;

  _InvoiceDetailState(this.invoice);

  final oCcy = new NumberFormat("#,##0.00", "en_US");

  TextEditingController repairNoteController = TextEditingController();

  List<ItemAmount> amounts = [];
  List<ItemAmountControllers> itemAmountControllers = [];

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
    if (invoice!.status == 2) {
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
                "${invoice!.amounts![i].model}",
                textAlign: pw.TextAlign.center,
              )),
          pw.Padding(
              padding: pw.EdgeInsets.only(bottom: 10, top: 10),
              child: pw.Text(
                "${invoice!.amounts![i].problem}",
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
              "Model",
              textAlign: TextAlign.center,
              style:
                  TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
            ),
            Text(
              "Problem",
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
        totalAmount +=
            double.parse(invoice!.amounts![i].amountMoney.toString());
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
              "${invoice!.amounts![i].model}",
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 10, top: 10),
            child: Text(
              "${invoice!.amounts![i].problem}",
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
                invoice!.status == 2
                    ? IconButton(
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
                                business =
                                    BusinessModel.fromJson(value.docs[0]);
                                setState(() {
                                  showLoading = false;
                                });
                              });
                            }
                          });
                          _printDocument(business!);
                        },
                        icon: Icon(Icons.print))
                    : SizedBox(),
                IconButton(
                    onPressed: () async {
                      var result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AddInvoice(
                                    invoice: invoice,
                                    editMode: true,
                                  )));
                      if (result == true) {
                        Navigator.pop(context);
                      }
                    },
                    icon: Icon(Icons.edit)),
                invoice!.status == 0
                    ? IconButton(
                        onPressed: () {
                          areYouSure(context, () {
                            this.setState(() {
                              showLoading = true;
                            });
                            FireBaseHelperFunctions()
                                .deleteInvoice(invoice!)
                                .then((value) {
                              this.setState(() {
                                showLoading = false;
                                Navigator.pop(this.context);
                              });
                            });
                          }, title: "Are sure to delete this invoice?");
                        },
                        icon: Icon(Icons.delete))
                    : SizedBox()
              ],
            ),
            floatingActionButton: invoice!.status == 2 || invoice!.status == 3
                ? paidButton()
                : invoice!.status != 2
                    ? repairButton()
                    : null,
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
                          Visibility(
                            visible: invoice!.repairNote != null &&
                                invoice!.repairNote != "",
                            child: InvoiceDetailItem(
                              title: "Repair Note",
                              data: invoice!.repairNote,
                            ),
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
                  Visibility(
                    visible: invoice!.status != 2,
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Device Information:",
                              style: TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16),
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: invoice!.amounts!.length,
                                itemBuilder: (context, index) {
                                  return Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            InvoiceDetailItem(
                                              title: "Model",
                                              data: invoice!
                                                  .amounts![index].model,
                                            ),
                                            InvoiceDetailItem(
                                              title: "Problem",
                                              data: invoice!
                                                  .amounts![index].problem,
                                            ),
                                            Visibility(
                                                visible: index !=
                                                    invoice!.amounts!.length -
                                                        1,
                                                child: Divider(
                                                  thickness: 1,
                                                ))
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12.0),
                                        child: Text(
                                          "${index + 1}",
                                          style: TextStyle(
                                              color: primaryColor(1.0),
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: invoice!.status == 2,
                    child: Card(
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

  Widget repairButton() {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        this.setState(() {
          repairNoteController.text = "";
          amounts = invoice!.amounts!;
          for (int i = 0; i < invoice!.amounts!.length; i++) {
            itemAmountControllers.add(ItemAmountControllers(
                modelController:
                    TextEditingController(text: invoice!.amounts![i].model),
                amountMoneyController: TextEditingController(
                    text: invoice!.amounts![i].amountMoney.toString()),
                problemController:
                    TextEditingController(text: invoice!.amounts![i].problem)));
          }
        });
        showDialog(
            context: context,
            builder: (context) {
              return StatefulBuilder(
                builder: (context, setState) => AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  title: invoice!.status == 0
                      ? Text("Are you sure to submit as repair?")
                      : Text("Are you sure to out this invoice?"),
                  content: invoice!.status == 0
                      ? Form(
                          key: _formKey,
                          // autovalidate: _autoValidate,
                          child: TextInputItem(
                            title: "Note",
                            hint: "write repair note",
                            controller: repairNoteController,
                          ),
                        )
                      : Form(
                          key: _formKey,
                          // autovalidate: _autoValidate,
                          child: SingleChildScrollView(
                            child: Column(
                              children: List.generate(amounts.length, (index) {
                                return Column(
                                  children: [
                                    TextInputItem(
                                      title: "Model",
                                      hint: "enter model name",
                                      enabled: false,
                                      controller: itemAmountControllers[index]
                                          .modelController,
                                    ),
                                    TextInputItem(
                                      title: "Problem",
                                      hint: "enter the problem",
                                      controller: itemAmountControllers[index]
                                          .problemController,
                                      enabled: false,
                                    ),
                                    TextInputItem(
                                      title: "Amount",
                                      hint: "write amount of money",
                                      controller: itemAmountControllers[index]
                                          .amountMoneyController,
                                      keyboardType: TextInputType.number,
                                      onChange: (v) {
                                        this.setState(() {
                                          setState(() {
                                            amounts[index].amountMoney =
                                                double.parse(v!);
                                          });
                                        });
                                      },
                                    ),
                                    Visibility(
                                        visible: index != amounts.length - 1,
                                        child: Divider(
                                          thickness: 1,
                                        )),
                                  ],
                                );
                              }),
                            ),
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
                          this.setState(() {
                            _autoValidate = true;
                          });
                          if (_formKey.currentState!.validate()) {
                            Navigator.pop(context);
                            this.setState(() {
                              showLoading = true;
                            });
                            InvoiceModel updateInvoice = invoice!;
                            if (invoice!.status == 0) {
                              updateInvoice.status = 1;
                              updateInvoice.repairNote =
                                  repairNoteController.text;
                              FireBaseHelperFunctions()
                                  .updateInvoice(updateInvoice)
                                  .then((value) {
                                this.setState(() {
                                  showLoading = false;
                                  Navigator.pop(this.context);
                                });
                              });
                            } else if (invoice!.status == 1) {
                              updateInvoice.status = 2;
                              updateInvoice.amounts = amounts;
                              FireBaseHelperFunctions()
                                  .updateInvoice(updateInvoice)
                                  .then((value) {
                                this.setState(() {
                                  showLoading = false;
                                  Navigator.pop(this.context);
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
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: secondaryColor(1.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            invoice!.status == 0 ? "Repair" : "Out",
            style: TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
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
        InvoiceModel updateInvoice = invoice!;
        if (invoice!.status == 2) {
          updateInvoice.status = 3;
        } else if (invoice!.status == 3) {
          updateInvoice.status = 2;
        }
        FireBaseHelperFunctions().updateInvoice(updateInvoice).then((value) {
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
            "${invoice!.status == 2 ? "Make Unpaid" : "Make Paid"}",
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
