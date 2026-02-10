import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthSelector extends StatelessWidget {
  final DateTime selectedMonth;
  final ValueChanged<DateTime> onChanged;

  const MonthSelector({
    super.key,
    required this.selectedMonth,
    required this.onChanged,
  });

  DateTime _toMonth(DateTime d) => DateTime(d.year, d.month);

  @override
  Widget build(BuildContext context) {
    final label = DateFormat('MMMM yyyy').format(selectedMonth);
    final pretty = label.isEmpty
        ? ''
        : label[0].toUpperCase() + label.substring(1);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
          )
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              final prev = DateTime(selectedMonth.year, selectedMonth.month - 1);
              onChanged(_toMonth(prev));
            },
          ),
          Expanded(
            child: Center(
              child: Text(
                pretty,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              final next = DateTime(selectedMonth.year, selectedMonth.month + 1);
              onChanged(_toMonth(next));
            },
          ),
        ],
      ),
    );
  }
}
