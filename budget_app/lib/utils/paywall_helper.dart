import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/budget_provider.dart';
import '../screens/pro/upgrade_pro_screen.dart';

class PaywallHelper {
  static bool _isShowing = false;

  static void showIfNeeded(BuildContext context, bool shouldShow) {
    if (!shouldShow || _isShowing) return;

    final budget = context.read<BudgetProvider>();

    if (budget.paywallVariant == 'A') {
      _showFullPaywall(context);
    } else {
      _showSoftPaywall(context);
    }
  }

  static void _showFullPaywall(BuildContext context) {
    _isShowing = true;

    Future.microtask(() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) => const UpgradeProScreen(),
      ).whenComplete(() {
        _isShowing = false;
      });
    });
  }

  static void _showSoftPaywall(BuildContext context) {
    _isShowing = true;

    Future.microtask(() async {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Límite alcanzado"),
          content: const Text(
            "Llegaste al límite del plan gratis 😅\n\n"
            "Podés desbloquear gastos ilimitados con Pro.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _isShowing = false;
              },
              child: const Text("Después"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);

                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => const UpgradeProScreen(),
                ).whenComplete(() {
                  _isShowing = false;
                });
              },
              child: const Text("Ver Pro"),
            ),
          ],
        ),
      );
    });
  }
}