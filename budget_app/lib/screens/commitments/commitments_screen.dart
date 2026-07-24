import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/financial_commitment.dart';
import '../../providers/budget_provider.dart';
import '../../providers/commitments_provider.dart';

class CommitmentsScreen extends StatelessWidget {
  const CommitmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CommitmentsProvider>();
    final budget = context.watch<BudgetProvider>();
    final active = provider.getActiveCommitments();
    final completed = provider.getCompletedCommitments();
    final all = provider.commitments;
    final totalPaid = all.fold(0.0, (sum, item) => sum + item.paidAmount);
    final totalRemaining =
        all.fold(0.0, (sum, item) => sum + item.remainingBalance);

    return Scaffold(
      appBar: AppBar(title: const Text('Compromisos')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SummaryCard(
              currencySymbol: budget.currencySymbol,
              monthlyTotal: provider.totalMonthlyCommitments(),
              totalPaid: totalPaid,
              totalRemaining: totalRemaining,
            ),
            const SizedBox(height: 16),
            Text(
              'Activos',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            if (active.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No hay compromisos activos todavía.'),
                ),
              )
            else
              ...active.map(
                (commitment) => _CommitmentTile(
                  commitment: commitment,
                  currencySymbol: budget.currencySymbol,
                ),
              ),
            const SizedBox(height: 16),
            Text(
              'Completados',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            if (completed.isEmpty)
              const Text('Cuando termines un compromiso, aparecerá aquí.')
            else
              ...completed.map(
                (commitment) => _CommitmentTile(
                  commitment: commitment,
                  currencySymbol: budget.currencySymbol,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String currencySymbol;
  final double monthlyTotal;
  final double totalPaid;
  final double totalRemaining;

  const _SummaryCard({
    required this.currencySymbol,
    required this.monthlyTotal,
    required this.totalPaid,
    required this.totalRemaining,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen de compromisos',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 12),
            _Metric(
                label: 'Total mensual',
                value: '$currencySymbol${monthlyTotal.toStringAsFixed(0)}'),
            _Metric(
                label: 'Total pagado',
                value: '$currencySymbol${totalPaid.toStringAsFixed(0)}'),
            _Metric(
                label: 'Saldo pendiente',
                value: '$currencySymbol${totalRemaining.toStringAsFixed(0)}'),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;

  const _Metric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _CommitmentTile extends StatelessWidget {
  final FinancialCommitment commitment;
  final String currencySymbol;

  const _CommitmentTile({
    required this.commitment,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              commitment.name,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            _Metric(
                label: 'Cuota',
                value:
                    '$currencySymbol${commitment.monthlyAmount.toStringAsFixed(0)}'),
            _Metric(
                label: 'Total',
                value:
                    '$currencySymbol${commitment.totalAmount.toStringAsFixed(0)}'),
            _Metric(
                label: 'Pagado',
                value:
                    '$currencySymbol${commitment.paidAmount.toStringAsFixed(0)}'),
            _Metric(
                label: 'Saldo',
                value:
                    '$currencySymbol${commitment.remainingBalance.toStringAsFixed(0)}'),
            _Metric(
                label: 'Cuotas',
                value:
                    '${commitment.paidInstallments}/${commitment.totalInstallments}'),
            _Metric(
              label: 'Próximo pago',
              value:
                  '${commitment.nextPaymentDate.day}/${commitment.nextPaymentDate.month}/${commitment.nextPaymentDate.year}',
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: commitment.isActive
                    ? () async {
                        final paid = await context
                            .read<CommitmentsProvider>()
                            .markPaymentAsPaid(
                              commitmentId: commitment.id,
                              budgetProvider: context.read<BudgetProvider>(),
                            );
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              paid
                                  ? '¡Una cuota menos! Tu saldo pendiente es de $currencySymbol${context.read<CommitmentsProvider>().remainingBalanceForCommitment(commitment.id).toStringAsFixed(0)}.'
                                  : 'Esta cuota ya fue registrada o no se pudo guardar.',
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    : null,
                child: const Text('Marcar cuota como pagada'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
