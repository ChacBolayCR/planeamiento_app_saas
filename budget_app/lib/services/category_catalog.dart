import 'package:flutter/material.dart';

import '../models/expense_category.dart';

class CategoryCatalog {
  static const createCategoryId = '__create_category__';
  static const createSubcategoryId = '__create_subcategory__';

  static const loanCategoryId = 'loans';

  static List<ExpenseCategory> systemCategories = [
    _category('general', 'General', Icons.category_outlined, ['Otro']),
    _category('coffee', 'Café', Icons.local_cafe_outlined,
        ['Café', 'Postre', 'Otro']),
    _category('food', 'Comida', Icons.restaurant_outlined, [
      'Supermercado',
      'Restaurante',
      'Comida rápida',
      'Almuerzo',
      'Cena',
      'Otro',
    ]),
    _category('transport', 'Transporte', Icons.directions_car_outlined, [
      'Combustible',
      'Uber o taxi',
      'Autobús',
      'Mantenimiento',
      'Parqueo',
      'Otro',
    ]),
    _category('shopping', 'Compras', Icons.shopping_bag_outlined, [
      'Ropa',
      'Hogar',
      'Tecnología',
      'Regalos',
      'Otro',
    ]),
    _category('services', 'Servicios', Icons.receipt_long_outlined, [
      'Electricidad',
      'Agua',
      'Internet',
      'Teléfono',
      'Streaming',
      'Otro',
    ]),
    _category(
        'rent', 'Alquiler', Icons.home_outlined, ['Casa', 'Oficina', 'Otro']),
    _category('entertainment', 'Entretenimiento', Icons.movie_outlined, [
      'Streaming',
      'Cine',
      'Eventos',
      'Otro',
    ]),
    _category('marketing', 'Marketing', Icons.campaign_outlined,
        ['Publicidad', 'Diseño', 'Otro']),
    _category('education', 'Educación', Icons.school_outlined, [
      'Matrícula',
      'Mensualidad',
      'Libros',
      'Cursos',
      'Otro',
    ]),
    _category('health', 'Salud', Icons.health_and_safety_outlined, [
      'Medicina',
      'Consulta',
      'Seguro',
      'Exámenes',
      'Otro',
    ]),
    _category(loanCategoryId, 'Préstamos', Icons.account_balance_outlined, [
      'Personal',
      'Vivienda',
      'Vehículo',
      'Educación',
      'Tarjeta de crédito',
      'Otro',
    ]),
    _category('other', 'Otros', Icons.more_horiz_outlined, ['Otro']),
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
      (category) => ExpenseCategory.normalizeKey(category.name) == key,
      orElse: () =>
          systemCategories.firstWhere((category) => category.id == 'other'),
    );
  }
}
