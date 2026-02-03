import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Perfil',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.attach_money),
              title: Text('Ingreso mensual'),
              subtitle: Text('₡600,000'),
            ),
            ListTile(
              leading: Icon(Icons.savings),
              title: Text('Meta de ahorro'),
              subtitle: Text('₡100,000'),
            ),
          ],
        ),
      ),
    );
  }
}
