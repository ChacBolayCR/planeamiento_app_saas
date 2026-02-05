import 'package:flutter/material.dart';
import '../../models/expense.dart';
import '../../data/expenses_repository.dart';
import '../../models/expense.dart';


class AddExpenseModal extends StatefulWidget {
  const AddExpenseModal({super.key});

  @override
  State<AddExpenseModal> createState() => _AddExpenseModalState();
}

class _AddExpenseModalState extends State<AddExpenseModal> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  
  String _selectedCategory = 'General';
  String _category = 'Fijo';

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nuevo gasto',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          // Descripción
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Descripción',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Monto
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Monto',
              prefixText: '\$ ',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Categoría
          DropdownButtonFormField<String>(
  value: _selectedCategory,
  items: const [
    DropdownMenuItem(value: 'Fijo', child: Text('Fijo')),
    DropdownMenuItem(value: 'Variable', child: Text('Variable')),
    DropdownMenuItem(value: 'Marketing', child: Text('Marketing')),
    DropdownMenuItem(value: 'Servicios', child: Text('Servicios')),
  ],
  onChanged: (value) {
    setState(() {
      _selectedCategory = value!;
    });
  },
  decoration: const InputDecoration(labelText: 'Categoría'),
),


          const SizedBox(height: 20),

          // Guardar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
  onPressed: () {
    final expense = Expense(
      title: _titleController.text,
      amount: double.parse(_amountController.text),
      category: _selectedCategory,
      date: DateTime.now(),
    );

    ExpensesRepository.instance.addExpense(expense);

    Navigator.pop(context);
  },
  child: const Text('Agregar'),
),
          ),
        ],
      ),
    );
  }
}
