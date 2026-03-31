import 'package:flutter/material.dart';

class ProBlurOverlay extends StatelessWidget {
  final double height;
  final VoidCallback? onUpgrade;

  const ProBlurOverlay({
    super.key,
    this.height = 220,
    this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: IgnorePointer(
        ignoring: false,
        child: SizedBox(
          height: height,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: Stack(
              children: [
                // Blur real
                /*BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: const SizedBox.expand(),
                ),*/

                // Degradado para que se vea premium y no “parche”
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(0.10),
                        Colors.white.withOpacity(0.85),
                      ],
                    ),
                  ),
                ),

                // Texto (opcional)
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      '🔒 Desbloquea Pro para ver analítica completa',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}