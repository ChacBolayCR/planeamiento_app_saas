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
            /// ðŸ± KIKI (imagen estática)
            Image.asset(
              'assets/images/avatars/kiki/kiki_rest.png',
              height: 160,
            ),

            const SizedBox(height: 24),

            const Text(
              'Agrega tu primer gasto y deja que Kiki te ayude a entender tu dinero.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
