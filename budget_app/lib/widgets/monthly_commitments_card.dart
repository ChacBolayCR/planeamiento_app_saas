import 'package:flutter/material.dart';

import '../design_system/components/kiki_card.dart';
import '../design_system/kiki_colors.dart';
import '../design_system/kiki_radius.dart';
import '../design_system/kiki_spacing.dart';
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

    return KikiCard(
      semanticLabel: 'Compromisos del mes',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Compromisos del mes',
                    style: theme.textTheme.titleMedium),
              ),
              TextButton(onPressed: onViewAll, child: const Text('Ver todos')),
            ],
          ),
          const SizedBox(height: KikiSpacing.sm),
          if (visible.isEmpty)
            Text(
              'A\u00fan no tienes compromisos activos.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          else
            ...visible.map(
              (commitment) => Padding(
                padding: const EdgeInsets.only(bottom: KikiSpacing.sm),
                child: _CommitmentPreview(
                  commitment: commitment,
                  currencySymbol: currencySymbol,
                ),
              ),
            ),
        ],
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
      'Vencido' => KikiColors.error,
      'Pr\u00f3ximo' => KikiColors.warning,
      'Pagado' => KikiColors.success,
      _ => theme.colorScheme.primary,
    };

    return Container(
      padding: const EdgeInsets.all(KikiSpacing.md),
      decoration: BoxDecoration(
        color: KikiColors.surfaceSoft,
        borderRadius: BorderRadius.circular(KikiRadius.medium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(commitment.name, style: theme.textTheme.titleSmall),
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
          const SizedBox(height: KikiSpacing.xs),
          Text(
            '$currencySymbol${commitment.monthlyAmount.toStringAsFixed(0)} \u00b7 pr\u00f3ximo ${commitment.nextPaymentDate.day}/${commitment.nextPaymentDate.month}',
          ),
          if (commitment.remainingBalance > 0) ...[
            const SizedBox(height: 2),
            Text(
              'Saldo pendiente: $currencySymbol${commitment.remainingBalance.toStringAsFixed(0)}',
              style: theme.textTheme.bodySmall,
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
    if (diff <= 7) return 'Pr\u00f3ximo';
    return 'Pendiente';
  }
}
