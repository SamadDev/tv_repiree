import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tv_repair/constants/constatns.dart';
import 'package:tv_repair/constants/helper_functions.dart';
import 'package:tv_repair/firebase_functions/firebase_functions.dart';
import 'package:tv_repair/model/businessModel.dart';
import 'package:tv_repair/widgets/loader.dart';
import 'package:tv_repair/widgets/textInputItem.dart';

class AddBusiness extends StatefulWidget {
  const AddBusiness({Key? key, this.business, this.editMode = false})
      : super(key: key);
  final BusinessModel? business;
  final bool editMode;

  @override
  _AddBusinessState createState() => _AddBusinessState(this.business);
}

class _AddBusinessState extends State<AddBusiness> {
  TextEditingController titleController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController footerController = TextEditingController();

  final BusinessModel? business;
  XFile? businessLogo;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  bool showLoading = false;

  _AddBusinessState(this.business);

  @override
  void initState() {
    super.initState();
    if (widget.editMode == true) {
      setState(() {
        titleController.text = business!.title!;
        addressController.text = business!.address!;
        footerController.text = business!.footer!;
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
              title: Text(widget.editMode ? "Update Business" : "New Business"),
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
                            Text(
                              "Business Information:",
                              style: TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16),
                            ),
                            TextInputItem(
                              title: "Title",
                              hint: "enter business title",
                              controller: titleController,
                            ),
                            TextInputItem(
                              title: "Address",
                              hint: "enter business address",
                              controller: addressController,
                              keyboardType: TextInputType.number,
                            ),
                            TextInputItem(
                              title: "Footer",
                              hint: "enter business footer",
                              controller: footerController,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              children: [
                                Text(
                                  "Logo:",
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Spacer(),
                                businessLogo == null
                                    ? FloatingActionButton(
                                        onPressed: _selectPhoto,
                                        heroTag: "businessLogo",
                                        backgroundColor: Colors.white,
                                        child: Icon(
                                          Icons.add,
                                          color: secondaryColor(1.0),
                                        ),
                                      )
                                    : Stack(
                                        children: [
                                          Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  .7,
                                              child: Image.file(
                                                File(businessLogo!.path),
                                                fit: BoxFit.contain,
                                              )),
                                          Positioned(
                                            top: 10,
                                            right: 10,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.white),
                                              child: IconButton(
                                                  onPressed: _selectPhoto,
                                                  icon: Icon(
                                                    Icons.edit,
                                                    color: secondaryColor(1.0),
                                                  )),
                                            ),
                                          )
                                        ],
                                      ),
                                Spacer(),
                              ],
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
          Loader(showLoading: showLoading),
        ],
      ),
    );
  }

  _selectPhoto() {
    final ImagePicker _picker = ImagePicker();
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      XFile? image =
                          await _picker.pickImage(source: ImageSource.gallery);
                      if (image != null) {
                        setState(() {
                          businessLogo = image;
                        });
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image,
                          color: secondaryColor(1.0),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "From Gallery",
                          style: TextStyle(
                            color: secondaryColor(1.0),
                          ),
                        ),
                      ],
                    )),
                Divider(),
                TextButton(
                    onPressed: () async {
                      XFile? photo =
                          await _picker.pickImage(source: ImageSource.camera);
                      if (photo != null) {
                        setState(() {
                          businessLogo = photo;
                        });
                      }
                      Navigator.pop(context);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.camera_alt_rounded,
                          color: secondaryColor(1.0),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text("From Camera",
                            style: TextStyle(color: secondaryColor(1.0))),
                      ],
                    ))
              ],
            ),
          );
        });
  }

  Widget submitButton() {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        setState(() {
          _autoValidate = true;
        });
        if (_formKey.currentState!.validate() &&
            (businessLogo != null || widget.editMode)) {
          areYouSure(context, () {
            setState(() {
              showLoading = true;
            });
            if (widget.editMode == true) {
              BusinessModel business = BusinessModel(
                  title: titleController.text,
                  address: addressController.text,
                  footer: footerController.text,
                  addedDate: this.business!.addedDate,
                  logo: this.business!.logo);
              FireBaseHelperFunctions()
                  .updateBusiness(business, businessLogo)
                  .then((value) {
                setState(() {
                  showLoading = false;
                  Navigator.pop(this.context, true);
                });
              });
            } else {
              BusinessModel business = BusinessModel(
                  title: titleController.text,
                  address: addressController.text,
                  footer: footerController.text,
                  addedDate: DateTime.now());
              FireBaseHelperFunctions()
                  .addNewBusiness(business, businessLogo)
                  .then((value) {
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
        if (businessLogo == null && !widget.editMode) {
          ScaffoldMessenger.of(this.context).showSnackBar(SnackBar(
            content: Text("Please select logo image",
                style: TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: Colors.red,
          ));
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
