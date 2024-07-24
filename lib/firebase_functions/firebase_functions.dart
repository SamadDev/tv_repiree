import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tv_repair/constants/constatns.dart';
import 'dart:io';
import 'package:tv_repair/constants/helper_functions.dart';
import 'package:tv_repair/model/businessModel.dart';
import 'package:tv_repair/model/customerModel.dart';
import 'package:tv_repair/model/invoiceGenModel.dart';
import 'package:tv_repair/model/invoiceModel.dart';
import 'package:tv_repair/model/tvModel.dart';
import 'package:tv_repair/model/userModel.dart';

class FireBaseHelperFunctions {
  Query customerCollection = FirebaseFirestore.instance.collection('Customer');
  Query invoiceCollection = FirebaseFirestore.instance.collection('Invoice');
  Query invoiceGenCollection = FirebaseFirestore.instance.collection('InvoiceGen');
  Query modelCollection = FirebaseFirestore.instance.collection('Model');
  Query userCollection = FirebaseFirestore.instance.collection('User');
  Query businessCollection = FirebaseFirestore.instance.collection('Business');
  Query lastInvoiceCollection =
      FirebaseFirestore.instance.collection('LastInvoice');
  Query lastInvoiceGenCollection =
  FirebaseFirestore.instance.collection('LastInvoiceGen');

  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseStorage _storage = FirebaseStorage.instance;

  //get all collections

  // Stream<QuerySnapshot> getAllUsers() {
  //   var querySnapshot = usersCollection
  //       .where("email", isNotEqualTo: _auth.currentUser.email)
  //       .snapshots();
  //   return querySnapshot;
  // }

  Stream<QuerySnapshot> getAllInvoices(int status) {
    var querySnapshot = invoiceCollection
        .where("status", isEqualTo: status)
        .orderBy("addedDate", descending: true)
        .snapshots();
    return querySnapshot;
  }

  Future<QuerySnapshot> getAllInvoicesFuture(int status) {
    var querySnapshot = invoiceCollection
        .where("status", isEqualTo: status)
        .orderBy("addedDate", descending: true)
        .get();
    return querySnapshot;
  }

  Stream<QuerySnapshot> getAllInvoicesGen(int status) {

    var querySnapshot = invoiceGenCollection
        .where("status", isEqualTo: status)
        .orderBy("addedDate", descending: true)
        .snapshots();
    return querySnapshot;
  }

  Future<QuerySnapshot> getAllInvoicesGenFuture(int status) {
    var querySnapshot = invoiceGenCollection
        .where("status", isEqualTo: status)
        .orderBy("addedDate", descending: true)
        .get();
    return querySnapshot;
  }

  Stream<QuerySnapshot> getAllUsers() {
    var querySnapshot = userCollection
        .where("type", isEqualTo: 1)
        .orderBy("addedDate", descending: true)
        .snapshots();
    return querySnapshot;
  }

  Stream<QuerySnapshot> getAllCustomers() {
    var querySnapshot =
        customerCollection.orderBy("addedDate", descending: true).snapshots();
    return querySnapshot;
  }

  Stream<QuerySnapshot> getAllBusiness() {
    var querySnapshot =
        businessCollection.orderBy("addedDate", descending: true).snapshots();
    return querySnapshot;
  }

  Future<QuerySnapshot> getAllBusinessFuture() {
    var querySnapshot =
        businessCollection.orderBy("addedDate", descending: true).get();
    return querySnapshot;
  }

  Stream<QuerySnapshot> getAllModel() {
    var querySnapshot =
        modelCollection.orderBy("addedDate", descending: true).snapshots();
    return querySnapshot;
  }

  Future<QuerySnapshot> getUserByIDFuture(String name) async {
    var querySnapshot = await userCollection
        .where("name", isEqualTo: "${name.replaceAll(new RegExp(r"\s+"), "")}")
        .get();
    return querySnapshot;
  }

  Future<QuerySnapshot> getUserByIDFuture2(double id) async {
    var querySnapshot = await userCollection.where("type", isEqualTo: id).get();
    return querySnapshot;
  }

  Future<QuerySnapshot> getLastInvoiceIDFuture() async {
    var querySnapshot = await lastInvoiceCollection.get();
    return querySnapshot;
  }

  Future updateLastInvoiceID(id) async {
    var querySnapshot = await getLastInvoiceIDFuture();
    var querySnapshotUpdate = await lastInvoiceCollection.firestore
        .collection("LastInvoice")
        .doc(querySnapshot.docs[0].id)
        .update({"id": id});
    return querySnapshotUpdate;
  }

  Future<QuerySnapshot> getLastInvoiceGenIDFuture() async {
    var querySnapshot = await lastInvoiceGenCollection.get();
    return querySnapshot;
  }

  Future updateLastInvoiceGenID(id) async {
    var querySnapshot = await getLastInvoiceGenIDFuture();
    var querySnapshotUpdate = await lastInvoiceGenCollection.firestore
        .collection("LastInvoiceGen")
        .doc(querySnapshot.docs[0].id)
        .update({"id": id});
    return querySnapshotUpdate;
  }

  Future addNewInvoice(InvoiceModel invoice) async {
    var inv = InvoiceModel().toJson(invoice);
    var querySnapshot =
        await invoiceCollection.firestore.collection("Invoice").doc().set(inv);
    return querySnapshot;
  }

  Future updateInvoice(InvoiceModel invoice) async {
    var inv = InvoiceModel().toJson(invoice);
    var querySnapshot = await invoiceCollection
        .where("addedDate", isEqualTo: Timestamp.fromDate(invoice.addedDate!))
        .get();
    var querySnapshotUpdate = await invoiceCollection.firestore
        .collection("Invoice")
        .doc(querySnapshot.docs[0].id)
        .update(inv);
    return querySnapshotUpdate;
  }

  Future deleteInvoice(InvoiceModel invoice) async {
    var querySnapshot = await invoiceCollection
        .where("addedDate", isEqualTo: Timestamp.fromDate(invoice.addedDate!))
        .get();
    var querySnapshotUpdate = await invoiceCollection.firestore
        .collection("Invoice")
        .doc(querySnapshot.docs[0].id)
        .delete();
    return querySnapshotUpdate;
  }

  ///Invoice Gen part
  Future addNewInvoiceGen(InvoiceGenModel invoice) async {
    var inv = InvoiceGenModel().toJson(invoice);
    var querySnapshot =
    await invoiceGenCollection.firestore.collection("InvoiceGen").doc().set(inv);
    return querySnapshot;
  }

  Future updateInvoiceGen(InvoiceGenModel invoice) async {
    var inv = InvoiceGenModel().toJson(invoice);
    var querySnapshot = await invoiceGenCollection
        .where("addedDate", isEqualTo: Timestamp.fromDate(invoice.addedDate!))
        .get();
    var querySnapshotUpdate = await invoiceGenCollection.firestore
        .collection("InvoiceGen")
        .doc(querySnapshot.docs[0].id)
        .update(inv);
    return querySnapshotUpdate;
  }

  Future deleteInvoiceGen(InvoiceGenModel invoice) async {
    var querySnapshot = await invoiceGenCollection
        .where("addedDate", isEqualTo: Timestamp.fromDate(invoice.addedDate!))
        .get();
    var querySnapshotUpdate = await invoiceGenCollection.firestore
        .collection("InvoiceGen")
        .doc(querySnapshot.docs[0].id)
        .delete();
    return querySnapshotUpdate;
  }

  ///End of Invoice Gen part

  Future addNewCustomer(CustomerModel customer) async {
    var cus = CustomerModel().toJson(customer);
    var querySnapshot = await customerCollection.firestore
        .collection("Customer")
        .doc()
        .set(cus);
    return querySnapshot;
  }

  Future updateCustomer(CustomerModel customer) async {
    var cus = CustomerModel().toJson(customer);
    var querySnapshot = await customerCollection
        .where("addedDate", isEqualTo: Timestamp.fromDate(customer.addedDate!))
        .get();
    var querySnapshotUpdate = await customerCollection.firestore
        .collection("Customer")
        .doc(querySnapshot.docs[0].id)
        .update(cus);
    return querySnapshotUpdate;
  }

  Future deleteCustomer(CustomerModel customer) async {
    var querySnapshot = await customerCollection
        .where("addedDate", isEqualTo: Timestamp.fromDate(customer.addedDate!))
        .get();
    var querySnapshotUpdate = await customerCollection.firestore
        .collection("Customer")
        .doc(querySnapshot.docs[0].id)
        .delete();
    return querySnapshotUpdate;
  }

  Future addNewModel(TVModel tvModel) async {
    var tv = TVModel().toJson(tvModel);
    var querySnapshot =
        await modelCollection.firestore.collection("Model").doc().set(tv);
    return querySnapshot;
  }

  Future updateModel(TVModel tvModel) async {
    var cus = TVModel().toJson(tvModel);
    var querySnapshot = await modelCollection
        .where("addedDate", isEqualTo: Timestamp.fromDate(tvModel.addedDate!))
        .get();
    var querySnapshotUpdate = await modelCollection.firestore
        .collection("Model")
        .doc(querySnapshot.docs[0].id)
        .update(cus);
    return querySnapshotUpdate;
  }

  Future deleteModel(TVModel tvModel) async {
    var querySnapshot = await modelCollection
        .where("addedDate", isEqualTo: Timestamp.fromDate(tvModel.addedDate!))
        .get();
    var querySnapshotUpdate = await modelCollection.firestore
        .collection("Model")
        .doc(querySnapshot.docs[0].id)
        .delete();
    return querySnapshotUpdate;
  }

  Future addNewBusiness(BusinessModel business, XFile? picture) async {
    var addedDate = business.addedDate;
    var cus = BusinessModel().toJson(business);
    var querySnapshot = await businessCollection.firestore
        .collection("Business")
        .doc()
        .set(cus);
    await addBusinessPictureFuture(picture, addedDate);
    return querySnapshot;
  }

  Future updateBusiness(BusinessModel business, XFile? picture) async {
    if (picture != null) {
      await deleteProfilePictureFuture(business.logo);
    }
    var addedDate = business.addedDate;
    var cus = BusinessModel().toJson(business);
    var querySnapshot = await businessCollection
        .where("addedDate", isEqualTo: Timestamp.fromDate(business.addedDate!))
        .get();
    var querySnapshotUpdate = await businessCollection.firestore
        .collection("Business")
        .doc(querySnapshot.docs[0].id)
        .update(cus);

    if (picture != null) {
      await addBusinessPictureFuture(picture, addedDate);
    }

    return querySnapshotUpdate;
  }

  Future deleteBusiness(BusinessModel business) async {
    await deleteProfilePictureFuture(business.logo);
    var querySnapshot = await businessCollection
        .where("addedDate", isEqualTo: Timestamp.fromDate(business.addedDate!))
        .get();
    var querySnapshotUpdate = await businessCollection.firestore
        .collection("Business")
        .doc(querySnapshot.docs[0].id)
        .delete();
    return querySnapshotUpdate;
  }

  Future addNewUser(UserModel user) async {
    FirebaseApp app = await Firebase.initializeApp(
        name: 'Secondary', options: Firebase.app().options);
    try {
      UserCredential userCredential = await FirebaseAuth.instanceFor(app: app)
          .createUserWithEmailAndPassword(
              email: user.name! + "@tvRepair.com",
              password: decode(user.password!));
      await app.delete();
    } on FirebaseException catch (e) {
      await app.delete();
      return e.code;
    }
    var cus = UserModel().toJson(user);
    var querySnapshot =
        await userCollection.firestore.collection("User").doc().set(cus);
    return querySnapshot;
  }

  Future updateUser(UserModel user, UserModel userPrev) async {
    var cus = UserModel().toJson(user);
    var querySnapshot = await userCollection
        .where("addedDate", isEqualTo: Timestamp.fromDate(user.addedDate!))
        .get();
    var querySnapshotUpdate = await userCollection.firestore
        .collection("User")
        .doc(querySnapshot.docs[0].id)
        .update(cus);

    UserCredential userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(
            email: userPrev.name! + "@tvRepair.com",
            password: decode(userPrev.password!));

    await userCredential.user!.updateEmail(user.name! + "@tvRepair.com");
    await userCredential.user!.updatePassword(decode(user.password!));

    var currentUserA =
        await FireBaseHelperFunctions().getUserByIDFuture2(userA);
    UserModel userModel = UserModel.fromJson(currentUserA.docs[0].data());
    await _auth.signInWithEmailAndPassword(
        email: userModel.name! + "@tvRepair.com",
        password: decode(userModel.password!));
    return querySnapshotUpdate;
  }

  Future deleteUser(UserModel user) async {
    var querySnapshot = await userCollection
        .where("addedDate", isEqualTo: Timestamp.fromDate(user.addedDate!))
        .get();

    var querySnapshotUpdate = await userCollection.firestore
        .collection("User")
        .doc(querySnapshot.docs[0].id)
        .delete();

    UserCredential result = await _auth.signInWithEmailAndPassword(
        email: user.name! + "@tvRepair.com", password: decode(user.password!));
    result.user!.delete();

    var currentUserA =
        await FireBaseHelperFunctions().getUserByIDFuture2(userA);
    UserModel userModel = UserModel.fromJson(currentUserA.docs[0].data());
    await _auth.signInWithEmailAndPassword(
        email: userModel.name! + "@tvRepair.com",
        password: decode(userModel.password!));
    return querySnapshotUpdate;
  }

  deleteProfilePictureFuture(String? url) async {
    try {
      await FirebaseStorage.instance
          .refFromURL(url!
              .replaceAll(
                  new RegExp(
                      r'https://firebasestorage.googleapis.com/v0/b/dial-in-21c50.appspot.com/o/default_images%2F'),
                  '')
              .split('?')[0])
          .delete();
    } catch (e) {
      print("fvb3tomg2093r4j59gjh24mg $e");
    }
  }

  Future<QuerySnapshot> addBusinessPictureFuture(XFile? picture, date) async {
    String? businessLogoUrl;

    Reference ref =
        _storage.ref().child('businessLogo').child("${DateTime.now()}jia2021");

    UploadTask uploadTask = ref.putFile(File(picture!.path));
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);

    await ref.getDownloadURL().then((value) {
      businessLogoUrl = value;
    });

    var querySnapshot = await businessCollection
        .where("addedDate", isEqualTo: Timestamp.fromDate(date))
        .get();
    var querySnapshotUpdate = await customerCollection.firestore
        .collection("Business")
        .doc(querySnapshot.docs[0].id)
        .update({'logo': '$businessLogoUrl'});

    return querySnapshot;
  }
}
