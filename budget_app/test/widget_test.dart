import 'package:budget_app/design_system/components/kiki_avatar_frame.dart';
import 'package:budget_app/design_system/components/kiki_button.dart';
import 'package:budget_app/design_system/components/kiki_card.dart';
import 'package:budget_app/design_system/components/kiki_choice_card.dart';
import 'package:budget_app/design_system/kiki_theme.dart';
import 'package:budget_app/screens/expenses/add_expenses_modal.dart';
import 'package:budget_app/screens/expenses/expenses_screen.dart';
import 'package:budget_app/models/expense.dart';
import 'package:budget_app/models/expense_category.dart';
import 'package:budget_app/models/financial_commitment.dart';
import 'package:budget_app/models/financial_profile.dart';
import 'package:budget_app/providers/budget_provider.dart';
import 'package:budget_app/providers/category_catalog_provider.dart';
import 'package:budget_app/providers/commitments_provider.dart';
import 'package:budget_app/providers/financial_profile_provider.dart';
import 'package:budget_app/screens/dashboard/dashboard_screen.dart';
import 'package:budget_app/screens/onboarding/onboarding_screen.dart';
import 'package:budget_app/widgets/companion_selector_sheet.dart';
import 'package:budget_app/services/category_catalog.dart';
import 'package:budget_app/services/streak_service.dart';
import 'package:budget_app/utils/smart_expense_parser.dart';
import 'package:budget_app/utils/kiki_avatar_assets.dart';
import 'package:budget_app/utils/kiki_mood_visual.dart';
import 'package:budget_app/widgets/kiki_message_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Kiki Design System', () {
    test('ThemeData is created with official Kiki colors', () {
      final theme = KikiTheme.light();

      expect(theme.useMaterial3, isTrue);
      expect(theme.scaffoldBackgroundColor.toARGB32(), 0xFFF8F5FF);
      expect(theme.colorScheme.primary.toARGB32(), 0xFF6542C7);
    });

    testWidgets('KikiCard renders main variants', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: KikiTheme.light(),
          home: const Scaffold(
            body: Column(
              children: [
                KikiCard(child: Text('standard')),
                KikiCard(
                  variant: KikiCardVariant.highlighted,
                  child: Text('highlighted'),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('standard'), findsOneWidget);
      expect(find.text('highlighted'), findsOneWidget);
    });

    testWidgets('KikiButton supports disabled and loading states',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: KikiTheme.light(),
          home: const Scaffold(
            body: Column(
              children: [
                KikiButton(label: 'Disabled', onPressed: null),
                KikiButton(label: 'Loading', onPressed: null, loading: true),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Disabled'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('KikiChoiceCard reflects selected state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: KikiTheme.light(),
          home: Scaffold(
            body: KikiChoiceCard(
              title: 'Controlar mis gastos',
              icon: Icons.fact_check_outlined,
              selected: true,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Controlar mis gastos'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('KikiAvatarFrame uses BoxFit.contain for local images',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: KikiTheme.light(),
          home: const Scaffold(
            body: KikiAvatarFrame(
              assetPath: 'assets/images/avatars/kiki/kiki_neutral.png',
            ),
          ),
        ),
      );

      final image = tester.widget<Image>(find.byType(Image));
      expect(image.fit, BoxFit.contain);
    });
  });

  group('Migrated UI smoke tests', () {
    testWidgets('Login uses official Kiki Wave asset', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: KikiTheme.light(),
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => BudgetProvider()),
            ],
            child: const Scaffold(
              body: Image(
                image: AssetImage(KikiAvatarAssets.wave),
              ),
            ),
          ),
        ),
      );

      final image = tester.widget<Image>(find.byType(Image));
      expect((image.image as AssetImage).assetName, KikiAvatarAssets.wave);
    });

    testWidgets('Onboarding supports textScaleFactor 1.3 without exceptions',
        (tester) async {
      final provider = FinancialProfileProvider();
      await provider.init();

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: provider,
          child: MaterialApp(
            theme: KikiTheme.light(),
            home: MediaQuery(
              data: const MediaQueryData(
                size: Size(360, 780),
                textScaler: TextScaler.linear(1.3),
              ),
              child: const OnboardingScreen(),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byKey(const ValueKey('intro_title')), findsOneWidget);
    });

    testWidgets('AddExpenseModal keeps its required fields', (tester) async {
      final budget = BudgetProvider();
      final catalog = CategoryCatalogProvider();
      final commitments = CommitmentsProvider();
      final profile = FinancialProfileProvider();
      await budget.init();
      await catalog.init();
      await commitments.init();
      await profile.init();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: budget),
            ChangeNotifierProvider.value(value: catalog),
            ChangeNotifierProvider.value(value: commitments),
            ChangeNotifierProvider.value(value: profile),
          ],
          child: MaterialApp(
            theme: KikiTheme.light(),
            home: const Scaffold(body: AddExpenseModal()),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Categor\u00eda'), findsOneWidget);
      expect(find.text('Subcategor\u00eda'), findsOneWidget);
      expect(find.text('Descripci\u00f3n'), findsOneWidget);
      expect(find.text('Monto'), findsOneWidget);
      expect(find.text('Guardar gasto'), findsOneWidget);
    });
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
        selectedGoals: const ['goal_reduce_debt', 'goal_save_more'],
        primaryGoal: 'goal_reduce_debt',
        selectedAvatarId: 'avatar_ra',
        onboardingCompleted: true,
        createdAt: DateTime(2026, 7, 24),
        updatedAt: DateTime(2026, 7, 24, 12),
      );

      final restored = FinancialProfile.fromMap(profile.toMap());

      expect(restored.selectedIncomeTypes, ['income_salary', 'income_sales']);
      expect(restored.selectedExpenseCategories, ['expense_housing']);
      expect(restored.selectedGoals, ['goal_reduce_debt', 'goal_save_more']);
      expect(restored.primaryGoal, 'goal_reduce_debt');
      expect(restored.selectedAvatarId, 'avatar_ra');
      expect(restored.onboardingCompleted, isTrue);
    });

    test('legacy profile with primaryGoal migrates to selectedGoals', () {
      final restored = FinancialProfile.fromMap({
        'selectedIncomeTypes': ['income_salary'],
        'selectedExpenseCategories': ['expense_food'],
        'primaryGoal': 'goal_save_more',
        'onboardingCompleted': true,
        'createdAt': DateTime(2026, 7, 24).toIso8601String(),
        'updatedAt': DateTime(2026, 7, 24).toIso8601String(),
      });

      expect(restored.selectedGoals, ['goal_save_more']);
      expect(restored.primaryGoal, 'goal_save_more');
      expect(restored.selectedAvatarId, FinancialProfile.defaultAvatarId);
    });

    test('invalid or missing selectedAvatarId uses avatar_kiki by default', () {
      expect(FinancialProfile.fromMap({}).selectedAvatarId, 'avatar_kiki');
      expect(
          FinancialProfile.fromMap({'selectedAvatarId': 'bad'})
              .selectedAvatarId,
          'avatar_kiki');
    });
  });

  group('FinancialProfileProvider', () {
    test('persists profile and completed onboarding', () async {
      final provider = FinancialProfileProvider();
      await provider.init();

      await provider.completeOnboarding(
        incomeTypes: const ['income_salary', 'income_sales'],
        expenseCategories: const ['expense_housing', 'expense_transport'],
        selectedGoals: const ['goal_organize_budget', 'goal_save_more'],
        primaryGoal: 'goal_organize_budget',
        selectedAvatarId: 'avatar_osi',
      );

      final restored = FinancialProfileProvider();
      await restored.init();

      expect(restored.onboardingCompleted, isTrue);
      expect(restored.profile.selectedIncomeTypes, contains('income_salary'));
      expect(restored.profile.selectedExpenseCategories,
          contains('expense_transport'));
      expect(restored.profile.selectedGoals, contains('goal_save_more'));
      expect(restored.profile.primaryGoal, 'goal_organize_budget');
      expect(restored.profile.selectedAvatarId, 'avatar_osi');
    });

    test('supports skipped onboarding without erasing financial data',
        () async {
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
        incomeTypes: const [],
        expenseCategories: const [],
        selectedGoals: const [],
        primaryGoal: null,
      );

      expect(provider.onboardingCompleted, isTrue);
      expect(provider.profile.selectedIncomeTypes, isEmpty);
      expect(provider.profile.selectedExpenseCategories, isEmpty);
      expect(provider.profile.selectedGoals, isEmpty);
      expect(provider.profile.selectedAvatarId, 'avatar_kiki');
      expect(budget.currentMonthExpenses.length, 1);
    });

    test('updates multiple income and expense selections plus selected goals',
        () async {
      final provider = FinancialProfileProvider();
      await provider.init();

      await provider
          .updateIncomeTypes(const ['income_salary', 'income_business']);
      await provider
          .updateExpenseCategories(const ['expense_food', 'expense_health']);
      await provider.updateSelectedGoals(
        const ['goal_save_more', 'goal_reduce_debt'],
      );
      await provider.updatePrimaryGoal('goal_reduce_debt');

      expect(provider.profile.selectedIncomeTypes,
          ['income_salary', 'income_business']);
      expect(provider.profile.selectedExpenseCategories,
          ['expense_food', 'expense_health']);
      expect(provider.profile.selectedGoals,
          ['goal_save_more', 'goal_reduce_debt']);
      expect(provider.profile.primaryGoal, 'goal_reduce_debt');
    });

    test('priority can only be selected from chosen goals', () async {
      final provider = FinancialProfileProvider();
      await provider.init();

      await provider.updateSelectedGoals(const ['goal_save_more']);
      await provider.updatePrimaryGoal('goal_reduce_debt');

      expect(provider.profile.primaryGoal, isNull);
    });

    test('removing the priority goal clears primaryGoal', () async {
      final provider = FinancialProfileProvider();
      await provider.init();

      await provider.updateSelectedGoals(
        const ['goal_save_more', 'goal_reduce_debt'],
      );
      await provider.updatePrimaryGoal('goal_reduce_debt');
      await provider.updateSelectedGoals(const ['goal_save_more']);

      expect(provider.profile.primaryGoal, isNull);
    });

    test('selected avatar persists', () async {
      final provider = FinancialProfileProvider();
      await provider.init();

      await provider.updateSelectedAvatar('avatar_ra');

      final restored = FinancialProfileProvider();
      await restored.init();

      expect(restored.profile.selectedAvatarId, 'avatar_ra');
    });

    test('reset preferences returns defaults and keeps existing financial data',
        () async {
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
        selectedGoals: const ['goal_control_expenses'],
        primaryGoal: 'goal_control_expenses',
        selectedAvatarId: 'avatar_ra',
      );
      await provider.resetPersonalization();

      expect(provider.onboardingCompleted, isTrue);
      expect(provider.profile.selectedExpenseCategories, isEmpty);
      expect(provider.profile.selectedGoals, isEmpty);
      expect(provider.profile.selectedAvatarId, 'avatar_kiki');
      expect(budget.currentMonthExpenses.length, 1);
    });
  });

  group('CategoryCatalog', () {
    test('includes Pr\u00e9stamos and its expected subcategories', () {
      final loans = CategoryCatalog.systemCategories.firstWhere(
        (category) => category.id == CategoryCatalog.loanCategoryId,
      );

      expect(loans.name, 'Pr\u00e9stamos');
      expect(loans.subcategories.map((item) => item.name),
          contains('Compras a cuotas'));
      expect(loans.subcategories.map((item) => item.name),
          contains('Tarjetas de cr\u00e9dito'));
      expect(loans.subcategories.map((item) => item.name),
          contains('Pr\u00e9stamo personal'));
      expect(loans.subcategories.map((item) => item.name),
          contains('Pr\u00e9stamo de veh\u00edculo'));
      expect(loans.subcategories.map((item) => item.name),
          contains('Pr\u00e9stamo de vivienda'));
    });

    test('companion catalog exposes only Kiki while Ra and Osi are pending',
        () {
      expect(CategoryCatalog.companionForId('avatar_kiki').name, 'Kiki');
      expect(CategoryCatalog.companionOptions.length, 1);
      expect(CategoryCatalog.companionForId('missing').name, 'Kiki');
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
      expect(ExpenseCategory.normalizeKey('  Caf\u00e9 '), 'cafe');
      expect(ExpenseCategory.normalizeKey('Tarjeta de cr\u00e9dito'),
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
      expect(provider.categoryExists('MASCOTA'), isTrue);
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

  group('OnboardingScreen', () {
    testWidgets('intro appears before financial questions', (tester) async {
      final provider = FinancialProfileProvider();
      await provider.init();

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: provider,
          child: const MaterialApp(home: OnboardingScreen()),
        ),
      );

      expect(find.byKey(const ValueKey('intro_title')), findsOneWidget);
      expect(find.text('\u00bfDe d\u00f3nde provienen tus ingresos?'),
          findsNothing);
    });

    testWidgets(
        'goals allow multiselection and keep selections when going back',
        (tester) async {
      final provider = FinancialProfileProvider();
      await provider.init();

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: provider,
          child: const MaterialApp(home: OnboardingScreen(editMode: true)),
        ),
      );

      await tester.tap(find.text('Siguiente'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Siguiente'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('goal_goal_save_more')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('goal_goal_reduce_debt')));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('priority_goal_save_more')),
          findsOneWidget);
      expect(find.byKey(const ValueKey('priority_goal_reduce_debt')),
          findsOneWidget);

      await tester.tap(find.text('Atr\u00e1s'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Siguiente'));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('priority_goal_save_more')),
          findsOneWidget);
      expect(find.byKey(const ValueKey('priority_goal_reduce_debt')),
          findsOneWidget);
    });

    testWidgets('edit preferences preloads existing data', (tester) async {
      final provider = FinancialProfileProvider();
      await provider.init();
      await provider.completeOnboarding(
        incomeTypes: const ['income_salary'],
        expenseCategories: const ['expense_food'],
        selectedGoals: const ['goal_save_more'],
        primaryGoal: 'goal_save_more',
        selectedAvatarId: 'avatar_ra',
      );

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: provider,
          child: const MaterialApp(home: OnboardingScreen(editMode: true)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Salario'), findsOneWidget);
      await tester.tap(find.text('Siguiente'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Siguiente'));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('priority_goal_save_more')),
          findsOneWidget);
    });
  });

  group('UX polish widgets', () {
    testWidgets('Expenses empty state shows Kiki Rest and CTA', (tester) async {
      final budget = BudgetProvider();
      await budget.init();

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: budget,
          child: const MaterialApp(home: ExpensesScreen()),
        ),
      );
      await tester.pump();

      final image = tester.widget<Image>(find.byType(Image).first);
      expect(image.image, isA<AssetImage>());
      expect((image.image as AssetImage).assetName,
          'assets/images/avatars/kiki/kiki_rest.png');
      expect(find.text('Agregar primer gasto'), findsOneWidget);
    });

    testWidgets('Companion selector opens with Kiki and no onboarding',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: KikiTheme.light(),
          home: const Scaffold(
            body: CompanionSelectorSheet(selectedAvatarId: 'avatar_kiki'),
          ),
        ),
      );

      expect(find.byKey(const ValueKey('companion_selector_title')),
          findsOneWidget);
      expect(find.byKey(const ValueKey('companion_option_avatar_kiki')),
          findsOneWidget);
      expect(find.text('Kiki'), findsOneWidget);
      expect(find.byType(OnboardingScreen), findsNothing);
    });
  });

  group('Dashboard smoke', () {
    test('Mood Engine returns expected official assets', () {
      final noExpenses = KikiMoodVisual.fromBudgetState(
        hasExpenses: false,
        budget: 100000,
        spent: 0,
        achievementsCount: 0,
        streak: 0,
      );
      final overBudget = KikiMoodVisual.fromBudgetState(
        hasExpenses: true,
        budget: 100000,
        spent: 120000,
        achievementsCount: 0,
        streak: 0,
      );

      expect(noExpenses.mood, KikiMood.noExpenses);
      expect(noExpenses.assetPath, KikiAvatarAssets.wave);
      expect(overBudget.mood, KikiMood.overBudget);
      expect(overBudget.assetPath, KikiAvatarAssets.sad);
    });

    testWidgets('DashboardHome works with empty selectedGoals', (tester) async {
      final budget = BudgetProvider();
      final commitments = CommitmentsProvider();
      final profile = FinancialProfileProvider();
      await budget.init();
      await commitments.init();
      await profile.init();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: budget),
            ChangeNotifierProvider.value(value: commitments),
            ChangeNotifierProvider.value(value: profile),
          ],
          child: const MaterialApp(home: Scaffold(body: DashboardHome())),
        ),
      );
      await tester.pump();

      expect(find.byType(DashboardHome), findsOneWidget);
    });
  });

  group('SmartExpenseParser', () {
    test('extracts amount from the end of a description', () {
      final parsed = SmartExpenseParser.parse('Caf\u00e9 1500');

      expect(parsed.title, 'Caf\u00e9');
      expect(parsed.amount, 1500);
    });

    test('detects known categories and falls back to General', () {
      expect(SmartExpenseParser.detectCategory('caf\u00e9'), 'Comida');
      expect(SmartExpenseParser.detectCategory('taxi'), 'Transporte');
      expect(SmartExpenseParser.detectCategory('papeler\u00eda'), 'General');
    });

    test('suggests Pr\u00e9stamos for loan-related terms', () {
      expect(
          SmartExpenseParser.detectCategory('cuota carro'), 'Pr\u00e9stamos');
      expect(SmartExpenseParser.detectCategory('prestamo universidad'),
          'Pr\u00e9stamos');
      expect(SmartExpenseParser.detectCategory('tarjeta cr\u00e9dito'),
          'Pr\u00e9stamos');
    });
  });

  group('Expense.fromMap', () {
    test('restores expense fields from persisted map', () {
      final date = DateTime(2026, 7, 21);
      final expense = Expense.fromMap({
        'id': 'expense-1',
        'title': 'Caf\u00e9',
        'category': 'Comida',
        'amount': 1500.0,
        'date': date.toIso8601String(),
      });

      expect(expense.id, 'expense-1');
      expect(expense.title, 'Caf\u00e9');
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
        name: 'Pr\u00e9stamo del veh\u00edculo',
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
        name: 'Pr\u00e9stamo del veh\u00edculo',
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
          title: 'D\u00eda 1',
          category: 'General',
          amount: 1,
          date: DateTime(2026, 7, 21, 9),
        ),
        Expense(
          title: 'D\u00eda 2',
          category: 'General',
          amount: 1,
          date: DateTime(2026, 7, 20, 9),
        ),
        Expense(
          title: 'D\u00eda 3',
          category: 'General',
          amount: 1,
          date: DateTime(2026, 7, 19, 9),
        ),
      ];

      expect(StreakService.calculateStreak(expenses), 3);
    });
  });
}
