import 'package:flutter/material.dart';

class InsightCard extends StatelessWidget {
  final String dominantCategory;
  final double percentUsed;

  const InsightCard({
    super.key,
    required this.dominantCategory,
    required this.percentUsed,
  });

  @override
  Widget build(BuildContext context) {
    String message;

    if (percentUsed < 0.5) {
      message = 'Vas muy bien 💚 sigue así.';
    } else if (percentUsed < 0.8) {
      message = 'Ojo 👀 ya llevas más de la mitad.';
    } else {
      message = 'Cuidado 😿 estás cerca del límite.';
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.pets, size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                dominantCategory.isEmpty
                    ? message
                    : '$message\nMayor gasto: $dominantCategory',
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
