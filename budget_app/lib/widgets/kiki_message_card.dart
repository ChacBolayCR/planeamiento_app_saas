import 'package:flutter/material.dart';

enum KikiMood { happy, neutral, warning }

class KikiMessageCard extends StatelessWidget {
  final KikiMood mood;
  final String message;

  /// Compacto para usarlo como banner chico
  final bool compact;

  const KikiMessageCard({
    super.key,
    required this.mood,
    required this.message,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final padding = compact ? const EdgeInsets.all(12) : const EdgeInsets.all(14);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      child: Padding(
        padding: padding,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: Image.asset(
                _kikiAssetForMood(mood),
                width: compact ? 40 : 46,
                height: compact ? 40 : 46,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: compact ? 13.5 : 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  height: 1.25,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _kikiAssetForMood(KikiMood mood) {
    switch (mood) {
      case KikiMood.happy:
        return 'assets/images/kiki/kiki_happy.png';

      case KikiMood.warning:
        // ⚠️ No tienes kiki_warning.png: usamos kiki_play como “alerta/protectora”
        return 'assets/images/kiki/kiki_play.png';

      case KikiMood.neutral:
      default:
        return 'assets/images/kiki/kiki_idle.png';
    }
  }
}
