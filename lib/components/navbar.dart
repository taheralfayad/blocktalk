import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../design-system/colors.dart';

class Navbar extends StatefulWidget {
  final int selectedIndex;

  const Navbar({
    super.key,
    required this.selectedIndex,
    });

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {

  void _onItemTapped(int index) {

    switch (index) {
      case 0:
        context.go('/'); // Navigate to Home
        break;
      case 1:
        context.go('/map'); // Navigate to Map
        break;
      case 2:
        context.go('/entry'); // Navigate to Add Entry
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.map),
          label: 'Map',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            CupertinoIcons.add_circled,
          ),
          label: 'Add Entry',
        ),
      ],
      currentIndex: widget.selectedIndex,
      onTap: _onItemTapped,
      backgroundColor: AppColors.navigationBarColor,
      inactiveColor: Colors.white70,
      activeColor: Colors.white,
    );
  }
}