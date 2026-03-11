import 'package:flutter/material.dart';

class KikiScoreCard extends StatelessWidget {
  final int score;

  const KikiScoreCard({
    super.key,
    required this.score,
  });

  Color _scoreColor() {
    if (score >= 90) return const Color(0xFF43A047);
    if (score >= 75) return const Color(0xFF7CB342);
    if (score >= 60) return const Color(0xFFF9A825);
    return const Color(0xFFE53935);
  }

  String _scoreLabel() {
    if (score >= 90) return 'Excelente';
    if (score >= 75) return 'Muy bien';
    if (score >= 60) return 'Aceptable';
    return 'A mejorar';
  }

  @override
  Widget build(BuildContext context) {
    final color = _scoreColor();
    final t = Theme.of(context);

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.insights_rounded,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Score financiero',
                    style: t.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _scoreLabel(),
                    style: t.textTheme.bodyMedium?.copyWith(
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '$score/100',
              style: t.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}