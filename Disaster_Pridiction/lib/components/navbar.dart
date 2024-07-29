import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class Navbar extends StatelessWidget {
  void Function(int)? onTabChange;
  Navbar({super.key, required this.onTabChange, required int selectedIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: GNav(
        color: Colors.grey,
        activeColor: Colors.black,
        tabActiveBorder: const Border(top: BorderSide(color: Colors.white)),
        tabBackgroundColor: Colors.white,
        tabBorderRadius: 30,
        mainAxisAlignment: MainAxisAlignment.center,
        onTabChange: (value) => onTabChange!(value),
        tabs: const [
          GButton(
            icon: Icons.home,
            text: 'Home',
          ),
          GButton(
            icon: Icons.landscape,
            text: 'Earthquake',
          ),
          GButton(
            icon: Icons.water,
            text: 'Flood',
          ),
        ],
      ),
    );
  }
}
