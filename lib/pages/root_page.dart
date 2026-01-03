import 'package:flutter/material.dart';
import 'package:playit/pages/libraryPage/library_page.dart';
import 'package:playit/pages/searchPage/search_page.dart';
import 'package:playit/pages/settingPage/setting_page.dart';

import 'homePage/home_page.dart';

class RootPage extends StatefulWidget {
  const RootPage({super.key});
  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  int currentIndex = 0;
  late final PageController _pageController;
  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (value) => {
          setState(() {
            currentIndex = value;
          }),
        },
        scrollDirection: Axis.horizontal,
        children: [HomePage(), LibraryPage(), SearchPage(), SettingPage()],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (value) => {
          setState(() {
            currentIndex = value;
          }),
          _pageController.animateToPage(
            value,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          ),
        },
        selectedItemColor: Theme.of(context).primaryColorDark,
        showUnselectedLabels: false,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: TextStyle(
          color: Theme.of(context).primaryColorDark,
        ),
        items: [
          BottomNavigationBarItem(label: "Home", icon: Icon(Icons.home)),
          BottomNavigationBarItem(
            label: "Libary",
            icon: Icon(Icons.library_music),
          ),
          BottomNavigationBarItem(label: "Search", icon: Icon(Icons.search)),
          BottomNavigationBarItem(label: "Setting", icon: Icon(Icons.settings)),
        ],
      ),
    );
  }
}
