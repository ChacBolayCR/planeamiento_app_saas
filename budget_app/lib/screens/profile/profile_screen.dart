import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/budget_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _budgetController;
  String _selectedCurrency = 'USD';

  final List<Map<String, String>> _currencies = [
    {'code': 'USD', 'label': 'USD - Dólar'},
    {'code': 'CRC', 'label': 'CRC - Colón'},
    {'code': 'EUR', 'label': 'EUR - Euro'},
    {'code': 'MXN', 'label': 'MXN - Peso MX'},
  ];

  @override
  void initState() {
    super.initState();

    final provider = context.read<BudgetProvider>();

    _budgetController = TextEditingController(
      text: provider.monthlyBudget.toStringAsFixed(0),
    );

    _selectedCurrency = provider.currencyCode;
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    final provider = context.read<BudgetProvider>();

    final budget = double.tryParse(_budgetController.text);
    if (budget == null || budget <= 0) return;

    provider.setMonthlyBudget(budget);
    provider.setCurrency(_selectedCurrency);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Perfil actualizado'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final symbol = context.watch<BudgetProvider>().currencySymbol;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Perfil',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Configura tu presupuesto y moneda',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),

              /// PRESUPUESTO
              TextField(
                controller: _budgetController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Presupuesto mensual',
                  prefixText: '$symbol ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// MONEDA
              DropdownButtonFormField<String>(
                value: _selectedCurrency,
                decoration: InputDecoration(
                  labelText: 'Moneda',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _currencies
                    .map(
                      (c) => DropdownMenuItem(
                        value: c['code'],
                        child: Text(c['label']!),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedCurrency = value);
                  }
                },
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Guardar cambios',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
