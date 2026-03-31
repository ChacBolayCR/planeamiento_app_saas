import 'package:flutter/material.dart';

class MonthlyOverviewCard extends StatelessWidget {
  final double budget;
  final double spent;
  final String currencySymbol;

  const MonthlyOverviewCard({
    super.key,
    required this.budget,
    required this.spent,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = budget - spent;

    final double percentUsed =
        budget <= 0 ? 0.0 : (spent / budget).clamp(0.0, 1.0);

    return SizedBox(
      height: 130, // 👈 un poco más compacto
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14), // 👈 menos padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Resumen del mes',
                style: TextStyle(color: Colors.black54),
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: _MiniStat(
                      label: 'Gastado',
                      value:
                          '$currencySymbol${spent.toStringAsFixed(0)}',
                      valueStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MiniStat(
                      label: 'Restante',
                      value:
                          '$currencySymbol${remaining.toStringAsFixed(0)}',
                      valueStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color:
                            remaining >= 0 ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: percentUsed,
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle valueStyle;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: valueStyle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis, // 👈 anti overflow extra
        ),
      ],
    );
  }
}