import 'package:flutter/material.dart';

import '../design_system/components/kiki_card.dart';
import '../design_system/kiki_colors.dart';
import '../design_system/kiki_radius.dart';
import '../design_system/kiki_spacing.dart';
import '../models/companion_definition.dart';
import '../services/companion_catalog.dart';

class CompanionSelectorSheet extends StatelessWidget {
  final String selectedAvatarId;

  const CompanionSelectorSheet({
    super.key,
    required this.selectedAvatarId,
  });

  @override
  Widget build(BuildContext context) {
    final companions = CompanionCatalog.companions;
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          KikiSpacing.lg,
          KikiSpacing.md,
          KikiSpacing.lg,
          KikiSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              child: Container(
                width: 44,
                height: 4,
                margin: const EdgeInsets.only(bottom: KikiSpacing.lg),
                decoration: BoxDecoration(
                  color: KikiColors.border,
                  borderRadius: BorderRadius.circular(KikiRadius.pill),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Selecciona tu compañero',
                    key: const ValueKey('companion_selector_title'),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Cerrar',
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: KikiSpacing.sm),
            Text(
              'Kiki está disponible hoy. Ra y Osi llegarán cuando existan sus assets oficiales.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: KikiSpacing.lg),
            LayoutBuilder(
              builder: (context, constraints) {
                final narrow = constraints.maxWidth < 360;
                return Wrap(
                  spacing: KikiSpacing.md,
                  runSpacing: KikiSpacing.md,
                  children: companions
                      .map(
                        (companion) => SizedBox(
                          width: narrow ? constraints.maxWidth : 200,
                          child: CompanionSelectorCard(
                            companion: companion,
                            selected: companion.id == selectedAvatarId,
                          ),
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class CompanionSelectorCard extends StatelessWidget {
  final CompanionDefinition companion;
  final bool selected;

  const CompanionSelectorCard({
    super.key,
    required this.companion,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enabled = companion.isAvailable;

    return KikiCard(
      key: ValueKey('companion_option_${companion.id}'),
      onTap: enabled ? () => Navigator.pop(context, companion.id) : null,
      variant:
          selected ? KikiCardVariant.highlighted : KikiCardVariant.standard,
      semanticLabel: companion.name,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            companion.assetPath,
            height: 108,
            fit: BoxFit.contain,
            alignment: Alignment.center,
          ),
          const SizedBox(height: KikiSpacing.sm),
          Text(
            companion.name,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: KikiSpacing.xs),
          Text(
            companion.description,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall,
          ),
          if (selected) ...[
            const SizedBox(height: KikiSpacing.sm),
            const Icon(Icons.check_circle, color: KikiColors.primary),
          ],
        ],
      ),
    );
  }
}
