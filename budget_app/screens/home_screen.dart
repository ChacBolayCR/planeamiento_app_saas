import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/transaction_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Inicio')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Saldo: ₡${provider.balance.toStringAsFixed(0)}'),
            Text('Ingresos: ₡${provider.totalIncome.toStringAsFixed(0)}'),
            Text('Gastos: ₡${provider.totalExpenses.toStringAsFixed(0)}'),
          ],
        ),
      ),
    );
  }
}
