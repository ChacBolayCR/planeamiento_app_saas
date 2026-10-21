import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../design_system/components/kiki_card.dart';
import '../../design_system/components/kiki_empty_state.dart';
import '../../design_system/kiki_colors.dart';
import '../../design_system/kiki_radius.dart';
import '../../design_system/kiki_spacing.dart';
import '../../models/expense.dart';
import '../../providers/budget_provider.dart';
import '../../utils/kiki_avatar_assets.dart';
import 'add_expenses_modal.dart';

class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});

  Future<void> _showFreeLimitDialog(BuildContext context, int limit) async {
    final budget = context.read<BudgetProvider>();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Límite Free alcanzado'),
        content: Text(
          'En la versión gratuita puedes registrar hasta $limit gastos por mes.',
        ),
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
                    content: Text('Pro activado (modo pruebas)'),
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
      useSafeArea: true,
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
      backgroundColor: KikiColors.background,
      appBar: AppBar(title: const Text('Gastos')),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Agregar gasto',
        onPressed: () async {
          if (canAdd) {
            _openAdd(context);
          } else {
            await _showFreeLimitDialog(context, limit);
          }
        },
        child: const Icon(Icons.add_rounded),
      ),
      body: expenses.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(KikiSpacing.lg),
              child: Center(
                child: KikiEmptyState(
                  assetPath: KikiAvatarAssets.rest,
                  title: 'No hay gastos registrados todavía.',
                  message:
                      'Agrega tu primer gasto para que Kiki empiece a ordenar tu historial.',
                  actionLabel: 'Agregar primer gasto',
                  onAction: canAdd
                      ? () => _openAdd(context)
                      : () => _showFreeLimitDialog(context, limit),
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                KikiSpacing.lg,
                KikiSpacing.sm,
                KikiSpacing.lg,
                KikiSpacing.section,
              ),
              itemCount: expenses.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: KikiSpacing.sm),
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
        return Icons.wifi_rounded;
      case 'Alquiler':
        return Icons.home_rounded;
      case 'Comida':
        return Icons.restaurant_rounded;
      case 'Transporte':
        return Icons.directions_car_rounded;
      case 'Marketing':
        return Icons.campaign_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<BudgetProvider>();
    final symbol = provider.currencySymbol;

    return KikiCard(
      padding: const EdgeInsets.all(KikiSpacing.md),
      semanticLabel: 'Gasto ${expense.title}',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: KikiColors.surfaceSoft,
              borderRadius: BorderRadius.circular(KikiRadius.medium),
            ),
            child: Icon(
              _iconByCategory(expense.category),
              color: KikiColors.primary,
            ),
          ),
          const SizedBox(width: KikiSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: KikiSpacing.xs),
                Text(
                  expense.subcategoryName == null
                      ? expense.category
                      : '${expense.category} · ${expense.subcategoryName}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: KikiColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: KikiSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$symbol${expense.amount.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: KikiColors.textPrimary,
                    ),
              ),
              IconButton(
                tooltip: 'Eliminar gasto',
                icon: const Icon(Icons.delete_outline_rounded),
                color: KikiColors.error,
                onPressed: () => _confirmDelete(context, provider),
              ),
            ],
          ),
        ],
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
            style: ElevatedButton.styleFrom(
              backgroundColor: KikiColors.error,
              foregroundColor: KikiColors.surface,
            ),
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
