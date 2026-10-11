import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../design_system/components/kiki_button.dart';
import '../../design_system/components/kiki_card.dart';
import '../../design_system/components/kiki_empty_state.dart';
import '../../design_system/kiki_colors.dart';
import '../../design_system/kiki_spacing.dart';
import '../../models/financial_commitment.dart';
import '../../providers/budget_provider.dart';
import '../../providers/commitments_provider.dart';
import '../../utils/kiki_avatar_assets.dart';

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
      backgroundColor: KikiColors.background,
      appBar: AppBar(title: const Text('Compromisos')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            KikiSpacing.lg,
            KikiSpacing.sm,
            KikiSpacing.lg,
            KikiSpacing.section,
          ),
          children: [
            _SummaryCard(
              currencySymbol: budget.currencySymbol,
              monthlyTotal: provider.totalMonthlyCommitments(),
              totalPaid: totalPaid,
              totalRemaining: totalRemaining,
            ),
            const SizedBox(height: KikiSpacing.lg),
            _SectionTitle(title: 'Activos'),
            const SizedBox(height: KikiSpacing.sm),
            if (active.isEmpty)
              const KikiEmptyState(
                assetPath: KikiAvatarAssets.saving,
                title: 'Sin compromisos activos',
                message:
                    'Cuando registres una cuota o pago mensual, Kiki lo mostrará aquí.',
              )
            else
              ...active.map(
                (commitment) => Padding(
                  padding: const EdgeInsets.only(bottom: KikiSpacing.sm),
                  child: _CommitmentTile(
                    commitment: commitment,
                    currencySymbol: budget.currencySymbol,
                  ),
                ),
              ),
            const SizedBox(height: KikiSpacing.lg),
            _SectionTitle(title: 'Completados'),
            const SizedBox(height: KikiSpacing.sm),
            if (completed.isEmpty)
              const KikiCard(
                variant: KikiCardVariant.soft,
                child: Text('Cuando termines un compromiso, aparecerá aquí.'),
              )
            else
              ...completed.map(
                (commitment) => Padding(
                  padding: const EdgeInsets.only(bottom: KikiSpacing.sm),
                  child: _CommitmentTile(
                    commitment: commitment,
                    currencySymbol: budget.currencySymbol,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: KikiColors.textPrimary,
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
    return KikiCard(
      variant: KikiCardVariant.highlighted,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                KikiAvatarAssets.saving,
                height: 72,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: KikiSpacing.md),
              Expanded(
                child: Text(
                  'Resumen de compromisos',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: KikiSpacing.md),
          _Metric(
            label: 'Total mensual',
            value: '$currencySymbol${monthlyTotal.toStringAsFixed(0)}',
          ),
          _Metric(
            label: 'Total pagado',
            value: '$currencySymbol${totalPaid.toStringAsFixed(0)}',
          ),
          _Metric(
            label: 'Saldo pendiente',
            value: '$currencySymbol${totalRemaining.toStringAsFixed(0)}',
          ),
        ],
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
      padding: const EdgeInsets.only(bottom: KikiSpacing.sm),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
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

    return KikiCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.payments_rounded, color: KikiColors.primary),
              const SizedBox(width: KikiSpacing.sm),
              Expanded(
                child: Text(
                  commitment.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: KikiSpacing.md),
          _Metric(
            label: 'Cuota',
            value:
                '$currencySymbol${commitment.monthlyAmount.toStringAsFixed(0)}',
          ),
          _Metric(
            label: 'Total',
            value:
                '$currencySymbol${commitment.totalAmount.toStringAsFixed(0)}',
          ),
          _Metric(
            label: 'Pagado',
            value: '$currencySymbol${commitment.paidAmount.toStringAsFixed(0)}',
          ),
          _Metric(
            label: 'Saldo',
            value:
                '$currencySymbol${commitment.remainingBalance.toStringAsFixed(0)}',
          ),
          _Metric(
            label: 'Cuotas',
            value:
                '${commitment.paidInstallments}/${commitment.totalInstallments}',
          ),
          _Metric(
            label: 'Próximo pago',
            value:
                '${commitment.nextPaymentDate.day}/${commitment.nextPaymentDate.month}/${commitment.nextPaymentDate.year}',
          ),
          const SizedBox(height: KikiSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: KikiButton(
              label: 'Marcar cuota como pagada',
              icon: Icons.check_circle_outline_rounded,
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
                                ? 'Una cuota menos. Tu saldo pendiente es de $currencySymbol${context.read<CommitmentsProvider>().remainingBalanceForCommitment(commitment.id).toStringAsFixed(0)}.'
                                : 'Esta cuota ya fue registrada o no se pudo guardar.',
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
