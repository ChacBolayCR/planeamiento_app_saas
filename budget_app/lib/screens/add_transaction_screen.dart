import 'package:flutter/material.dart';

class AddTransactionScreen extends StatelessWidget {
  const AddTransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo gasto'),
      ),
      body: const Center(
        child: Text(
          'ADD OK',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
