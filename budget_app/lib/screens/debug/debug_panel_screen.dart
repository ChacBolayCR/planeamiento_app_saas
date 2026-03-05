import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/budget_provider.dart';

class DebugPanelScreen extends StatelessWidget {
  const DebugPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ Seguridad: solo permitir en debug
    if (!kDebugMode) {
      return const Scaffold(
        body: Center(child: Text('No disponible')),
      );
    }

    final t = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Panel'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Consumer<BudgetProvider>(
          builder: (_, budget, __) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Pro (modo pruebas)',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                        Switch(
                          value: budget.isPro,
                          onChanged: budget.setIsPro,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                Text(
                  'Tips',
                  style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                const Text('• Úsalo para probar features Pro sin cobrar.'),
                const Text('• No se muestra en Release.'),

                const Spacer(),

                // Opcional: botón para resetear data (si quieres lo activamos luego)
                // ElevatedButton.icon(
                //   onPressed: () async { ... },
                //   icon: const Icon(Icons.delete_forever),
                //   label: const Text('Reset data (todo)'),
                // ),
              ],
            );
          },
        ),
      ),
    );
  }
}