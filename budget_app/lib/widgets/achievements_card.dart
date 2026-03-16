import 'package:flutter/material.dart';
import '../models/achievement.dart';

class AchievementsCard extends StatelessWidget {

  final List<Achievement> achievements;

  const AchievementsCard({super.key, required this.achievements});

  @override
  Widget build(BuildContext context) {

    final unlocked = achievements.where((a) => a.unlocked).toList();

    if (unlocked.isEmpty) return const SizedBox();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "Logros 🏆",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            ...unlocked.map((a) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text("✓ ${a.title}"),
            ))

          ],
        ),
      ),
    );
  }
}

