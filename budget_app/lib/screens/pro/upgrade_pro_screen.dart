import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/budget_provider.dart';

class UpgradeProScreen extends StatefulWidget {
  const UpgradeProScreen({super.key});

  @override
  State<UpgradeProScreen> createState() => _UpgradeProScreenState();
}

class _UpgradeProScreenState extends State<UpgradeProScreen> {
  bool _loading = false;
  bool _restoring = false;

  @override
  Widget build(BuildContext context) {
    final budget = context.watch<BudgetProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kiki Pro'),
      ),
      body: SafeArea(
        child: Column(
          children: [

            /// 🔽 CONTENIDO
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [

                    /// 🧠 HEADER
                    _Header(theme: theme),

                    const SizedBox(height: 16),

                    /// 💎 FEATURES
                    const _ProFeatureTile(
                      icon: Icons.all_inclusive_rounded,
                      title: 'Gastos ilimitados',
                      subtitle: 'Registra sin límites y sin fricción.',
                    ),
                    const SizedBox(height: 10),

                    const _ProFeatureTile(
                      icon: Icons.bar_chart_rounded,
                      title: 'Gráficos avanzados',
                      subtitle: 'Visualiza patrones y categorías.',
                    ),
                    const SizedBox(height: 10),

                    const _ProFeatureTile(
                      icon: Icons.timeline_rounded,
                      title: 'Tendencias mensuales',
                      subtitle: 'Entiende cómo evolucionas.',
                    ),
                    const SizedBox(height: 10),

                    const _ProFeatureTile(
                      icon: Icons.auto_awesome_rounded,
                      title: 'Insights inteligentes',
                      subtitle: 'Recomendaciones automáticas.',
                    ),

                    const SizedBox(height: 20),

                    /// 🧪 TRIAL INFO
                    if (budget.isTrialActive)
                      _TrialBanner(daysLeft: budget.trialDaysLeft),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            /// 🔻 FOOTER
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [

                  /// 🚀 BOTÓN PRINCIPAL
                  SizedBox(
  width: double.infinity,
  height: 54,
  child: ElevatedButton(
    onPressed: (_loading || budget.isPro)
        ? null
        : () async {
            setState(() => _loading = true);

            await budget.buyPro();

            setState(() => _loading = false);

            if (!mounted) return;

            _showSnack('🎉 Pro activado');

            Navigator.pop(context);
          },
    child: _loading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Text(
            budget.isPro
                ? 'Has debloqueado Kiki Pro ✅'
                : 'Probar 7 días gratis',
          ),
  ),
),

                  const SizedBox(height: 12),

                  /// 🔄 RESTORE
                  TextButton(
                    onPressed: _restoring
                        ? null
                        : () async {
                            setState(() => _restoring = true);

                            await budget.restorePurchases();

                            setState(() => _restoring = false);

                            _showSnack('Compras restauradas');
                          },
                    child: _restoring
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Restaurar compras'),
                  ),

                  const SizedBox(height: 6),

                  /// 🧾 DISCLAIMER
                  const Text(
                    'Suscripción mensual. Cancela en cualquier momento.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black45, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final ThemeData theme;

  const _Header({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Card(
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
              'Controla tu dinero como nunca antes.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrialBanner extends StatelessWidget {
  final int daysLeft;

  const _TrialBanner({required this.daysLeft});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.primary.withOpacity(0.08),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Text(
          'Te quedan $daysLeft día(s) de Pro gratis',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
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