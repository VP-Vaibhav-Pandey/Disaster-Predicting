import 'package:flutter/material.dart';
import 'package:app2/components/navbar.dart';
import 'package:app2/pages/earthquake.dart';
import 'package:app2/pages/flood.dart';
import 'package:app2/pages/home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Set(),
    );
  }
}

class Set extends StatefulWidget {
  const Set({super.key});

  @override
  State<Set> createState() => _SetState();
}

class _SetState extends State<Set> {
  int _select = 0;
  PageController _pageController = PageController();

  void navigate(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() {
      _select = index;
    });
  }

  final List<Widget> _pages = [
    const Home(),
    const Earthquake(),
    const Flood(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      bottomNavigationBar: Navbar(
        onTabChange: (index) => navigate(index),
        selectedIndex: _select,
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _select = index;
          });
        },
        children: _pages,
      ),
    );
  }
}
