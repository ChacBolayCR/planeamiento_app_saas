import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction.dart';
import '../services/transaction_provider.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _amountController = TextEditingController();
  String _category = 'Comida';
  bool _isIncome = false;

  void _saveTransaction() {
    final amount = double.tryParse(_amountController.text);
    if (amount == null) return;

    final transaction = TransactionModel(
      id: const Uuid().v4(),
      amount: amount,
      category: _category,
      date: DateTime.now(),
      isIncome: _isIncome,
    );

    Provider.of<TransactionProvider>(context, listen: false)
        .addTransaction(transaction);

    _amountController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Movimiento guardado')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SwitchListTile(
            title: Text(_isIncome ? 'Ingreso' : 'Gasto'),
            value: _isIncome,
            onChanged: (val) => setState(() => _isIncome = val),
          ),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Monto'),
          ),
          DropdownButtonFormField(
            value: _category,
            items: const [
              DropdownMenuItem(value: 'Comida', child: Text('🍔 Comida')),
              DropdownMenuItem(value: 'Transporte', child: Text('🚗 Transporte')),
              DropdownMenuItem(value: 'Casa', child: Text('🏠 Casa')),
            ],
            onChanged: (value) => setState(() => _category = value.toString()),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _saveTransaction,
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
