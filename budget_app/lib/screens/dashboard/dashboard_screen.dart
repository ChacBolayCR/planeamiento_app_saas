import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/budget_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final budget = context.watch<BudgetProvider>();

    final total = budget.monthlyBudget;
    final spent = budget.totalExpenses;
    final remaining = budget.remainingBudget;

    final double percent =
    total == 0 ? 0.0 : (spent / total).clamp(0.0, 1.0).toDouble();

    Color progressColor;
    if (percent < 0.7) {
      progressColor = Colors.green;
    } else if (percent < 0.9) {
      progressColor = Colors.orange;
    } else {
      progressColor = Colors.red;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _BudgetHeader(
              total: total,
              spent: spent,
              remaining: remaining,
            ),

            const SizedBox(height: 24),

            Text(
              'Uso del presupuesto',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),

            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: LinearProgressIndicator(
                value: percent,
                minHeight: 18,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation(progressColor),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              '${(percent * 100).toStringAsFixed(1)}% utilizado',
              textAlign: TextAlign.right,
              style: TextStyle(color: progressColor),
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetHeader extends StatelessWidget {
  final double total;
  final double spent;
  final double remaining;

  const _BudgetHeader({
    required this.total,
    required this.spent,
    required this.remaining,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _RowItem(
              label: 'Presupuesto mensual',
              value: total,
              color: Colors.blue,
            ),
            const SizedBox(height: 12),
            _RowItem(
              label: 'Gastos',
              value: spent,
              color: Colors.red,
            ),
            const Divider(height: 32),
            _RowItem(
              label: 'Disponible',
              value: remaining,
              color: remaining >= 0 ? Colors.green : Colors.red,
              bold: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _RowItem extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final bool bold;

  const _RowItem({
    required this.label,
    required this.value,
    required this.color,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          '\$${value.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
