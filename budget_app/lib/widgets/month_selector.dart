import 'package:flutter/material.dart';

class MonthSelector extends StatelessWidget {
  final DateTime selectedMonth;
  final ValueChanged<DateTime> onChanged;

  const MonthSelector({
    super.key,
    required this.selectedMonth,
    required this.onChanged,
  });

  String _label(DateTime d) => "${d.month}/${d.year}";

  DateTime _monthStart(DateTime d) => DateTime(d.year, d.month, 1);

  @override
  Widget build(BuildContext context) {
    final now = _monthStart(DateTime.now());
    final isCurrent = selectedMonth.year == now.year && selectedMonth.month == now.month;

    final prev = DateTime(selectedMonth.year, selectedMonth.month - 1, 1);
    final next = DateTime(selectedMonth.year, selectedMonth.month + 1, 1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
      child: Row(
        children: [
          IconButton(
            tooltip: 'Mes anterior',
            onPressed: () => onChanged(prev),
            icon: const Icon(Icons.chevron_left),
          ),

          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () async {
                final picked = await showModalBottomSheet<DateTime>(
                  context: context,
                  builder: (_) => _MonthPickerSheet(current: selectedMonth),
                );
                if (picked != null) onChanged(picked);
              },
              child: Center(
                child: Text(
                  "Mes: ${_label(selectedMonth)}",
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),

          if (!isCurrent)
            TextButton.icon(
              onPressed: () => onChanged(now),
              icon: const Icon(Icons.today, size: 18),
              label: const Text('Hoy'),
            )
          else
            const SizedBox(width: 8),

          IconButton(
            tooltip: 'Mes siguiente',
            onPressed: () => onChanged(next),
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}

class _MonthPickerSheet extends StatelessWidget {
  final DateTime current;
  const _MonthPickerSheet({required this.current});

  @override
  Widget build(BuildContext context) {
    DateTime prev = DateTime(current.year, current.month - 1, 1);
    DateTime next = DateTime(current.year, current.month + 1, 1);
    DateTime now = DateTime(DateTime.now().year, DateTime.now().month, 1);

    String fmt(DateTime d) => "${d.month}/${d.year}";

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Selecciona mes', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.chevron_left),
              title: Text(fmt(prev)),
              onTap: () => Navigator.pop(context, prev),
            ),
            ListTile(
              leading: const Icon(Icons.today),
              title: Text(fmt(now)),
              onTap: () => Navigator.pop(context, now),
            ),
            ListTile(
              leading: const Icon(Icons.chevron_right),
              title: Text(fmt(next)),
              onTap: () => Navigator.pop(context, next),
            ),
          ],
        ),
      ),
    );
  }
}
