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
    final buffer = StringBuffer();

    for (final rune in value.trim().toLowerCase().runes) {
      buffer.write(_normalizeRune(rune));
    }

    return buffer.toString();
  }

  static String _normalizeRune(int rune) {
    return switch (rune) {
      0x00E1 || 0x00E0 || 0x00E4 || 0x00E2 || 0x00E3 => 'a',
      0x00E9 || 0x00E8 || 0x00EB || 0x00EA => 'e',
      0x00ED || 0x00EC || 0x00EF || 0x00EE => 'i',
      0x00F3 || 0x00F2 || 0x00F6 || 0x00F4 || 0x00F5 => 'o',
      0x00FA || 0x00F9 || 0x00FC || 0x00FB => 'u',
      0x00F1 => 'n',
      0x00E7 => 'c',
      _ => String.fromCharCode(rune),
    };
  }
}
