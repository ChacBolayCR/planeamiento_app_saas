class FinancialProfile {
  final List<String> selectedIncomeTypes;
  final List<String> selectedExpenseCategories;
  final String? primaryGoal;
  final bool onboardingCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  FinancialProfile({
    required this.selectedIncomeTypes,
    required this.selectedExpenseCategories,
    required this.primaryGoal,
    required this.onboardingCompleted,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FinancialProfile.empty() {
    final now = DateTime.now();
    return FinancialProfile(
      selectedIncomeTypes: const [],
      selectedExpenseCategories: const [],
      primaryGoal: null,
      onboardingCompleted: false,
      createdAt: now,
      updatedAt: now,
    );
  }

  FinancialProfile copyWith({
    List<String>? selectedIncomeTypes,
    List<String>? selectedExpenseCategories,
    String? primaryGoal,
    bool? onboardingCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FinancialProfile(
      selectedIncomeTypes: selectedIncomeTypes ?? this.selectedIncomeTypes,
      selectedExpenseCategories:
          selectedExpenseCategories ?? this.selectedExpenseCategories,
      primaryGoal: primaryGoal ?? this.primaryGoal,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'selectedIncomeTypes': selectedIncomeTypes,
      'selectedExpenseCategories': selectedExpenseCategories,
      'primaryGoal': primaryGoal,
      'onboardingCompleted': onboardingCompleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory FinancialProfile.fromMap(Map<String, dynamic> map) {
    final now = DateTime.now();
    return FinancialProfile(
      selectedIncomeTypes:
          (map['selectedIncomeTypes'] as List?)?.whereType<String>().toList() ??
              const [],
      selectedExpenseCategories: (map['selectedExpenseCategories'] as List?)
              ?.whereType<String>()
              .toList() ??
          const [],
      primaryGoal: map['primaryGoal'] as String?,
      onboardingCompleted: map['onboardingCompleted'] as bool? ?? false,
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? now,
      updatedAt: DateTime.tryParse(map['updatedAt'] as String? ?? '') ?? now,
    );
  }
}
