import 'package:flutter/material.dart';

enum KikiMood {
  happy,
  neutral,
  warning,
}

class KikiMessageCard extends StatelessWidget {
  final KikiMood mood;
  final String message;

  const KikiMessageCard({
    super.key,
    required this.mood,
    required this.message,
  });

  String _imageForMood() {
    switch (mood) {
      case KikiMood.happy:
        return 'assets/images/kiki/kiki_happy.png';
      case KikiMood.warning:
        return 'assets/images/kiki/kiki_main.png';
      case KikiMood.neutral:
      default:
        return 'assets/images/kiki/kiki_idle.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceVariant,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Image.asset(
              _imageForMood(),
              height: 64,
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
