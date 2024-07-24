import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:tv_repair/MainScreen.dart';
import 'package:tv_repair/constants/constatns.dart';
import 'package:tv_repair/screens/homeScreen.dart';
import 'package:tv_repair/screens/signInScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(HotRestartController(child: MyApp()));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NGS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: primaryColor(1.0),
        primaryIconTheme: const IconThemeData.fallback().copyWith(
          color: Colors.white,
        ),
        // buttonColor: Colors.white,
        floatingActionButtonTheme:
            FloatingActionButtonThemeData(foregroundColor: Colors.white),
      ),
      home: _auth.currentUser != null ? MainScreen() : LoginScreen(),
    );
  }
}

class HotRestartController extends StatefulWidget {
  final Widget child;

  HotRestartController({required this.child});

  static performHotRestart(BuildContext context) {
    final _HotRestartControllerState? state =
    context.findAncestorStateOfType<_HotRestartControllerState>();
    state!.performHotRestart();
  }

  @override
  _HotRestartControllerState createState() => new _HotRestartControllerState();
}

class _HotRestartControllerState extends State<HotRestartController> {
  Key key = new UniqueKey();

  void performHotRestart() {
    this.setState(() {
      key = new UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      key: key,
      child: widget.child,
    );
  }
}

