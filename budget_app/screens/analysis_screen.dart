import 'package:flutter/material.dart';

class AnalysisScreen extends StatelessWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Análisis mensual',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.fastfood),
              title: Text('Comida'),
              trailing: Text('₡120,000'),
            ),
            ListTile(
              leading: Icon(Icons.directions_car),
              title: Text('Transporte'),
              trailing: Text('₡80,000'),
            ),
            SizedBox(height: 16),
            Text(
              '💡 Consejo: Reduce comidas fuera y ahorra ₡25,000',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
