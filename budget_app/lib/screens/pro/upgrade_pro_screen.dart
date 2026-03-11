import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/budget_provider.dart';

class UpgradeProScreen extends StatelessWidget {
  const UpgradeProScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final budget = context.watch<BudgetProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kiki Pro'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.workspace_premium_rounded,
                          size: 38,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Kiki Pro ✨',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Desbloquea análisis más avanzados y lleva tu control financiero a otro nivel.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              const _ProFeatureTile(
                icon: Icons.all_inclusive_rounded,
                title: 'Gastos ilimitados',
                subtitle: 'Registra todos los movimientos que necesites.',
              ),
              const SizedBox(height: 10),
              const _ProFeatureTile(
                icon: Icons.bar_chart_rounded,
                title: 'Gráficos avanzados',
                subtitle: 'Visualiza tus categorías y tendencias del mes.',
              ),
              const SizedBox(height: 10),
              const _ProFeatureTile(
                icon: Icons.timeline_rounded,
                title: 'Tendencias mensuales',
                subtitle: 'Compara tu comportamiento financiero con más contexto.',
              ),
              const SizedBox(height: 10),
              const _ProFeatureTile(
                icon: Icons.auto_awesome_rounded,
                title: 'Insights inteligentes',
                subtitle: 'Recibe recomendaciones más útiles de Kiki.',
              ),

              const Spacer(),

              if (budget.isTrialActive) ...[
                Card(
                  elevation: 0,
                  color: theme.colorScheme.primary.withOpacity(0.08),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Text(
                      'Tu prueba Pro está activa. Te quedan ${budget.trialDaysLeft} día(s).',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    if (budget.isPro) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Pro ya está activo ✅'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return;
                    }

                    if (kDebugMode) {
                      await budget.startProTrial();

                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Trial Pro activado por 7 días ✅'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      Navigator.pop(context);
                      return;
                    }

                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Pronto podrás activar tu prueba Pro ✨'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: Text(
                    budget.isPro ? 'Pro activo' : 'Probar Pro por 7 días',
                  ),
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Luego podrás activar tu suscripción desde Google Play.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black45),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProFeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ProFeatureTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}