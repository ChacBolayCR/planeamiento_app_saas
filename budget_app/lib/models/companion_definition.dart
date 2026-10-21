class CompanionDefinition {
  final String id;
  final String name;
  final String assetPath;
  final String description;
  final bool isAvailable;
  final String? lockedMessage;

  const CompanionDefinition({
    required this.id,
    required this.name,
    required this.assetPath,
    required this.description,
    this.isAvailable = true,
    this.lockedMessage,
  });
}
