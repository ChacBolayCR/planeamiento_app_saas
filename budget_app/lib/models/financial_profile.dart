class FinancialProfile {
  static const defaultAvatarId = 'avatar_kiki';
  static const _unset = Object();

  final List<String> selectedIncomeTypes;
  final List<String> selectedExpenseCategories;
  final List<String> selectedGoals;
  final String? primaryGoal;
  final String selectedAvatarId;
  final bool onboardingCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  FinancialProfile({
    required this.selectedIncomeTypes,
    required this.selectedExpenseCategories,
    required this.selectedGoals,
    required this.primaryGoal,
    required this.selectedAvatarId,
    required this.onboardingCompleted,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FinancialProfile.empty() {
    final now = DateTime.now();
    return FinancialProfile(
      selectedIncomeTypes: const [],
      selectedExpenseCategories: const [],
      selectedGoals: const [],
      primaryGoal: null,
      selectedAvatarId: defaultAvatarId,
      onboardingCompleted: false,
      createdAt: now,
      updatedAt: now,
    );
  }

  FinancialProfile copyWith({
    List<String>? selectedIncomeTypes,
    List<String>? selectedExpenseCategories,
    List<String>? selectedGoals,
    Object? primaryGoal = _unset,
    String? selectedAvatarId,
    bool? onboardingCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FinancialProfile(
      selectedIncomeTypes: selectedIncomeTypes ?? this.selectedIncomeTypes,
      selectedExpenseCategories:
          selectedExpenseCategories ?? this.selectedExpenseCategories,
      selectedGoals: selectedGoals ?? this.selectedGoals,
      primaryGoal:
          primaryGoal == _unset ? this.primaryGoal : primaryGoal as String?,
      selectedAvatarId: selectedAvatarId ?? this.selectedAvatarId,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'selectedIncomeTypes': selectedIncomeTypes,
      'selectedExpenseCategories': selectedExpenseCategories,
      'selectedGoals': selectedGoals,
      'primaryGoal': primaryGoal,
      'selectedAvatarId': selectedAvatarId,
      'onboardingCompleted': onboardingCompleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory FinancialProfile.fromMap(Map<String, dynamic> map) {
    final now = DateTime.now();
    final primaryGoal = map['primaryGoal'] as String?;
    final selectedGoals =
        (map['selectedGoals'] as List?)?.whereType<String>().toList() ??
            const [];

    return FinancialProfile(
      selectedIncomeTypes:
          (map['selectedIncomeTypes'] as List?)?.whereType<String>().toList() ??
              const [],
      selectedExpenseCategories: (map['selectedExpenseCategories'] as List?)
              ?.whereType<String>()
              .toList() ??
          const [],
      selectedGoals: selectedGoals.isEmpty && primaryGoal != null
          ? [primaryGoal]
          : selectedGoals,
      primaryGoal: primaryGoal,
      selectedAvatarId: _validAvatarId(map['selectedAvatarId'] as String?),
      onboardingCompleted: map['onboardingCompleted'] as bool? ?? false,
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? now,
      updatedAt: DateTime.tryParse(map['updatedAt'] as String? ?? '') ?? now,
    );
  }

  static String _validAvatarId(String? value) {
    return switch (value) {
      'avatar_kiki' || 'avatar_ra' || 'avatar_osi' => value!,
      _ => defaultAvatarId,
    };
  }
}
