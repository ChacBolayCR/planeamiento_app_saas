class SmartExpenseParser {
  static ({String title, double? amount}) parse(String input) {
    final parts = input.trim().split(' ');

    

    if (parts.isEmpty) {
      return (title: '', amount: null);
    }

    double? amount;
    String title = input;

    final last = parts.last.replaceAll(',', '.');

    final parsedAmount = double.tryParse(last);

    if (parsedAmount != null) {
      amount = parsedAmount;
      title = parts.sublist(0, parts.length - 1).join(' ');
    }

    return (
      title: title.trim(),
      amount: amount,
    );
  }
  
  static String detectCategory(String title) {
    final t = title.toLowerCase();

    if (t.contains('Café') || t.contains('comida')) return 'Comida';
    if (t.contains('uber') || t.contains('taxi')) return 'Transporte';
    if (t.contains('netflix') || t.contains('cine')) return 'Entretenimiento';

    return 'General';
  }
}