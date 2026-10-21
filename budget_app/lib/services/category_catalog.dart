import 'package:flutter/material.dart';

import '../models/expense_category.dart';
import '../models/financial_profile.dart';
import '../utils/kiki_avatar_assets.dart';

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

class FinancialCompanionOption {
  final String id;
  final String name;
  final String description;
  final IconData fallbackIcon;
  final String? assetPath;

  const FinancialCompanionOption({
    required this.id,
    required this.name,
    required this.description,
    required this.fallbackIcon,
    this.assetPath,
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
      label: 'Alimentaci\u00f3n',
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
      label: 'Educaci\u00f3n',
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
      label: 'Deudas y pr\u00e9stamos',
      icon: Icons.account_balance_outlined,
      categoryId: loanCategoryId,
    ),
    FinancialProfileOption(
      id: 'expense_savings_investment',
      label: 'Ahorro e inversi\u00f3n',
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
      label: 'Ahorrar m\u00e1s',
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
      label: 'Saber en qu\u00e9 gasto',
      icon: Icons.pie_chart_outline,
    ),
    FinancialProfileOption(
      id: 'goal_build_habits',
      label: 'Crear mejores h\u00e1bitos financieros',
      icon: Icons.auto_awesome_outlined,
    ),
  ];

  static const companionOptions = [
    FinancialCompanionOption(
      id: FinancialProfile.defaultAvatarId,
      name: 'Kiki',
      description: 'Siempre lista para ayudarte.',
      fallbackIcon: Icons.auto_awesome_outlined,
      assetPath: KikiAvatarAssets.neutral,
    ),
  ];

  static List<ExpenseCategory> systemCategories = [
    _category('general', 'General', Icons.category_outlined, ['Otro']),
    _category('housing', 'Vivienda', Icons.home_outlined, [
      'Alquiler',
      'Cuota condominal',
      'Reparaciones',
      'Mantenimiento',
      'Muebles y electrodom\u00e9sticos',
      'Impuestos municipales',
    ]),
    _category('services', 'Servicios', Icons.receipt_long_outlined, [
      'Electricidad',
      'Agua',
      'Internet y cable',
      'Telefon\u00eda',
      'Gas',
      'Streaming y suscripciones',
    ]),
    _category('food', 'Alimentaci\u00f3n', Icons.restaurant_outlined, [
      'Supermercado',
      'Feria',
      'Restaurantes',
      'Comida r\u00e1pida',
      'Pedidos a domicilio',
      'Caf\u00e9 y snacks',
    ]),
    _category('transport', 'Transporte', Icons.directions_car_outlined, [
      'Combustible o recarga el\u00e9ctrica',
      'Transporte p\u00fablico',
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
      'Ex\u00e1menes',
      'Seguro m\u00e9dico',
      'Odontolog\u00eda',
      'Terapias',
    ]),
    _category('education', 'Educaci\u00f3n', Icons.school_outlined, [
      'Mensualidad',
      'Matr\u00edcula',
      '\u00datiles',
      'Uniformes',
      'Cursos',
      'Guarder\u00eda',
      'Plataformas educativas',
    ]),
    _category('pets', 'Mascotas', Icons.pets_outlined, [
      'Alimentaci\u00f3n',
      'Veterinario',
      'Medicamentos',
      'Higiene',
      'Accesorios',
    ]),
    _category(
        loanCategoryId, 'Pr\u00e9stamos', Icons.account_balance_outlined, [
      'Compras a cuotas',
      'Tarjetas de cr\u00e9dito',
      'Pr\u00e9stamo personal',
      'Pr\u00e9stamo de veh\u00edculo',
      'Pr\u00e9stamo de vivienda',
      'Otro',
    ]),
    _category(
      'savings_investment',
      'Ahorro e inversi\u00f3n',
      Icons.savings_outlined,
      ['Fondo de emergencia', 'Ahorro', 'Inversiones'],
    ),
    _category('personal', 'Personal', Icons.person_outline, [
      'Ropa y calzado',
      'Barber\u00eda o sal\u00f3n',
      'Cosm\u00e9ticos',
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
      'Tecnolog\u00eda',
      'Regalos',
      'Otro',
    ]),
    _category('marketing', 'Marketing', Icons.campaign_outlined, [
      'Publicidad',
      'Dise\u00f1o',
      'Otro',
    ]),
    _category('coffee', 'Caf\u00e9', Icons.local_cafe_outlined, [
      'Caf\u00e9',
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
      FinancialProfileOption? option;
      for (final item in expenseProfileOptions) {
        if (item.id == id) {
          option = item;
          break;
        }
      }
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

  static String labelForCompanion(String id) => companionForId(id).name;

  static FinancialCompanionOption companionForId(String id) {
    return companionOptions.firstWhere(
      (option) => option.id == id,
      orElse: () => companionOptions.first,
    );
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
      'food' => key == 'comida' || key == 'alimentacion',
      'housing' => key == 'vivienda' || key == 'alquiler',
      'loans' => key == 'prestamos' || key == 'deudasyprestamos',
      'entertainment' => key == 'entretenimiento',
      'other' => key == 'otros' || key == 'otrosegresos',
      _ => false,
    };
  }
}
