import 'package:flutter/material.dart';

class EmptyHome extends StatelessWidget {
  const EmptyHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// 🐱 KIKI (imagen estática)
            Image.asset(
              'assets/images/kiki_idle_1.png',
              height: 160,
            ),

            const SizedBox(height: 24),

            const Text(
              'La libertad empieza con educación financiera 💳',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              'Agrega tu primer gasto y deja que Kiki te ayude a entender tu dinero.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
