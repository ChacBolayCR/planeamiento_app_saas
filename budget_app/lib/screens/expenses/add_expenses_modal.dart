import 'package:flutter/material.dart';
import '../../models/expense.dart';

class AddExpenseModal extends StatefulWidget {
  const AddExpenseModal({super.key});

  @override
  State<AddExpenseModal> createState() => _AddExpenseModalState();
}

class _AddExpenseModalState extends State<AddExpenseModal> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

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
            value: _category,
            items: const [
              DropdownMenuItem(value: 'Fijo', child: Text('Fijo')),
              DropdownMenuItem(value: 'Marketing', child: Text('Marketing')),
              DropdownMenuItem(value: 'Servicios', child: Text('Servicios')),
              DropdownMenuItem(value: 'Otros', child: Text('Otros')),
            ],
            onChanged: (value) {
              setState(() {
                _category = value!;
              });
            },
            decoration: InputDecoration(
              labelText: 'Categoría',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Guardar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_titleController.text.isEmpty ||
                    _amountController.text.isEmpty) {
                  return;
                }

                final expense = Expense(
                  title: _titleController.text,
                  category: _category,
                  amount: double.tryParse(_amountController.text) ?? 0,
                );

                Navigator.pop(context, expense);
              },
              child: const Text('Guardar gasto'),
            ),
          ),
        ],
      ),
    );
  }
}
