import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

enum KikiState { idle, happy, warning, alert }

class KikiAvatar extends StatelessWidget {
  final KikiState state;
  final double size;

  const KikiAvatar({
    super.key,
    required this.state,
    this.size = 64,
  });

  String get _animation {
    switch (state) {
      case KikiState.happy:
        return 'assets/lottie/kiki_happy.json';
      case KikiState.warning:
        return 'assets/lottie/kiki_warning.json';
      case KikiState.alert:
        return 'assets/lottie/kiki_alert.json';
      case KikiState.idle:
      default:
        return 'assets/lottie/kiki_idle.json';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Lottie.asset(
        _animation,
        fit: BoxFit.contain,
      ),
    );
  }
}
