import 'package:flutter/material.dart';

class DashboardSection extends StatelessWidget {

  final String title;
  final IconData icon;
  final List<Widget> children;

  const DashboardSection({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {

    return Card(
      child: ExpansionTile(
        leading: Icon(icon),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        childrenPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        children: children,
      ),
    );
  }
}