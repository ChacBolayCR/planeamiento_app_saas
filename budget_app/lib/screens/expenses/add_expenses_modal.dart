import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../design_system/components/kiki_button.dart';
import '../../design_system/components/kiki_card.dart';
import '../../design_system/kiki_spacing.dart';
import '../../models/expense.dart';
import '../../models/expense_category.dart';
import '../../models/financial_commitment.dart';
import '../../providers/budget_provider.dart';
import '../../providers/category_catalog_provider.dart';
import '../../providers/commitments_provider.dart';
import '../../providers/financial_profile_provider.dart';
import '../../services/category_catalog.dart';
import '../../utils/smart_expense_parser.dart';

class AddExpenseModal extends StatefulWidget {
  final String? prefilledCategory;

  const AddExpenseModal({
    super.key,
    this.prefilledCategory,
  });

  @override
  State<AddExpenseModal> createState() => _AddExpenseModalState();
}

class _AddExpenseModalState extends State<AddExpenseModal> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _customNameController = TextEditingController();
  final _commitmentNameController = TextEditingController();
  final _monthlyAmountController = TextEditingController();
  final _totalAmountController = TextEditingController();
  final _paidAmountController = TextEditingController();
  final _remainingAmountController = TextEditingController();
  final _installmentsController = TextEditingController(text: '12');

  String _selectedCategoryId = 'general';
  String? _selectedSubcategoryId;
  bool _isSaving = false;
  bool _createLoanCommitment = false;
  bool _repeatMonthly = false;
  bool _showAllCategories = false;
  int _paymentDay = DateTime.now().day.clamp(1, 28);
  DateTime _nextPaymentDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _nextPaymentDate =
        DateTime(DateTime.now().year, DateTime.now().month, _paymentDay);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final categories = context.read<CategoryCatalogProvider>();
    final prefilled = widget.prefilledCategory;
    if (prefilled != null && _titleController.text.isEmpty) {
      final category = categories.categoryByName(prefilled);
      _selectedCategoryId = category.id;
      _selectedSubcategoryId = category.subcategories.isNotEmpty
          ? category.subcategories.first.id
          : null;
      _titleController.text = prefilled;
    } else if (_selectedSubcategoryId == null) {
      final category = categories.categoryById(_selectedCategoryId);
      _selectedSubcategoryId = category.subcategories.isNotEmpty
          ? category.subcategories.first.id
          : null;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _customNameController.dispose();
    _commitmentNameController.dispose();
    _monthlyAmountController.dispose();
    _totalAmountController.dispose();
    _paidAmountController.dispose();
    _remainingAmountController.dispose();
    _installmentsController.dispose();
    super.dispose();
  }

  bool get _isLoanCategory =>
      _selectedCategoryId == CategoryCatalog.loanCategoryId;

  bool get _isFormValid {
    final title = _titleController.text.trim();
    final amount = _readAmount(_amountController.text);
    if (title.isEmpty || amount == null || amount <= 0) return false;

    if (_createLoanCommitment) {
      return _commitmentNameController.text.trim().isNotEmpty &&
          (_readAmount(_monthlyAmountController.text) ?? 0) > 0 &&
          (_readAmount(_totalAmountController.text) ?? 0) > 0 &&
          ((_readAmount(_paidAmountController.text) ?? -1) >= 0 ||
              (_readAmount(_remainingAmountController.text) ?? -1) >= 0) &&
          (int.tryParse(_installmentsController.text.trim()) ?? 0) > 0;
    }

    return true;
  }

  Future<void> _showFreeLimitDialog(
    BuildContext context,
    BudgetProvider budget,
  ) async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Límite Free alcanzado'),
        content: Text(
          'En la versión gratuita puedes registrar hasta '
          '${BudgetProvider.freeMonthlyExpenseLimit} gastos por mes.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
          if (kDebugMode)
            ElevatedButton(
              onPressed: () {
                budget.setIsPro(true);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pro activado (modo pruebas)'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Activar Pro (debug)'),
            ),
        ],
      ),
    );
  }

  Future<void> _createCustomCategory(CategoryCatalogProvider provider) async {
    final name =
        await _promptForName('Crear categoría', 'Nombre de la categoría');
    if (name == null) return;

    final created = await provider.addCustomCategory(name);
    if (!mounted) return;

    if (created == null) {
      _showError('Esa categoría ya existe o el nombre no es válido.');
      return;
    }

    setState(() {
      _selectedCategoryId = created.id;
      _selectedSubcategoryId = created.subcategories.first.id;
      _createLoanCommitment = false;
      _repeatMonthly = false;
    });
  }

  Future<void> _createCustomSubcategory(
      CategoryCatalogProvider provider) async {
    final name =
        await _promptForName('Crear subcategoría', 'Nombre de la subcategoría');
    if (name == null) return;

    final created =
        await provider.addCustomSubcategory(_selectedCategoryId, name);
    if (!mounted) return;

    if (created == null) {
      _showError('Esa subcategoría ya existe o el nombre no es válido.');
      return;
    }

    setState(() => _selectedSubcategoryId = created.id);
  }

  Future<String?> _promptForName(String title, String label) async {
    _customNameController.clear();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: _customNameController,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(context, _customNameController.text.trim()),
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickNextPaymentDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _nextPaymentDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime(DateTime.now().year + 5),
    );

    if (picked == null) return;
    setState(() {
      _nextPaymentDate = picked;
      _paymentDay = picked.day.clamp(1, 31);
    });
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _saveExpense() async {
    final budget = context.read<BudgetProvider>();
    final categories = context.read<CategoryCatalogProvider>();
    final commitments = context.read<CommitmentsProvider>();

    if (!_isFormValid) {
      _formKey.currentState?.validate();
      _showError('Revisa los datos antes de guardar.');
      return;
    }

    if (budget.isFreeLimitReached) {
      await _showFreeLimitDialog(context, budget);
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isSaving = true);

    try {
      final category = categories.categoryById(_selectedCategoryId);
      final subcategory = _selectedSubcategory(category);
      final amount = _readAmount(_amountController.text)!;
      String? commitmentId;

      if (_createLoanCommitment || _repeatMonthly) {
        final commitment = _buildCommitment(category, subcategory, amount);
        await commitments.addCommitment(commitment);
        commitmentId = commitment.id;
      }

      final expense = Expense(
        title: _titleController.text.trim(),
        category: category.name,
        categoryId: category.id,
        categoryName: category.name,
        subcategoryId: subcategory?.id,
        subcategoryName: subcategory?.name,
        amount: amount,
        date: DateTime.now(),
        commitmentId: commitmentId,
        isRecurring: _createLoanCommitment || _repeatMonthly,
      );

      final added = budget.addExpense(expense);
      if (!added) {
        _showError('No se pudo guardar el gasto. Revisa el límite Free.');
        return;
      }

      if (!mounted) return;

      final message = _createLoanCommitment
          ? 'Compromiso creado y gasto guardado'
          : 'Gasto guardado';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );

      await Future.delayed(const Duration(milliseconds: 150));

      if (!mounted) return;
      Navigator.pop(context);
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  FinancialCommitment _buildCommitment(
    ExpenseCategory category,
    ExpenseSubcategory? subcategory,
    double fallbackAmount,
  ) {
    final monthlyAmount =
        _readAmount(_monthlyAmountController.text) ?? fallbackAmount;
    final totalAmount =
        _readAmount(_totalAmountController.text) ?? monthlyAmount;
    final explicitPaid = _readAmount(_paidAmountController.text);
    final explicitRemaining = _readAmount(_remainingAmountController.text);
    final double paidAmount = explicitPaid ??
        (explicitRemaining == null ? 0.0 : totalAmount - explicitRemaining)
            .clamp(0.0, totalAmount)
            .toDouble();
    final installments = int.tryParse(_installmentsController.text.trim()) ?? 1;
    final name = _commitmentNameController.text.trim().isEmpty
        ? _titleController.text.trim()
        : _commitmentNameController.text.trim();

    return FinancialCommitment(
      name: name,
      categoryId: category.id,
      subcategoryId: subcategory?.id ?? 'other',
      monthlyAmount: monthlyAmount,
      totalAmount: totalAmount < monthlyAmount ? monthlyAmount : totalAmount,
      paidAmount: paidAmount,
      startDate: DateTime.now(),
      nextPaymentDate: _nextPaymentDate,
      paymentDay: _paymentDay,
      totalInstallments: installments,
      paidInstallments:
          (paidAmount / monthlyAmount).floor().clamp(0, installments),
    );
  }

  List<ExpenseCategory> _orderedCategories(
    CategoryCatalogProvider catalog,
    FinancialProfileProvider financialProfile,
  ) {
    final all = catalog.categories;
    final selectedProfileIds =
        financialProfile.profile.selectedExpenseCategories;
    if (_showAllCategories || selectedProfileIds.isEmpty) return all;

    final preferredIds = CategoryCatalog.categoryIdsForProfileExpenseIds(
      selectedProfileIds,
    );
    final ordered = <ExpenseCategory>[];

    for (final id in preferredIds) {
      for (final category in all) {
        if (category.id == id && !ordered.any((item) => item.id == id)) {
          ordered.add(category);
        }
      }
    }

    for (final category in all.where((category) => category.isCustom)) {
      if (!ordered.any((item) => item.id == category.id)) {
        ordered.add(category);
      }
    }

    if (!ordered.any((category) => category.id == _selectedCategoryId)) {
      ordered.add(catalog.categoryById(_selectedCategoryId));
    }

    return ordered.isEmpty ? all : ordered;
  }

  ExpenseSubcategory? _selectedSubcategory(ExpenseCategory category) {
    if (_selectedSubcategoryId == null) return null;
    return category.subcategories.firstWhere(
      (subcategory) => subcategory.id == _selectedSubcategoryId,
      orElse: () => category.subcategories.isNotEmpty
          ? category.subcategories.first
          : const ExpenseSubcategory(id: 'other', name: 'Otro'),
    );
  }

  double? _readAmount(String value) {
    final normalized = value.trim().replaceAll(' ', '').replaceAll(',', '.');
    return double.tryParse(normalized);
  }

  @override
  Widget build(BuildContext context) {
    final symbol =
        context.select<BudgetProvider, String>((p) => p.currencySymbol);
    final catalog = context.watch<CategoryCatalogProvider>();
    final financialProfile = context.watch<FinancialProfileProvider>();
    final mediaQuery = MediaQuery.of(context);
    final maxModalHeight = mediaQuery.size.height * 0.9;
    final categories = _orderedCategories(catalog, financialProfile);
    final selectedCategory = catalog.categoryById(_selectedCategoryId);
    final subcategories = selectedCategory.subcategories;

    if (_selectedSubcategoryId != null &&
        !subcategories
            .any((subcategory) => subcategory.id == _selectedSubcategoryId)) {
      _selectedSubcategoryId =
          subcategories.isNotEmpty ? subcategories.first.id : null;
    }

    return SafeArea(
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxModalHeight),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(KikiSpacing.lg),
            child: Form(
              key: _formKey,
              onChanged: () => setState(() {}),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Nuevo gasto',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: KikiSpacing.lg),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategoryId,
                    decoration: const InputDecoration(
                      labelText: 'Categoría',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      ...categories.map(
                        (category) => DropdownMenuItem(
                          value: category.id,
                          child: Row(
                            children: [
                              Icon(category.icon, size: 18),
                              const SizedBox(width: KikiSpacing.sm),
                              Text(category.name),
                            ],
                          ),
                        ),
                      ),
                      const DropdownMenuItem(
                        value: CategoryCatalog.createCategoryId,
                        child: Text('+ Crear categoría'),
                      ),
                    ],
                    onChanged: (value) async {
                      if (value == null) return;
                      if (value == CategoryCatalog.headerYourCategoriesId ||
                          value == CategoryCatalog.headerAllCategoriesId) {
                        return;
                      }
                      if (value == CategoryCatalog.showAllCategoriesId) {
                        setState(() => _showAllCategories = true);
                        return;
                      }
                      if (value == CategoryCatalog.createCategoryId) {
                        await _createCustomCategory(catalog);
                        return;
                      }
                      final category = catalog.categoryById(value);
                      setState(() {
                        _selectedCategoryId = category.id;
                        _selectedSubcategoryId =
                            category.subcategories.isNotEmpty
                                ? category.subcategories.first.id
                                : null;
                        _createLoanCommitment = false;
                        _repeatMonthly = false;
                      });
                    },
                  ),
                  const SizedBox(height: KikiSpacing.md),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedSubcategoryId,
                    decoration: const InputDecoration(
                      labelText: 'Subcategoría',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      ...subcategories.map(
                        (subcategory) => DropdownMenuItem(
                          value: subcategory.id,
                          child: Text(subcategory.name),
                        ),
                      ),
                      const DropdownMenuItem(
                        value: CategoryCatalog.createSubcategoryId,
                        child: Text('+ Crear subcategoría'),
                      ),
                    ],
                    onChanged: (value) async {
                      if (value == null) return;
                      if (value == CategoryCatalog.createSubcategoryId) {
                        await _createCustomSubcategory(catalog);
                        return;
                      }
                      setState(() => _selectedSubcategoryId = value);
                    },
                  ),
                  const SizedBox(height: KikiSpacing.md),
                  TextFormField(
                    controller: _titleController,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Descripción',
                      hintText: 'Ejemplo: Café 1500',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      final parsed = SmartExpenseParser.parse(value);
                      final suggestedCategory =
                          SmartExpenseParser.detectCategory(parsed.title);
                      final category =
                          catalog.categoryByName(suggestedCategory);
                      setState(() {
                        _selectedCategoryId = category.id;
                        _selectedSubcategoryId =
                            category.subcategories.isNotEmpty
                                ? category.subcategories.first.id
                                : null;
                        _createLoanCommitment = false;
                        _repeatMonthly = false;
                      });

                      if (parsed.amount != null) {
                        _amountController.text = parsed.amount.toString();
                      }
                    },
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Agrega una descripción';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: KikiSpacing.md),
                  TextFormField(
                    controller: _amountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d\., ]')),
                    ],
                    decoration: InputDecoration(
                      labelText: 'Monto',
                      prefixText: '$symbol ',
                      hintText: '0.00',
                      border: const OutlineInputBorder(),
                    ),
                    validator: (v) {
                      final parsed = _readAmount(v ?? '');
                      if (parsed == null || parsed <= 0) {
                        return 'Monto inválido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: KikiSpacing.md),
                  if (_isLoanCategory)
                    _LoanFollowUpCard(
                      createCommitment: _createLoanCommitment,
                      onChanged: (value) => setState(() {
                        _createLoanCommitment = value;
                        _repeatMonthly = false;
                        if (value && _monthlyAmountController.text.isEmpty) {
                          _monthlyAmountController.text =
                              _amountController.text;
                        }
                      }),
                    )
                  else
                    CheckboxListTile(
                      value: _repeatMonthly,
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Repetir cada mes'),
                      subtitle: const Text(
                          'Se guardará como próximo compromiso, sin crear gastos futuros automáticamente.'),
                      onChanged: (value) =>
                          setState(() => _repeatMonthly = value ?? false),
                    ),
                  if (_createLoanCommitment || _repeatMonthly) ...[
                    const SizedBox(height: KikiSpacing.md),
                    _CommitmentFields(
                      isLoan: _createLoanCommitment,
                      symbol: symbol,
                      nameController: _commitmentNameController,
                      monthlyAmountController: _monthlyAmountController,
                      totalAmountController: _totalAmountController,
                      paidAmountController: _paidAmountController,
                      remainingAmountController: _remainingAmountController,
                      installmentsController: _installmentsController,
                      paymentDay: _paymentDay,
                      nextPaymentDate: _nextPaymentDate,
                      onPaymentDayChanged: (value) =>
                          setState(() => _paymentDay = value),
                      onPickDate: _pickNextPaymentDate,
                    ),
                  ],
                  const SizedBox(height: KikiSpacing.xl),
                  SizedBox(
                    height: 48,
                    child: KikiButton(
                      label: 'Guardar gasto',
                      loading: _isSaving,
                      onPressed:
                          _isSaving || !_isFormValid ? null : _saveExpense,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoanFollowUpCard extends StatelessWidget {
  final bool createCommitment;
  final ValueChanged<bool> onChanged;

  const _LoanFollowUpCard({
    required this.createCommitment,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return KikiCard(
      variant: KikiCardVariant.highlighted,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¿Quieres llevar el seguimiento de este préstamo?',
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          const Text(
              'Kiki puede ayudarte a llevar el saldo y tus próximas cuotas.'),
          RadioGroup<bool>(
            groupValue: createCommitment,
            onChanged: (value) => onChanged(value ?? false),
            child: const Column(
              children: [
                RadioListTile<bool>(
                  value: false,
                  contentPadding: EdgeInsets.zero,
                  title: Text('Solo registrar este gasto'),
                ),
                RadioListTile<bool>(
                  value: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text('Crear compromiso recurrente'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CommitmentFields extends StatelessWidget {
  final bool isLoan;
  final String symbol;
  final TextEditingController nameController;
  final TextEditingController monthlyAmountController;
  final TextEditingController totalAmountController;
  final TextEditingController paidAmountController;
  final TextEditingController remainingAmountController;
  final TextEditingController installmentsController;
  final int paymentDay;
  final DateTime nextPaymentDate;
  final ValueChanged<int> onPaymentDayChanged;
  final VoidCallback onPickDate;

  const _CommitmentFields({
    required this.isLoan,
    required this.symbol,
    required this.nameController,
    required this.monthlyAmountController,
    required this.totalAmountController,
    required this.paidAmountController,
    required this.remainingAmountController,
    required this.installmentsController,
    required this.paymentDay,
    required this.nextPaymentDate,
    required this.onPaymentDayChanged,
    required this.onPickDate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: nameController,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: isLoan ? 'Nombre del préstamo' : 'Nombre del compromiso',
            hintText: isLoan ? 'Préstamo del vehículo' : 'Pago mensual',
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: KikiSpacing.md),
        TextFormField(
          controller: monthlyAmountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d\., ]'))
          ],
          decoration: InputDecoration(
            labelText: 'Cuota mensual',
            prefixText: '$symbol ',
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: KikiSpacing.md),
        TextFormField(
          controller: totalAmountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d\., ]'))
          ],
          decoration: InputDecoration(
            labelText: isLoan ? 'Total del préstamo' : 'Total del compromiso',
            prefixText: '$symbol ',
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: KikiSpacing.md),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: paidAmountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d\., ]'))
                ],
                decoration: InputDecoration(
                  labelText: 'Pagado',
                  prefixText: '$symbol ',
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: KikiSpacing.sm),
            Expanded(
              child: TextFormField(
                controller: remainingAmountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d\., ]'))
                ],
                decoration: InputDecoration(
                  labelText: 'Saldo actual',
                  prefixText: '$symbol ',
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: KikiSpacing.md),
        TextFormField(
          controller: installmentsController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            labelText: 'Número total de cuotas',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: KikiSpacing.md),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<int>(
                initialValue: paymentDay.clamp(1, 31),
                decoration: const InputDecoration(
                  labelText: 'Día de pago',
                  border: OutlineInputBorder(),
                ),
                items: List.generate(
                  31,
                  (index) => DropdownMenuItem(
                    value: index + 1,
                    child: Text('${index + 1}'),
                  ),
                ),
                onChanged: (value) {
                  if (value != null) onPaymentDayChanged(value);
                },
              ),
            ),
            const SizedBox(width: KikiSpacing.sm),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onPickDate,
                icon: const Icon(Icons.event_outlined),
                label: Text(
                    '${nextPaymentDate.day}/${nextPaymentDate.month}/${nextPaymentDate.year}'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
