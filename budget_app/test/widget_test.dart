import 'package:budget_app/models/expense.dart';
import 'package:budget_app/models/expense_category.dart';
import 'package:budget_app/models/financial_commitment.dart';
import 'package:budget_app/providers/budget_provider.dart';
import 'package:budget_app/providers/category_catalog_provider.dart';
import 'package:budget_app/providers/commitments_provider.dart';
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

  group('CategoryCatalog', () {
    test('includes Préstamos and its expected subcategories', () {
      final loans = CategoryCatalog.systemCategories.firstWhere(
        (category) => category.id == CategoryCatalog.loanCategoryId,
      );

      expect(loans.name, 'Préstamos');
      expect(
          loans.subcategories.map((item) => item.name), contains('Personal'));
      expect(
          loans.subcategories.map((item) => item.name), contains('Vivienda'));
      expect(
          loans.subcategories.map((item) => item.name), contains('Vehículo'));
      expect(loans.subcategories.map((item) => item.name),
          contains('Tarjeta de crédito'));
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
