import 'package:flutter/material.dart';
import 'kiki_message_card.dart';

class KikiAssistant extends StatefulWidget {
  final KikiMood mood;
  final String message;

  /// posición en pantalla
  final EdgeInsets margin;

  /// ✅ opcional: si quieres permitir cerrar el mensaje (ej: nuevo mes)
  final VoidCallback? onDismiss;

  const KikiAssistant({
    super.key,
    required this.mood,
    required this.message,
    this.margin = const EdgeInsets.only(right: 16, bottom: 16),
    this.onDismiss,
  });

  @override
  State<KikiAssistant> createState() => _KikiAssistantState();
}

class _KikiAssistantState extends State<KikiAssistant> {
  String _kikiAssetForMood(KikiMood mood) {
    switch (mood) {
      case KikiMood.happy:
        return 'assets/images/kiki/kiki_happy.png';
      case KikiMood.warning:
        return 'assets/images/kiki/kiki_warning.png';
      case KikiMood.neutral:
      default:
        return 'assets/images/kiki/kiki_main.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: widget.margin.right,
      bottom: widget.margin.bottom,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // ✅ Globo SIEMPRE visible, pero sin avatar interno
          Container(
            constraints: const BoxConstraints(maxWidth: 320),
            margin: const EdgeInsets.only(bottom: 10),
            child: _SpeechBubble(
              child: Stack(
                children: [
                  KikiMessageCard(
                    mood: widget.mood,
                    message: widget.message,
                    compact: true,
                    showAvatar: false, // ✅ clave para evitar redundancia
                  ),
                  if (widget.onDismiss != null)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: InkWell(
                        onTap: widget.onDismiss,
                        borderRadius: BorderRadius.circular(999),
                        child: const Padding(
                          padding: EdgeInsets.all(6),
                          child: Icon(Icons.close, size: 16),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // 🐱 botón flotante con la imagen de Kiki
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.all(6),
            child: ClipOval(
              child: Image.asset(
                _kikiAssetForMood(widget.mood),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpeechBubble extends StatelessWidget {
  final Widget child;

  const _SpeechBubble({required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: child,
        ),
        Positioned(
          right: 18,
          bottom: -6,
          child: Transform.rotate(
            angle: 0.45,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
