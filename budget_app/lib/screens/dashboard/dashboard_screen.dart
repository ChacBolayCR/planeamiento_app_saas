import 'package:flutter/material.dart';
import '../../data/expenses_repository.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = ExpensesRepository.instance;
    final byCategory = repo.expensesByCategory();

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total gastos: ₡${repo.totalExpenses.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),

            const Text(
              'Gastos por categoría',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            ...byCategory.entries.map(
              (e) => ListTile(
                title: Text(e.key),
                trailing: Text('₡${e.value.toStringAsFixed(2)}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
