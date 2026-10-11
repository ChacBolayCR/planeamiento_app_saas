import 'package:flutter/material.dart';

import '../design_system/components/kiki_avatar_frame.dart';
import '../design_system/components/kiki_card.dart';
import '../models/financial_profile.dart';
import '../services/category_catalog.dart';
import '../utils/kiki_avatar_assets.dart';

enum KikiMood {
  happy,
  neutral,
  warning,
  overbudget,
  overBudget,
  noExpenses,
  healthy,
  goalProgress,
  achievement,
  inactive,
}

class KikiMessageCard extends StatelessWidget {
  final KikiMood mood;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool compact;
  final bool showAvatar;
  final String avatarId;

  const KikiMessageCard({
    super.key,
    required this.mood,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.compact = false,
    this.showAvatar = true,
    this.avatarId = FinancialProfile.defaultAvatarId,
  });

  @override
  Widget build(BuildContext context) {
    final padding = compact
        ? const EdgeInsets.all(12)
        : const EdgeInsets.fromLTRB(14, 14, 14, 10);

    return KikiCard(
      padding: padding,
      semanticLabel: 'Mensaje de Kiki',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showAvatar) ...[
                _CompanionAvatar(
                  mood: mood,
                  avatarId: avatarId,
                  size: compact ? 44 : 52,
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    fontSize: compact ? 14 : 15,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CompanionAvatar extends StatelessWidget {
  final KikiMood mood;
  final String avatarId;
  final double size;

  const _CompanionAvatar({
    required this.mood,
    required this.avatarId,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final companion = CategoryCatalog.companionForId(avatarId);

    return KikiAvatarFrame(
      assetPath: companion.assetPath == null
          ? null
          : avatarId == FinancialProfile.defaultAvatarId
              ? _assetForMood(mood)
              : companion.assetPath!,
      fallbackIcon: companion.fallbackIcon,
      size: size,
      padding: 3,
      semanticLabel: companion.name,
    );
  }

  String _assetForMood(KikiMood mood) {
    switch (mood) {
      case KikiMood.happy:
        return KikiAvatarAssets.happy;
      case KikiMood.noExpenses:
        return KikiAvatarAssets.wave;
      case KikiMood.healthy:
        return KikiAvatarAssets.happy;
      case KikiMood.warning:
        return KikiAvatarAssets.worried;
      case KikiMood.overbudget:
      case KikiMood.overBudget:
        return KikiAvatarAssets.sad;
      case KikiMood.goalProgress:
        return KikiAvatarAssets.saving;
      case KikiMood.achievement:
        return KikiAvatarAssets.celebrating;
      case KikiMood.inactive:
        return KikiAvatarAssets.rest;
      case KikiMood.neutral:
        return KikiAvatarAssets.neutral;
    }
  }
}
