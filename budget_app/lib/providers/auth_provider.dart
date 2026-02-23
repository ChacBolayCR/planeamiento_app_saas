import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  String? _email;
  String? get email => _email;

  Future<void> login(String email, String password) async {
    // ✅ Simulación de login (luego lo conectamos a Firebase)
    await Future.delayed(const Duration(milliseconds: 700));

    _email = email.trim();
    _isLoggedIn = true;
    notifyListeners();
  }

  Future<void> loginAsGuest() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _email = null;
    _isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _email = null;
    notifyListeners();
  }
}
