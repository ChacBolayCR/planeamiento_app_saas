import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/budget_provider.dart';
import '../../models/expense.dart';
import 'add_expenses_modal.dart';

class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});

  Future<void> _showFreeLimitDialog(BuildContext context, int limit) async {
    final budget = context.read<BudgetProvider>();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Límite Free alcanzado'),
        content: Text('En la versión gratuita puedes registrar hasta $limit gastos por mes.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
          if (kDebugMode)
            ElevatedButton(
              onPressed: () {
                budget.setIsPro(true);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pro activado (modo pruebas) ✅'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Activar Pro (debug)'),
            ),
        ],
      ),
    );
  }

  void _openAdd(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const AddExpenseModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final budget = context.watch<BudgetProvider>();
    final expenses = budget.expenses;

    final limit = BudgetProvider.freeMonthlyExpenseLimit;
    final canAdd = budget.isPro || expenses.length < limit;

    return Scaffold(
      appBar: AppBar(title: const Text('Gastos')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (canAdd) {
            _openAdd(context);
          } else {
            await _showFreeLimitDialog(context, limit);
          }
        },
        child: const Icon(Icons.add),
      ),
      body: expenses.isEmpty
          ? const Center(child: Text('No hay gastos registrados'))
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: expenses.length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
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

  IconData _iconByCategory(String category) {
    switch (category) {
      case 'Servicios':
        return Icons.wifi;
      case 'Alquiler':
        return Icons.home;
      case 'Comida':
        return Icons.restaurant;
      case 'Transporte':
        return Icons.directions_car;
      case 'Marketing':
        return Icons.campaign;
      default:
        return Icons.receipt_long;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<BudgetProvider>();
    final symbol = provider.currencySymbol;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Icon(
            _iconByCategory(expense.category),
            color: Colors.blue,
          ),
        ),
        title: Text(
          expense.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(expense.category),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$symbol${expense.amount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDelete(context, provider),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, BudgetProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar gasto'),
        content: const Text('¿Deseas eliminar este gasto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              provider.removeExpense(expense.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Gasto eliminado'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}