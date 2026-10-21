import 'package:flutter/material.dart';

import '../kiki_colors.dart';

class KikiAvatarFrame extends StatelessWidget {
  final String? assetPath;
  final ImageProvider? imageProvider;
  final IconData fallbackIcon;
  final double size;
  final double padding;
  final bool selected;
  final bool showBackground;
  final String? semanticLabel;

  const KikiAvatarFrame({
    super.key,
    this.assetPath,
    this.imageProvider,
    this.fallbackIcon = Icons.auto_awesome_outlined,
    this.size = 64,
    this.padding = 4,
    this.selected = false,
    this.showBackground = false,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ImageProvider? provider =
        imageProvider ?? (assetPath == null ? null : AssetImage(assetPath!));

    return Semantics(
      image: true,
      selected: selected,
      label: semanticLabel,
      child: Container(
        width: size,
        height: size,
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: showBackground
              ? KikiColors.primary.withValues(alpha: selected ? 0.16 : 0.08)
              : Colors.transparent,
          shape: BoxShape.circle,
          border:
              selected ? Border.all(color: KikiColors.primary, width: 2) : null,
        ),
        child: provider == null
            ? Icon(
                fallbackIcon,
                size: size * 0.46,
                color: theme.colorScheme.primary,
              )
            : Image(
                image: provider,
                fit: BoxFit.contain,
                alignment: Alignment.center,
              ),
      ),
    );
  }
}
