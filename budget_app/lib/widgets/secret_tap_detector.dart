import 'dart:async';
import 'package:flutter/material.dart';

class SecretTapDetector extends StatefulWidget {
  final Widget child;
  final int tapsRequired;
  final Duration window;
  final VoidCallback onUnlocked;

  const SecretTapDetector({
    super.key,
    required this.child,
    required this.onUnlocked,
    this.tapsRequired = 7,
    this.window = const Duration(seconds: 2),
  });

  @override
  State<SecretTapDetector> createState() => _SecretTapDetectorState();
}

class _SecretTapDetectorState extends State<SecretTapDetector> {
  int _taps = 0;
  Timer? _timer;

  void _registerTap() {
    _timer ??= Timer(widget.window, () {
      _taps = 0;
      _timer?.cancel();
      _timer = null;
    });

    _taps++;

    if (_taps >= widget.tapsRequired) {
      _taps = 0;
      _timer?.cancel();
      _timer = null;
      widget.onUnlocked();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _registerTap,
      behavior: HitTestBehavior.translucent,
      child: widget.child,
    );
  }
}