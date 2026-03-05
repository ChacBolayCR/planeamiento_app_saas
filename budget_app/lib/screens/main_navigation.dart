import 'package:flutter/material.dart';

import 'dashboard/dashboard_screen.dart';
import 'expenses/expenses_screen.dart';
import 'profile/profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _index = 0;

  // Para preservar estado por tab (scroll, inputs, etc.)
  final _storageBucket = PageStorageBucket();

  late final List<Widget> _tabs = [
    PageStorage(
      bucket: PageStorageBucket(),
      child: DashboardScreen(),
    ),
    PageStorage(
      bucket: PageStorageBucket(),
      child: ExpensesScreen(),
    ),
    PageStorage(
      bucket: PageStorageBucket(),
      child: ProfileScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageStorage(
        bucket: _storageBucket,
        child: IndexedStack(
          index: _index,
          children: _tabs,
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: 'Gastos',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}