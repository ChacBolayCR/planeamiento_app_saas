import 'dart:async';
import 'package:flutter/material.dart';

import 'kiki_message_card.dart';

class KikiAssistant extends StatefulWidget {
  final KikiMood mood;
  final String message;
  final Duration autoHideAfter;
  final EdgeInsets margin;
  final bool showOnStart;

  final String? actionLabel;
  final VoidCallback? onAction;

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

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void initState() {
    super.initState();

    if (widget.showOnStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _openBubble();
      });
    }
  }

  @override
  void didUpdateWidget(covariant KikiAssistant oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Si cambia el mensaje/mood, reiniciamos el timer para evitar estados raros.
    if (oldWidget.message != widget.message || oldWidget.mood != widget.mood) {
      _cancelTimer();
      if (_showBubble) {
        _startAutoHide();
      }
    }
  }

  void _startAutoHide() {
    _cancelTimer();
    _timer = Timer(widget.autoHideAfter, () {
      if (!mounted) return;
      if (!_showBubble) return;
      setState(() => _showBubble = false);
    });
  }

  void _openBubble() {
    if (!mounted) return;
    setState(() => _showBubble = true);
    _startAutoHide();
  }

  void _toggleBubble() {
    if (!mounted) return;

    setState(() => _showBubble = !_showBubble);

    if (_showBubble) {
      _startAutoHide();
    } else {
      _cancelTimer();
    }
  }

  @override
  void deactivate() {
    // ✅ Esto mata timers incluso si la pantalla se está quitando del árbol por navegación.
    _cancelTimer();
    super.deactivate();
  }

  @override
  void dispose() {
    _cancelTimer();
    super.dispose();
  }

  String _kikiAssetForMood(KikiMood mood) {
    switch (mood) {
      case KikiMood.happy:
        return 'assets/images/kiki/kiki_success.png';
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
                            showAvatar: false,
                          ),
                          if (widget.actionLabel != null &&
                              widget.onAction != null) ...[
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