import '../models/companion_definition.dart';
import '../models/financial_profile.dart';
import '../utils/kiki_avatar_assets.dart';

class CompanionCatalog {
  static const companions = [
    CompanionDefinition(
      id: FinancialProfile.defaultAvatarId,
      name: 'Kiki',
      assetPath: KikiAvatarAssets.neutral,
      description: 'Siempre lista para ayudarte.',
    ),
  ];

  static List<CompanionDefinition> get available =>
      companions.where((item) => item.isAvailable).toList(growable: false);

  static CompanionDefinition byId(String id) {
    return companions.firstWhere(
      (item) => item.id == id,
      orElse: () => companions.first,
    );
  }
}
