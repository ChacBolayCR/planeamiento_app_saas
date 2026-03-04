import 'package:flutter/material.dart';

import 'screens/auth/login_screen.dart';
import 'theme/kiki_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Budget App',
      // Base44 style
      themeMode: ThemeMode.light,
      theme: KikiTheme.light(),
      home: const LoginScreen(),
    );
  }
}