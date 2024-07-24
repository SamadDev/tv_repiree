import 'package:flutter/material.dart';
import 'package:tv_repair/constants/constatns.dart';
import 'package:tv_repair/screens/homeScreen.dart';
import 'package:tv_repair/screens/homeScreen2.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  PageController _pageController = PageController();
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        physics: NeverScrollableScrollPhysics(),
        controller: _pageController,
        children: [HomeScreen(), HomeScreen2()],
      ),
      bottomNavigationBar: BottomNavigationBar(
        showUnselectedLabels: false,
        currentIndex: _selectedIndex,
        selectedItemColor: primaryColor(1.0),
        unselectedItemColor: Colors.grey,
        onTap: (int value) {
          FocusScope.of(context).unfocus();
          setState(() {
            _selectedIndex = value;
          });
          _pageController.jumpToPage(_selectedIndex);
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.tv),
            label: "TV Repair",
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.article_sharp), label: "Invoice")
        ],
      ),
    );
  }
}
