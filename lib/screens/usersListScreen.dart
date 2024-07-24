import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:tv_repair/constants/constatns.dart';
import 'package:tv_repair/constants/helper_functions.dart';
import 'package:tv_repair/firebase_functions/firebase_functions.dart';
import 'package:tv_repair/model/userModel.dart';
import 'package:tv_repair/widgets/searchItem.dart';
import 'package:tv_repair/widgets/textInputItem.dart';

class UserList extends StatefulWidget {
  const UserList({Key? key}) : super(key: key);

  @override
  _UserListState createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  TextEditingController searchController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

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
                  Text("Users"),
                ],
              ),
              actions: [submitUser(icon: Icons.add)],
            ),
            body: Column(
              children: [
                Material(
                    color: primaryColor(1.0),
                    elevation: 2,
                    child: SearchItem(
                      searchController: searchController,
                      hint: "search for user",
                      onChange: (v) {
                        setState(() {});
                      },
                    )),
                SizedBox(
                  height: 6,
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                      stream: FireBaseHelperFunctions().getAllUsers(),
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
                                  UserModel user = UserModel.fromJson(
                                      snapshot.data!.docs[index]);
                                  return user.name!.toLowerCase().contains(
                                          searchController.text.toLowerCase())
                                      ? Card(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12)),
                                          child: InkWell(
                                            borderRadius:
                                                BorderRadius.circular(12),
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
                                                        "${user.name}",
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            color:
                                                                Colors.black87,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Text(
                                                        "${user.addedDate.toString().split(" ")[0]}",
                                                        style: TextStyle(
                                                          color: Colors.black87,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 6,
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      submitUser(
                                                          user: user,
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
                                                                  .deleteUser(
                                                                      user)
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
                                                                    "Are sure to delete this user?");
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

  Widget submitUser({bool editMode = false, UserModel? user, IconData? icon}) {
    return IconButton(
        onPressed: () async {
          this.setState(() {
            _autoValidate = false;
            if (editMode) {
              nameController.text = user!.name!;
              passwordController.text = decode(user.password!);
            } else {
              nameController.text = "";
              passwordController.text = "";
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
                        ? Text("Are you sure to edit this user?")
                        : Text("Are you sure to add  this user?"),
                    content: Form(
                      key: _formKey,
                      // autovalidate: _autoValidate,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextInputItem(
                            title: "Name",
                            hint: "write user name",
                            controller: nameController,
                          ),
                          TextInputItem(
                            title: "Password",
                            hint: "write user password",
                            obscureText: false,
                            validator: (v) {
                              if (v!.length < 6) {
                                return "weak password less than 6 character";
                              } else {
                                return null;
                              }
                            },
                            controller: passwordController,
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
                                UserModel prevUser = user!;
                                UserModel updateUser = UserModel(
                                    name: nameController.text,
                                    password: encode(passwordController.text),
                                    addedDate: user.addedDate,
                                    type: user.type);
                                FireBaseHelperFunctions()
                                    .updateUser(updateUser, prevUser)
                                    .then((value) {
                                  this.setState(() {
                                    showLoading = false;
                                  });
                                });
                              } else {
                                UserModel newUser = UserModel(
                                    name: nameController.text,
                                    password: encode(passwordController.text),
                                    type: 1,
                                    addedDate: DateTime.now());
                                FireBaseHelperFunctions()
                                    .addNewUser(newUser)
                                    .then((value) {
                                  this.setState(() {
                                    showLoading = false;
                                  });
                                  if (value is String) {
                                    if (value == "email-already-in-use") {
                                      ScaffoldMessenger.of(this.context)
                                          .showSnackBar(SnackBar(
                                        content: Text(
                                            "This user name is already exist, cant be duplicate!",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        backgroundColor: Colors.red,
                                      ));
                                    }
                                  }
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
