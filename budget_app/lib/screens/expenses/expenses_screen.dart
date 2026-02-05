import 'package:flutter/material.dart';
import '../../repositories/expenses_repository.dart';
import '../../models/expense.dart';
import 'add_expenses_modal.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final ExpensesRepository repo = ExpensesRepository.instance;

  @override
  Widget build(BuildContext context) {
    final expenses = repo.expenses;

    return Scaffold(
      appBar: AppBar(title: const Text('Gastos')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => const AddExpenseModal(),
          );
          setState(() {}); // 🔥 fuerza refresco
        },
        child: const Icon(Icons.add),
      ),
      body: expenses.isEmpty
          ? const Center(child: Text('No hay gastos registrados'))
          : ListView.builder(
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                return _ExpenseTile(expense: expenses[index]);
              },
            ),
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  final Expense expense;

  const _ExpenseTile({required this.expense});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(expense.title),
      subtitle: Text(expense.category),
      trailing: Text('\$${expense.amount.toStringAsFixed(2)}'),
    );
  }
}
