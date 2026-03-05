import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../providers/budget_provider.dart';
import '../../models/expense.dart';

class AddExpenseModal extends StatefulWidget {
  const AddExpenseModal({super.key});

  @override
  State<AddExpenseModal> createState() => _AddExpenseModalState();
}

class _AddExpenseModalState extends State<AddExpenseModal> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  String _selectedCategory = 'General';

  final List<String> _categories = [
    'General',
    'Servicios',
    'Alquiler',
    'Comida',
    'Transporte',
    'Marketing',
    'Entretenimiento',
  ];

  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    final title = _titleController.text.trim();
    final amountText = _amountController.text.trim();
    if (title.isEmpty || amountText.isEmpty) return false;
    final amount = double.tryParse(amountText.replaceAll(',', '.'));
    if (amount == null || amount <= 0) return false;
    return true;
  }

  Future<void> _showFreeLimitDialog(int limit) async {
    final budget = context.read<BudgetProvider>();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Límite Free alcanzado'),
        content: Text('En la versión gratuita puedes registrar hasta $limit gastos por mes.'),
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
                    content: Text('Pro activado (modo pruebas) ✅'),
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

  Future<void> _saveExpense() async {
    if (!_isFormValid) {
      _formKey.currentState?.validate();
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isSaving = true);

    final title = _titleController.text.trim();
    final amountText = _amountController.text.trim().replaceAll(',', '.');
    final amount = double.parse(amountText);

    final expense = Expense(
      title: title,
      category: _selectedCategory,
      amount: amount,
      date: DateTime.now(),
    );

    try {
      context.read<BudgetProvider>().addExpense(expense);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gasto guardado ✅'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      await Future.delayed(const Duration(milliseconds: 200));
      if (mounted) Navigator.pop(context);
    } on FreeLimitReachedException catch (e) {
      // ✅ Mensaje elegante + opción debug para activar Pro
      await _showFreeLimitDialog(e.limit);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final symbol = context.select<BudgetProvider, String>((p) => p.currencySymbol);

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
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
            const SizedBox(height: 16),

            TextFormField(
              controller: _titleController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Describe el gasto';
                return null;
              },
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'[\d\.,]')),
              ],
              decoration: InputDecoration(
                labelText: 'Monto',
                prefixText: '$symbol ',
                border: const OutlineInputBorder(),
                hintText: '0.00',
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Ingresa un monto';
                final parsed = double.tryParse(v.trim().replaceAll(',', '.'));
                if (parsed == null || parsed <= 0) return 'Monto inválido';
                return null;
              },
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Categoría',
                border: OutlineInputBorder(),
              ),
              items: _categories
                  .map(
                    (category) => DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _selectedCategory = value);
              },
            ),

            const SizedBox(height: 20),

            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _isSaving || !_isFormValid ? null : _saveExpense,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Guardar gasto'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}