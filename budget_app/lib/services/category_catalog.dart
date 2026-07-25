import 'package:flutter/material.dart';

import '../models/expense_category.dart';

class FinancialProfileOption {
  final String id;
  final String label;
  final IconData icon;
  final String? categoryId;

  const FinancialProfileOption({
    required this.id,
    required this.label,
    required this.icon,
    this.categoryId,
  });
}

class CategoryCatalog {
  static const createCategoryId = '__create_category__';
  static const createSubcategoryId = '__create_subcategory__';
  static const showAllCategoriesId = '__show_all_categories__';
  static const headerYourCategoriesId = '__header_your_categories__';
  static const headerAllCategoriesId = '__header_all_categories__';

  static const loanCategoryId = 'loans';

  static const incomeOptions = [
    FinancialProfileOption(
      id: 'income_salary',
      label: 'Salario',
      icon: Icons.badge_outlined,
    ),
    FinancialProfileOption(
      id: 'income_professional_services',
      label: 'Servicios profesionales',
      icon: Icons.work_outline,
    ),
    FinancialProfileOption(
      id: 'income_sales',
      label: 'Ventas',
      icon: Icons.storefront_outlined,
    ),
    FinancialProfileOption(
      id: 'income_business',
      label: 'Emprendimientos',
      icon: Icons.rocket_launch_outlined,
    ),
    FinancialProfileOption(
      id: 'income_investments',
      label: 'Inversiones',
      icon: Icons.trending_up_outlined,
    ),
    FinancialProfileOption(
      id: 'income_other',
      label: 'Otro',
      icon: Icons.more_horiz_outlined,
    ),
  ];

  static const expenseProfileOptions = [
    FinancialProfileOption(
      id: 'expense_housing',
      label: 'Vivienda',
      icon: Icons.home_outlined,
      categoryId: 'housing',
    ),
    FinancialProfileOption(
      id: 'expense_services',
      label: 'Servicios',
      icon: Icons.receipt_long_outlined,
      categoryId: 'services',
    ),
    FinancialProfileOption(
      id: 'expense_food',
      label: 'Alimentación',
      icon: Icons.restaurant_outlined,
      categoryId: 'food',
    ),
    FinancialProfileOption(
      id: 'expense_transport',
      label: 'Transporte',
      icon: Icons.directions_car_outlined,
      categoryId: 'transport',
    ),
    FinancialProfileOption(
      id: 'expense_health',
      label: 'Salud',
      icon: Icons.health_and_safety_outlined,
      categoryId: 'health',
    ),
    FinancialProfileOption(
      id: 'expense_education',
      label: 'Educación',
      icon: Icons.school_outlined,
      categoryId: 'education',
    ),
    FinancialProfileOption(
      id: 'expense_pets',
      label: 'Mascotas',
      icon: Icons.pets_outlined,
      categoryId: 'pets',
    ),
    FinancialProfileOption(
      id: 'expense_debt_loans',
      label: 'Deudas y préstamos',
      icon: Icons.account_balance_outlined,
      categoryId: loanCategoryId,
    ),
    FinancialProfileOption(
      id: 'expense_savings_investment',
      label: 'Ahorro e inversión',
      icon: Icons.savings_outlined,
      categoryId: 'savings_investment',
    ),
    FinancialProfileOption(
      id: 'expense_personal',
      label: 'Personal',
      icon: Icons.person_outline,
      categoryId: 'personal',
    ),
    FinancialProfileOption(
      id: 'expense_entertainment',
      label: 'Entretenimiento y ocio',
      icon: Icons.movie_outlined,
      categoryId: 'entertainment',
    ),
    FinancialProfileOption(
      id: 'expense_other',
      label: 'Otros egresos',
      icon: Icons.more_horiz_outlined,
      categoryId: 'other',
    ),
  ];

  static const goalOptions = [
    FinancialProfileOption(
      id: 'goal_control_expenses',
      label: 'Controlar mis gastos',
      icon: Icons.fact_check_outlined,
    ),
    FinancialProfileOption(
      id: 'goal_save_more',
      label: 'Ahorrar más',
      icon: Icons.savings_outlined,
    ),
    FinancialProfileOption(
      id: 'goal_reduce_debt',
      label: 'Salir de deudas',
      icon: Icons.account_balance_wallet_outlined,
    ),
    FinancialProfileOption(
      id: 'goal_organize_budget',
      label: 'Organizar mi presupuesto',
      icon: Icons.calendar_month_outlined,
    ),
    FinancialProfileOption(
      id: 'goal_understand_spending',
      label: 'Saber en qué gasto',
      icon: Icons.pie_chart_outline,
    ),
    FinancialProfileOption(
      id: 'goal_build_habits',
      label: 'Crear mejores hábitos financieros',
      icon: Icons.auto_awesome_outlined,
    ),
  ];

  static List<ExpenseCategory> systemCategories = [
    _category('general', 'General', Icons.category_outlined, ['Otro']),
    _category('housing', 'Vivienda', Icons.home_outlined, [
      'Alquiler',
      'Cuota condominal',
      'Reparaciones',
      'Mantenimiento',
      'Muebles y electrodomésticos',
      'Impuestos municipales',
    ]),
    _category('services', 'Servicios', Icons.receipt_long_outlined, [
      'Electricidad',
      'Agua',
      'Internet y cable',
      'Telefonía',
      'Gas',
      'Streaming y suscripciones',
    ]),
    _category('food', 'Alimentación', Icons.restaurant_outlined, [
      'Supermercado',
      'Feria',
      'Restaurantes',
      'Comida rápida',
      'Pedidos a domicilio',
      'Café y snacks',
    ]),
    _category('transport', 'Transporte', Icons.directions_car_outlined, [
      'Combustible o recarga eléctrica',
      'Transporte público',
      'Peajes',
      'Parqueos',
      'Mantenimiento',
      'Marchamo',
      'Seguro',
      'Repuestos',
    ]),
    _category('health', 'Salud', Icons.health_and_safety_outlined, [
      'Chequeo anual',
      'Consultas',
      'Medicamentos',
      'Exámenes',
      'Seguro médico',
      'Odontología',
      'Terapias',
    ]),
    _category('education', 'Educación', Icons.school_outlined, [
      'Mensualidad',
      'Matrícula',
      'Útiles',
      'Uniformes',
      'Cursos',
      'Guardería',
      'Plataformas educativas',
    ]),
    _category('pets', 'Mascotas', Icons.pets_outlined, [
      'Alimentación',
      'Veterinario',
      'Medicamentos',
      'Higiene',
      'Accesorios',
    ]),
    _category(loanCategoryId, 'Préstamos', Icons.account_balance_outlined, [
      'Compras a cuotas',
      'Tarjetas de crédito',
      'Préstamo personal',
      'Préstamo de vehículo',
      'Préstamo de vivienda',
      'Otro',
    ]),
    _category(
        'savings_investment', 'Ahorro e inversión', Icons.savings_outlined, [
      'Fondo de emergencia',
      'Ahorro',
      'Inversiones',
    ]),
    _category('personal', 'Personal', Icons.person_outline, [
      'Ropa y calzado',
      'Barbería o salón',
      'Cosméticos',
      'Gimnasio',
      'Productos personales',
    ]),
    _category('entertainment', 'Entretenimiento y ocio', Icons.movie_outlined, [
      'Videojuegos',
      'Cine',
      'Paseos',
      'Eventos',
      'Hobbies',
      'Vacaciones',
    ]),
    _category('shopping', 'Compras', Icons.shopping_bag_outlined, [
      'Ropa',
      'Hogar',
      'Tecnología',
      'Regalos',
      'Otro',
    ]),
    _category('marketing', 'Marketing', Icons.campaign_outlined, [
      'Publicidad',
      'Diseño',
      'Otro',
    ]),
    _category('coffee', 'Café', Icons.local_cafe_outlined, [
      'Café',
      'Snacks',
      'Otro',
    ]),
    _category('rent', 'Alquiler', Icons.home_work_outlined, [
      'Casa',
      'Oficina',
      'Otro',
    ]),
    _category('other', 'Otros egresos', Icons.more_horiz_outlined, ['Otro']),
  ];

  static ExpenseCategory _category(
    String id,
    String name,
    IconData icon,
    List<String> subcategories,
  ) {
    return ExpenseCategory(
      id: id,
      name: name,
      icon: icon,
      subcategories: subcategories
          .map(
            (name) => ExpenseSubcategory(
              id: ExpenseCategory.normalizeKey(name),
              name: name,
            ),
          )
          .toList(),
    );
  }

  static ExpenseCategory categoryForLegacyName(String? name) {
    if (name == null || name.trim().isEmpty) return systemCategories.first;
    final key = ExpenseCategory.normalizeKey(name);
    return systemCategories.firstWhere(
      (category) =>
          ExpenseCategory.normalizeKey(category.name) == key ||
          _legacyCategoryMatches(category.id, key),
      orElse: () =>
          systemCategories.firstWhere((category) => category.id == 'other'),
    );
  }

  static List<String> categoryIdsForProfileExpenseIds(List<String> ids) {
    final mapped = <String>[];
    for (final id in ids) {
      final option =
          expenseProfileOptions.where((item) => item.id == id).firstOrNull;
      final categoryId = option?.categoryId;
      if (categoryId != null && !mapped.contains(categoryId)) {
        mapped.add(categoryId);
      }
    }
    return mapped;
  }

  static String labelForIncome(String id) => _labelFor(incomeOptions, id);

  static String labelForExpenseProfile(String id) =>
      _labelFor(expenseProfileOptions, id);

  static String labelForGoal(String? id) {
    if (id == null || id.isEmpty) return 'Sin objetivo seleccionado';
    return _labelFor(goalOptions, id);
  }

  static String _labelFor(List<FinancialProfileOption> options, String id) {
    return options
        .firstWhere(
          (option) => option.id == id,
          orElse: () => FinancialProfileOption(
            id: id,
            label: id,
            icon: Icons.label_outline,
          ),
        )
        .label;
  }

  static bool _legacyCategoryMatches(String categoryId, String key) {
    return switch (categoryId) {
      'food' => key == 'comida',
      'housing' => key == 'vivienda' || key == 'alquiler',
      'loans' => key == 'prestamos' || key == 'deudasyprestamos',
      'entertainment' => key == 'entretenimiento',
      'other' => key == 'otros',
      _ => false,
    };
  }
}
