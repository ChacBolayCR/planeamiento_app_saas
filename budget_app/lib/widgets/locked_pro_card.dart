import 'package:flutter/material.dart';

import '../screens/pro/upgrade_pro_screen.dart';

class LockedProCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const LockedProCard({
    super.key,
    this.title = 'Función Pro',
    this.subtitle = 'Desbloquea esta sección para ver el desglose completo.',
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: t.colorScheme.primary.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.lock_rounded,
                    color: t.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: t.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: t.textTheme.bodyMedium?.copyWith(
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 46,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const UpgradeProScreen(),
                    ),
                  );
                },
                child: const Text('Ver Kiki Pro ✨'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}