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

    return SizedBox(
      height: 140, // 👈 altura controlada (clave)
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
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

              /// CONTENIDO FLEXIBLE (FIX REAL)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resumen',
                      style: t.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),

                    /// 👇 esto evita overflow
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          RichText(
                            text: TextSpan(
                              text: '$score',
                              style: t.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                              children: [
                                TextSpan(
                                  text: '/100',
                                  style: t.textTheme.bodySmall?.copyWith(
                                    color: Colors.black45,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _scoreLabel(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis, // 👈 FIX
                            style: t.textTheme.bodyMedium?.copyWith(
                              color: Colors.black54,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}