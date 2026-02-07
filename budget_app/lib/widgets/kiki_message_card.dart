import 'package:flutter/material.dart';
import 'kiki_avatar.dart';

class KikiMessageCard extends StatelessWidget {
  final String? category;


  const KikiMessageCard({
    super.key,
    this.category,
  });

  /*String _message() {
    if (percentUsed == 0) {
      return 'Empezamos con calma 🐾\nBuen momento para planear bien.';
    } else if (percentUsed < 0.5) {
      return 'Vas excelente 💙\nEl control trae tranquilidad.';
    } else if (percentUsed < 0.8) {
      return 'Ojo por aquí 👀\nTodavía hay margen.';
    } else {
      return 'Cuidado 🐱⚠️\nQuizá toca frenar un poquito.';
    }
  }*/

  String _message() {
  switch (category) {
    case 'Comida':
      return 'Mucho en comida 🍕\n¿Probamos planear mejor?';
    case 'Servicios':
      return 'Servicios pesan 🧾\nTal vez revisar suscripciones.';
    case 'Transporte':
      return 'Movilidad activa 🚗\nBuen momento para optimizar.';
    default:
      return '';
  }
}


  /*Color _color() {
    if (percentUsed < 0.5) return Colors.green;
    if (percentUsed < 0.8) return Colors.orange;
    return Colors.red;
  }*/

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const KikiAvatar(
              state: KikiState.idle,
              size: 70,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                _message(),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        )
      ),
    );
  }
}
