import 'package:flutter/material.dart';

class MonthSelector extends StatelessWidget {
  const MonthSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final month = "${now.month}/${now.year}";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
          )
        ],
      ),
      child: Center(
        child: Text(
          "Mes actual: $month",
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
