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
    final t = _normalize(title);

    if (_containsAny(t, [
      'prestamo',
      'hipoteca',
      'cuota',
      'carro',
      'vehiculo',
      'universidad',
      'tarjeta',
    ])) {
      return 'Préstamos';
    }

    if (t.contains('cafe') || t.contains('comida')) return 'Comida';
    if (t.contains('uber') || t.contains('taxi')) return 'Transporte';
    if (t.contains('netflix') || t.contains('cine')) return 'Entretenimiento';

    return 'General';
  }

  static bool _containsAny(String value, List<String> terms) {
    return terms.any(value.contains);
  }

  static String _normalize(String value) {
    final lower = value.trim().toLowerCase();
    const from = 'áàäâãéèëêíìïîóòöôõúùüûñç';
    const to = 'aaaaaeeeeiiiiooooouuuunc';
    final buffer = StringBuffer();

    for (final rune in lower.runes) {
      final char = String.fromCharCode(rune);
      final index = from.indexOf(char);
      buffer.write(index >= 0 ? to[index] : char);
    }

    return buffer.toString();
  }
}
