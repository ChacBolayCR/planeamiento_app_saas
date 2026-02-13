import 'package:flutter/material.dart';

enum KikiMood { happy, neutral, warning }

class KikiMessageCard extends StatelessWidget {
  final KikiMood mood;
  final String message;

  /// Si luego quieres compactarlo más, deja esto listo
  final bool compact;

  /// ✅ NUEVO: permitir ocultar la imagen dentro del globo
  final bool showAvatar;

  const KikiMessageCard({
    super.key,
    required this.mood,
    required this.message,
    this.compact = false,
    this.showAvatar = true,
  });

  @override
  Widget build(BuildContext context) {
    final EdgeInsets padding =
        compact ? const EdgeInsets.all(12) : const EdgeInsets.all(16);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: padding,
        child: Row(
          children: [
            if (showAvatar) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: Image.asset(
                  _kikiAssetForMood(mood),
                  width: compact ? 38 : 44,
                  height: compact ? 38 : 44,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
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
        return 'assets/images/kiki/kiki_warning.png';
      case KikiMood.neutral:
      default:
        return 'assets/images/kiki/kiki_idle.png';
    }
  }
}
