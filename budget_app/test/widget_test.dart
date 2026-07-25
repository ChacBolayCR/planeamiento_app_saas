import 'package:budget_app/models/expense.dart';
import 'package:budget_app/models/expense_category.dart';
import 'package:budget_app/models/financial_commitment.dart';
import 'package:budget_app/models/financial_profile.dart';
import 'package:budget_app/providers/budget_provider.dart';
import 'package:budget_app/providers/category_catalog_provider.dart';
import 'package:budget_app/providers/commitments_provider.dart';
import 'package:budget_app/providers/financial_profile_provider.dart';
import 'package:budget_app/services/category_catalog.dart';
import 'package:budget_app/services/streak_service.dart';
import 'package:budget_app/utils/smart_expense_parser.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('monthKey', () {
    test('formats year and month with leading zero', () {
      expect(monthKey(DateTime(2026, 1, 15)), '2026-01');
      expect(monthKey(DateTime(2026, 11, 1)), '2026-11');
    });
  });

  group('FinancialProfile', () {
    test('round-trips toMap/fromMap', () {
      final profile = FinancialProfile(
        selectedIncomeTypes: const ['income_salary', 'income_sales'],
        selectedExpenseCategories: const ['expense_housing'],
        primaryGoal: 'goal_reduce_debt',
        onboardingCompleted: true,
        createdAt: DateTime(2026, 7, 24),
        updatedAt: DateTime(2026, 7, 24, 12),
      );

      final restored = FinancialProfile.fromMap(profile.toMap());

      expect(restored.selectedIncomeTypes, ['income_salary', 'income_sales']);
      expect(restored.selectedExpenseCategories, ['expense_housing']);
      expect(restored.primaryGoal, 'goal_reduce_debt');
      expect(restored.onboardingCompleted, isTrue);
    });
  });

  group('FinancialProfileProvider', () {
    test('persists profile and completed onboarding', () async {
      final provider = FinancialProfileProvider();
      await provider.init();

      await provider.completeOnboarding(
        incomeTypes: const ['income_salary', 'income_sales'],
        expenseCategories: const ['expense_housing', 'expense_transport'],
        primaryGoal: 'goal_organize_budget',
      );

      final restored = FinancialProfileProvider();
      await restored.init();

      expect(restored.onboardingCompleted, isTrue);
      expect(restored.profile.selectedIncomeTypes, contains('income_salary'));
      expect(restored.profile.selectedExpenseCategories,
          contains('expense_transport'));
      expect(restored.profile.primaryGoal, 'goal_organize_budget');
    });

    test('supports skipped onboarding', () async {
      final provider = FinancialProfileProvider();
      await provider.init();

      await provider.completeOnboarding(
        incomeTypes: const [],
        expenseCategories: const [],
        primaryGoal: null,
      );

      expect(provider.onboardingCompleted, isTrue);
      expect(provider.profile.selectedIncomeTypes, isEmpty);
      expect(provider.profile.selectedExpenseCategories, isEmpty);
    });

    test('updates multiple income and expense selections plus single goal',
        () async {
      final provider = FinancialProfileProvider();
      await provider.init();

      await provider
          .updateIncomeTypes(const ['income_salary', 'income_business']);
      await provider
          .updateExpenseCategories(const ['expense_food', 'expense_health']);
      await provider.updatePrimaryGoal('goal_save_more');

      expect(provider.profile.selectedIncomeTypes,
          ['income_salary', 'income_business']);
      expect(provider.profile.selectedExpenseCategories,
          ['expense_food', 'expense_health']);
      expect(provider.profile.primaryGoal, 'goal_save_more');
    });

    test('reset preferences does not clear existing financial data', () async {
      final budget = BudgetProvider();
      final provider = FinancialProfileProvider();
      await budget.init();
      await provider.init();

      budget.addExpense(
        Expense(
          title: 'Taxi',
          category: 'Transporte',
          amount: 2500,
          date: DateTime(2026, 7, 24),
        ),
      );
      await provider.completeOnboarding(
        incomeTypes: const ['income_salary'],
        expenseCategories: const ['expense_transport'],
        primaryGoal: 'goal_control_expenses',
      );
      await provider.resetOnboarding();

      expect(provider.onboardingCompleted, isTrue);
      expect(provider.profile.selectedExpenseCategories, isEmpty);
      expect(budget.currentMonthExpenses.length, 1);
    });
  });

  group('CategoryCatalog', () {
    test('includes Préstamos and its expected subcategories', () {
      final loans = CategoryCatalog.systemCategories.firstWhere(
        (category) => category.id == CategoryCatalog.loanCategoryId,
      );

      expect(loans.name, 'Préstamos');
      expect(loans.subcategories.map((item) => item.name),
          contains('Compras a cuotas'));
      expect(loans.subcategories.map((item) => item.name),
          contains('Tarjetas de crédito'));
      expect(loans.subcategories.map((item) => item.name),
          contains('Préstamo personal'));
      expect(loans.subcategories.map((item) => item.name),
          contains('Préstamo de vehículo'));
      expect(loans.subcategories.map((item) => item.name),
          contains('Préstamo de vivienda'));
    });

    test('maps chosen expense categories to category ids first', () {
      final ids = CategoryCatalog.categoryIdsForProfileExpenseIds(
        const ['expense_debt_loans', 'expense_food'],
      );

      expect(ids.first, CategoryCatalog.loanCategoryId);
      expect(ids, contains('food'));
    });

    test('full catalog remains available beyond selected profile categories',
        () {
      final selected = CategoryCatalog.categoryIdsForProfileExpenseIds(
        const ['expense_food'],
      );
      final allIds =
          CategoryCatalog.systemCategories.map((item) => item.id).toList();

      expect(selected, ['food']);
      expect(allIds, contains(CategoryCatalog.loanCategoryId));
      expect(allIds.length, greaterThan(selected.length));
    });
    test('normalizes names for duplicate checks', () {
      expect(ExpenseCategory.normalizeKey('  Café '), 'cafe');
      expect(ExpenseCategory.normalizeKey('Tarjeta de crédito'),
          'tarjetadecredito');
    });
  });

  group('CategoryCatalogProvider', () {
    test('creates custom categories and prevents duplicates', () async {
      final provider = CategoryCatalogProvider();
      await provider.init();

      final created = await provider.addCustomCategory('Mascota');
      final duplicate = await provider.addCustomCategory('  mascota ');

      expect(created, isNotNull);
      expect(created!.name, 'Mascota');
      expect(duplicate, isNull);
      expect(provider.categoryExists('MASCÓTA'), isTrue);
    });

    test('creates custom subcategories under the active category', () async {
      final provider = CategoryCatalogProvider();
      await provider.init();

      final created = await provider.addCustomSubcategory('food', 'Merienda');
      final duplicate =
          await provider.addCustomSubcategory('food', ' merienda ');

      expect(created, isNotNull);
      expect(created!.name, 'Merienda');
      expect(duplicate, isNull);
      expect(provider.subcategoryExists('food', 'MERIENDA'), isTrue);
    });
  });

  test('custom categories stay compatible with profile personalization',
      () async {
    final provider = CategoryCatalogProvider();
    await provider.init();
    final custom = await provider.addCustomCategory('Mascota');

    final selected = CategoryCatalog.categoryIdsForProfileExpenseIds(
      const ['expense_food'],
    );
    final categories = provider.categories;

    expect(custom, isNotNull);
    expect(selected, ['food']);
    expect(categories.any((category) => category.id == custom!.id), isTrue);
  });
  group('SmartExpenseParser', () {
    test('extracts amount from the end of a description', () {
      final parsed = SmartExpenseParser.parse('Café 1500');

      expect(parsed.title, 'Café');
      expect(parsed.amount, 1500);
    });

    test('detects known categories and falls back to General', () {
      expect(SmartExpenseParser.detectCategory('café'), 'Comida');
      expect(SmartExpenseParser.detectCategory('taxi'), 'Transporte');
      expect(SmartExpenseParser.detectCategory('papelería'), 'General');
    });

    test('suggests Préstamos for loan-related terms', () {
      expect(SmartExpenseParser.detectCategory('cuota carro'), 'Préstamos');
      expect(SmartExpenseParser.detectCategory('prestamo universidad'),
          'Préstamos');
      expect(SmartExpenseParser.detectCategory('tarjeta crédito'), 'Préstamos');
    });
  });

  group('Expense.fromMap', () {
    test('restores expense fields from persisted map', () {
      final date = DateTime(2026, 7, 21);
      final expense = Expense.fromMap({
        'id': 'expense-1',
        'title': 'Café',
        'category': 'Comida',
        'amount': 1500.0,
        'date': date.toIso8601String(),
      });

      expect(expense.id, 'expense-1');
      expect(expense.title, 'Café');
      expect(expense.category, 'Comida');
      expect(expense.categoryName, 'Comida');
      expect(expense.categoryId, 'food');
      expect(expense.amount, 1500.0);
      expect(expense.date, date);
    });

    test('accepts legacy maps that only have category', () {
      final expense = Expense.fromMap({
        'title': 'Taxi',
        'category': 'Transporte',
        'amount': 3500,
        'date': DateTime(2026, 7, 21).toIso8601String(),
      });

      expect(expense.category, 'Transporte');
      expect(expense.categoryId, 'transport');
      expect(expense.subcategoryId, isNull);
    });
  });

  group('FinancialCommitment', () {
    test('round-trips toMap/fromMap and calculates remaining balance', () {
      final commitment = FinancialCommitment(
        id: 'loan-1',
        name: 'Préstamo del vehículo',
        categoryId: CategoryCatalog.loanCategoryId,
        subcategoryId: 'vehiculo',
        monthlyAmount: 185000,
        totalAmount: 9500000,
        paidAmount: 1110000,
        startDate: DateTime(2026, 1, 1),
        nextPaymentDate: DateTime(2026, 8, 5),
        paymentDay: 5,
        totalInstallments: 60,
        paidInstallments: 6,
      );

      final restored = FinancialCommitment.fromMap(commitment.toMap());

      expect(restored.totalAmount, 9500000);
      expect(restored.paidAmount, 1110000);
      expect(restored.remainingBalance, 8390000);
      expect(restored.paidInstallments, 6);
    });
  });

  group('CommitmentsProvider', () {
    test(
        'marks a payment as paid, advances nextPaymentDate, and avoids duplicates',
        () async {
      final budget = BudgetProvider();
      final commitments = CommitmentsProvider();
      await budget.init();
      await commitments.init();

      final commitment = FinancialCommitment(
        id: 'loan-1',
        name: 'Préstamo del vehículo',
        categoryId: CategoryCatalog.loanCategoryId,
        subcategoryId: 'vehiculo',
        monthlyAmount: 185000,
        totalAmount: 9500000,
        paidAmount: 1110000,
        startDate: DateTime(2026, 1, 1),
        nextPaymentDate: DateTime(2026, 8, 5),
        paymentDay: 5,
        totalInstallments: 60,
        paidInstallments: 6,
      );

      await commitments.addCommitment(commitment);

      final firstPaid = await commitments.markPaymentAsPaid(
        commitmentId: commitment.id,
        budgetProvider: budget,
      );
      final duplicatePaid = await commitments.markPaymentAsPaid(
        commitmentId: commitment.id,
        budgetProvider: budget,
      );
      final updated = commitments.commitments.first;

      expect(firstPaid, isTrue);
      expect(duplicatePaid, isFalse);
      expect(updated.paidAmount, 1295000);
      expect(updated.remainingBalance, 8205000);
      expect(updated.paidInstallments, 7);
      expect(updated.nextPaymentDate, DateTime(2026, 9, 5));
      expect(budget.currentMonthExpenses.length, 1);
      expect(budget.currentMonthExpenses.first.commitmentId, commitment.id);
    });
  });

  group('StreakService', () {
    test('returns zero when there are no expenses', () {
      expect(StreakService.calculateStreak(const []), 0);
    });

    test('counts consecutive expense days from the latest date', () {
      final expenses = [
        Expense(
          title: 'Día 1',
          category: 'General',
          amount: 1,
          date: DateTime(2026, 7, 21, 9),
        ),
        Expense(
          title: 'Día 2',
          category: 'General',
          amount: 1,
          date: DateTime(2026, 7, 20, 9),
        ),
        Expense(
          title: 'Día 3',
          category: 'General',
          amount: 1,
          date: DateTime(2026, 7, 19, 9),
        ),
      ];

      expect(StreakService.calculateStreak(expenses), 3);
    });
  });
}
