import 'dart:async';
import 'package:flutter/material.dart';

import 'kiki_message_card.dart';

class KikiAssistant extends StatefulWidget {
  final KikiMood mood;
  final String message;

  /// si quieres que se oculte solo
  final Duration autoHideAfter;

  /// posición en pantalla
  final EdgeInsets margin;

  /// mostrar bubble al entrar (y luego auto-hide)
  final bool showOnStart;

  /// botón de acción opcional dentro del bubble
  final String? actionLabel;
  final VoidCallback? onAction;

  /// botón para dismiss (nuevo mes)
  final VoidCallback? onDismiss;

  const KikiAssistant({
    super.key,
    required this.mood,
    required this.message,
    this.autoHideAfter = const Duration(seconds: 4),
    this.margin = const EdgeInsets.only(right: 16, bottom: 16),
    this.showOnStart = true,
    this.actionLabel,
    this.onAction,
    this.onDismiss,
  });

  @override
  State<KikiAssistant> createState() => _KikiAssistantState();
}

class _KikiAssistantState extends State<KikiAssistant> {
  bool _showBubble = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    if (widget.showOnStart) {
      // lo mostramos al cargar (post-frame)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _openBubble();
      });
    }
  }

  void _openBubble() {
    setState(() => _showBubble = true);

    _timer?.cancel();
    _timer = Timer(widget.autoHideAfter, () {
      if (!mounted) return;
      setState(() => _showBubble = false);
    });
  }

  void _toggleBubble() {
    setState(() => _showBubble = !_showBubble);

    _timer?.cancel();
    if (_showBubble) {
      _timer = Timer(widget.autoHideAfter, () {
        if (!mounted) return;
        setState(() => _showBubble = false);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _kikiAssetForMood(KikiMood mood) {
    switch (mood) {
      case KikiMood.happy:
        return 'assets/images/kiki/kiki_happy.png';
      case KikiMood.warning:
        return 'assets/images/kiki/kiki_warning.png';
      case KikiMood.overbudget:
        return 'assets/images/kiki/kiki_overbudget.png';
      case KikiMood.neutral:
      default:
        return 'assets/images/kiki/kiki_neutral.png';
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
          // 🗨️ bubble
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _showBubble
                ? Container(
                    key: const ValueKey('bubble'),
                    constraints: const BoxConstraints(maxWidth: 320),
                    margin: const EdgeInsets.only(bottom: 10),
                    child: _SpeechBubble(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          KikiMessageCard(
                            mood: widget.mood,
                            message: widget.message,
                            compact: true,
                            showAvatar: false, // ✅
                          ),

                          if (widget.actionLabel != null && widget.onAction != null) ...[
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: widget.onAction,
                                child: Text(widget.actionLabel!),
                              ),
                            ),
                          ],

                          if (widget.onDismiss != null) ...[
                            const SizedBox(height: 6),
                            TextButton(
                              onPressed: widget.onDismiss,
                              child: const Text('Entendido'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  )
                : const SizedBox.shrink(key: ValueKey('empty')),
          ),

          // 🐱 floating button (kiki)
          GestureDetector(
            onTap: _toggleBubble,
            child: Container(
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
