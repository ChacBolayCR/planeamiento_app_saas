import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Resumen general',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Así va tu negocio hoy',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 24),

              // KPI Cards
              LayoutBuilder(
  builder: (context, constraints) {
    final isWide = constraints.maxWidth > 900;

    return isWide
        ? Row(
            children: const [
              Expanded(child: _KpiCard(title: 'Ingresos', value: '\$12,450', color: Colors.green)),
              SizedBox(width: 16),
              Expanded(child: _KpiCard(title: 'Gastos', value: '\$6,320', color: Colors.red)),
              SizedBox(width: 16),
              Expanded(child: _KpiCard(title: 'Balance', value: '\$6,130', color: Colors.blue)),
            ],
          )
        : Column(
            children: const [
              _KpiCard(title: 'Ingresos', value: '\$12,450', color: Colors.green),
              SizedBox(height: 12),
              _KpiCard(title: 'Gastos', value: '\$6,320', color: Colors.red),
              SizedBox(height: 12),
              _KpiCard(title: 'Balance', value: '\$6,130', color: Colors.blue),
            ],
          );
  },
),


              const SizedBox(height: 24),

              // Chart placeholder
              Container(
                height: 220,
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Evolución mensual',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Expanded(
                      child: Center(
                        child: Text(
                          '📊 Gráfico próximamente',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Info box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Este resumen te permite entender rápidamente '
                  'el estado financiero de tu negocio sin complicaciones.',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
