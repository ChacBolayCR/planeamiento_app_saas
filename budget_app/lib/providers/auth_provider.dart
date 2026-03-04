import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _email;
  String? get email => _email;

  bool get isGuest => _email == null && _isLoggedIn;

  /// Simulación login email/password
  Future<void> login(String email, String password) async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 700));

      _email = email.trim();
      _isLoggedIn = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Login como invitado
  Future<void> loginAsGuest() async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 300));

      _email = null;
      _isLoggedIn = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Logout
  void logout() {
    _isLoggedIn = false;
    _email = null;
    notifyListeners();
  }
}