import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../design-system/colors.dart';

import '../providers/auth_provider.dart';

class Navbar extends ConsumerStatefulWidget {
  final int selectedIndex;

  const Navbar({
    super.key,
    required this.selectedIndex,
    });

  @override
  ConsumerState<Navbar> createState() => _NavbarState();
}

class _NavbarState extends ConsumerState<Navbar> {

  void _onItemTapped(int index, bool isAuthenticated) {

    switch (index) {
      case 0:
        context.go('/'); // Navigate to Home
        break;
      case 1:
        context.go('/map'); // Navigate to Map
        break;
      case 2:
        context.go('/add_entry'); // Navigate to Add Entry
        break;
      case 3:
        isAuthenticated
          ? context.go('/user') // Navigate to User Profile if authenticated
          :
        context.go('/login');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

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
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.person),
          label: 'User',
        ),
      ],
      currentIndex: widget.selectedIndex,
      onTap: (index) => _onItemTapped(index, isAuthenticated),
      backgroundColor: AppColors.navigationBarColor,
      inactiveColor: Colors.white70,
      activeColor: Colors.white,
    );
  }
}