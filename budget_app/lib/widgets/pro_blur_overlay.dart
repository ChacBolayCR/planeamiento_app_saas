import 'dart:ui';
import 'package:flutter/material.dart';

class ProBlurOverlay extends StatelessWidget {
  const ProBlurOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,

      // Ajusta esta altura: solo bloquea “lo Pro”
      child: SizedBox(
        height: 220,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              color: Colors.white.withOpacity(0.55),
              padding: const EdgeInsets.all(16),
              alignment: Alignment.center,
              child: const Text(
                '🔒 Desbloquea Pro para ver analítica completa',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
