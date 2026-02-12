import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/budget_provider.dart';

// Screens
import '../dashboard/dashboard_screen.dart'; 
import '../expenses/expenses_screen.dart';
import '../profile/profile_screen.dart';

// Widgets
import '../../widgets/empty_home.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  void _onTap(int index) => setState(() => _currentIndex = index);

  @override
  Widget build(BuildContext context) {
    final budget = context.watch<BudgetProvider>();
    final hasExpenses = budget.expenses.isNotEmpty;

    // Si no hay gastos, que no se quede en Gastos/Perfil por accidente
    if (!hasExpenses && _currentIndex != 0) _currentIndex = 0;

    final pages = <Widget>[
      hasExpenses ? const DashboardScreen() : const EmptyHome(),
      const ExpensesScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kiki Finance'),
      ),
      body: pages[_currentIndex],

      floatingActionButton: (_currentIndex == 0 || _currentIndex == 1)
          ? FloatingActionButton(
              onPressed: () => setState(() => _currentIndex = 1),
              child: const Icon(Icons.add),
            )
          : null,

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Resumen'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Gastos'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
