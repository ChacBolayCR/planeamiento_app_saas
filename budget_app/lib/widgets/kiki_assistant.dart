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
    this.autoHideAfter = const Duration(seconds: 5),
    this.margin = const EdgeInsets.only(right: 16, bottom: 18),
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
  Timer? _floatingTimer;
  double _floatingOffset = 0;

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _startAutoHide() {
    _cancelTimer();
    _timer = Timer(widget.autoHideAfter, () {
      if (!mounted) return;
      if (!_showBubble) return;
      setState(() => _showBubble = false);
    });
  }

  void _startFloating() {
    _floatingTimer?.cancel();
    _floatingTimer = Timer.periodic(const Duration(milliseconds: 1400), (_) {
      if (!mounted) return;
      setState(() {
        _floatingOffset = _floatingOffset == 0 ? -6 : 0;
      });
    });
  }

  @override
  void initState() {
    super.initState();

    _startFloating();

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

    final changed = oldWidget.message != widget.message || oldWidget.mood != widget.mood;
    if (changed) {
      _cancelTimer();
      if (mounted) {
        setState(() => _showBubble = true);
        _startAutoHide();
      }
    }
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
    _cancelTimer();
    super.deactivate();
  }

  @override
  void dispose() {
    _cancelTimer();
    _floatingTimer?.cancel();
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

  Color _ringColor(BuildContext context) {
    switch (widget.mood) {
      case KikiMood.happy:
        return const Color(0xFF6DBB75);
      case KikiMood.warning:
        return const Color(0xFFE6A93D);
      case KikiMood.overbudget:
        return const Color(0xFFE36A6A);
      case KikiMood.neutral:
      default:
        return Theme.of(context).colorScheme.primary.withOpacity(0.28);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ringColor = _ringColor(context);

    return Positioned(
      right: widget.margin.right,
      bottom: widget.margin.bottom,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          IgnorePointer(
            ignoring: !_showBubble,
            child: AnimatedOpacity(
              opacity: _showBubble ? 1 : 0,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              child: AnimatedPadding(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                padding: EdgeInsets.only(bottom: _showBubble ? 12 : 0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    transform: Matrix4.translationValues(0, _showBubble ? 0 : 8, 0),
                    child: _SpeechBubble(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          KikiMessageCard(
                            mood: widget.mood,
                            message: widget.message,
                            compact: false,
                            showAvatar: false,
                          ),
                          if (widget.actionLabel != null && widget.onAction != null) ...[
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: widget.onAction,
                                  child: Text(widget.actionLabel!),
                                ),
                              ),
                            ),
                          ],
                          if (widget.onDismiss != null) ...[
                            Padding(
                              padding: const EdgeInsets.only(left: 8, right: 8, bottom: 6),
                              child: TextButton(
                                onPressed: widget.onDismiss,
                                child: const Text('Entendido'),
                              ),
                            ),
                          ] else
                            const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: _toggleBubble,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              transform: Matrix4.translationValues(0, _floatingOffset, 0),
              width: _showBubble ? 82 : 78,
              height: _showBubble ? 82 : 78,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: ringColor,
                  width: 2.4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: ringColor.withOpacity(0.18),
                    blurRadius: 20,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  _kikiAssetForMood(widget.mood),
                  fit: BoxFit.contain,
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
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.98),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: child,
        ),
        Positioned(
          right: 24,
          bottom: -7,
          child: Transform.rotate(
            angle: 0.75,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.98),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}