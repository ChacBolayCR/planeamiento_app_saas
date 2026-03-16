class Achievement {
  final String id;
  final String title;
  final String description;
  final bool unlocked;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    this.unlocked = false,
  });

  Achievement copyWith({bool? unlocked}) {
    return Achievement(
      id: id,
      title: title,
      description: description,
      unlocked: unlocked ?? this.unlocked,
    );
  }
}
