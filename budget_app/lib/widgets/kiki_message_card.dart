import 'package:flutter/material.dart';

enum KikiMood { happy, neutral, warning, overbudget }

class KikiMessageCard extends StatelessWidget {
  final KikiMood mood;
  final String message;
  final bool compact;
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
    final padding = compact
        ? const EdgeInsets.all(12)
        : const EdgeInsets.fromLTRB(14, 14, 14, 8);

    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showAvatar) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: Image.asset(
                _kikiAssetForMood(mood),
                width: compact ? 40 : 48,
                height: compact ? 40 : 48,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: compact ? 14 : 15,
                height: 1.35,
                fontWeight: FontWeight.w600,
                color: Colors.black.withOpacity(0.82),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _kikiAssetForMood(KikiMood mood) {
    switch (mood) {
      case KikiMood.happy:
        return 'assets/images/kiki/kiki_success.png';
      case KikiMood.warning:
        return 'assets/images/kiki/kiki_warning.png';
      case KikiMood.overbudget:
        return 'assets/images/kiki/kiki_overbudget.png';
      case KikiMood.neutral:
      default:
        return 'assets/images/kiki/kiki_neutral.png';
    }
  }
}