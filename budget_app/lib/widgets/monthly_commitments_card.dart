import 'package:flutter/material.dart';

import '../models/financial_commitment.dart';

class MonthlyCommitmentsCard extends StatelessWidget {
  final List<FinancialCommitment> commitments;
  final String currencySymbol;
  final VoidCallback onViewAll;

  const MonthlyCommitmentsCard({
    super.key,
    required this.commitments,
    required this.currencySymbol,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visible = commitments.take(3).toList();

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Compromisos del mes',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: onViewAll,
                  child: const Text('Ver todos'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (visible.isEmpty)
              Text(
                'Aún no tienes compromisos activos.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
            else
              ...visible.map(
                (commitment) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _CommitmentPreview(
                    commitment: commitment,
                    currencySymbol: currencySymbol,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CommitmentPreview extends StatelessWidget {
  final FinancialCommitment commitment;
  final String currencySymbol;

  const _CommitmentPreview({
    required this.commitment,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = _statusFor(commitment);
    final statusColor = switch (status) {
      'Vencido' => Colors.red,
      'Próximo' => Colors.orange,
      'Pagado' => Colors.green,
      _ => theme.colorScheme.primary,
    };

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  commitment.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                status,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$currencySymbol${commitment.monthlyAmount.toStringAsFixed(0)} · próximo ${commitment.nextPaymentDate.day}/${commitment.nextPaymentDate.month}',
          ),
          if (commitment.remainingBalance > 0) ...[
            const SizedBox(height: 2),
            Text(
              'Saldo pendiente: $currencySymbol${commitment.remainingBalance.toStringAsFixed(0)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _statusFor(FinancialCommitment commitment) {
    if (!commitment.isActive) return 'Pagado';
    final today = DateTime.now();
    final due = DateTime(
      commitment.nextPaymentDate.year,
      commitment.nextPaymentDate.month,
      commitment.nextPaymentDate.day,
    );
    final current = DateTime(today.year, today.month, today.day);
    final diff = due.difference(current).inDays;
    if (diff < 0) return 'Vencido';
    if (diff <= 7) return 'Próximo';
    return 'Pendiente';
  }
}
