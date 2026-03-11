import 'package:flutter/material.dart';

import 'screens/auth/auth_gate.dart';
import 'theme/kiki_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kiki Personal Budget',
      themeMode: ThemeMode.light,
      theme: KikiTheme.light(),
      home: const AuthGate(),
    );
  }
}