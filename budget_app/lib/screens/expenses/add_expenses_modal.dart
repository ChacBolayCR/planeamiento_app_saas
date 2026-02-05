import 'package:flutter/material.dart';
import '../../repositories/expenses_repository.dart';
import '../../models/expense.dart';

class AddExpenseModal extends StatefulWidget {
  const AddExpenseModal({super.key});

  @override
  State<AddExpenseModal> createState() => _AddExpenseModalState();
}

class _AddExpenseModalState extends State<AddExpenseModal> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedCategory = 'General';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Descripción'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Monto'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            items: const [
              DropdownMenuItem(value: 'General', child: Text('General')),
              DropdownMenuItem(value: 'Fijo', child: Text('Fijo')),
              DropdownMenuItem(value: 'Variable', child: Text('Variable')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedCategory = value!;
              });
            },
            decoration: const InputDecoration(labelText: 'Categoría'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              ExpensesRepository.instance.addExpense(
                Expense(
                  title: _titleController.text,
                  category: _selectedCategory,
                  amount: double.parse(_amountController.text),
                ),
              );
              Navigator.pop(context);
            },
            child: const Text('Agregar gasto'),
          ),
        ],
      ),
    );
  }
}
