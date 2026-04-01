import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/budget_provider.dart';

class UpgradeProScreen extends StatelessWidget {
  const UpgradeProScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final budget = context.watch<BudgetProvider>();

    final used = budget.currentMonthExpenses.length;
    final limit = BudgetProvider.freeMonthlyExpenseLimit;
    final progress = (used / limit).clamp(0.0, 1.0);

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            /// HANDLE
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            /// 🚨 HEADLINE
            const Text(
              "Te quedaste sin espacio 😅",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              "Usaste $used de $limit gastos este mes",
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 16),

            /// 📊 PROGRESS BAR (clave psicológica)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: Colors.grey.shade200,
                color: Colors.redAccent,
              ),
            ),

            const SizedBox(height: 20),

            /// 💡 MENSAJE DE PÉRDIDA
            const Text(
              "Si no activás Pro, no vas a poder seguir registrando gastos 😬",
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            /// 💎 BENEFICIOS
            _feature("Gastos ilimitados"),
            _feature("Control total mensual"),
            _feature("Insights automáticos"),
            _feature("Gráficos avanzados"),

            const SizedBox(height: 20),

            /// 🎁 TRIAL
            if (!budget.isTrialActive && !budget.isPro)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "🎁 Probá 7 días GRATIS",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),

            const SizedBox(height: 20),

            /// 💰 PRECIO
            const Text(
              "₡2,500 / mes",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const Text(
              "Menos que un café ☕",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 20),

            /// 🔥 CTA
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (!budget.isTrialActive && !budget.isPro) {
                    await budget.startProTrial();
                  } else {
                    await budget.buyPro();
                  }

                  if (context.mounted) Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  _getText(budget),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 10),

            /// RESTORE
            TextButton(
              onPressed: () async {
                await budget.restorePurchases();
              },
              child: const Text("Restaurar compra"),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _feature(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.indigo),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  static String _getText(BudgetProvider budget) {
    if (budget.isPro) return "Ya sos Pro 🎉";
    if (budget.isTrialActive) return "Seguir con Pro";
    return "Activar prueba gratis";
  }
}