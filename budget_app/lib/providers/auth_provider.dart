import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  bool _isNewUser = true;

  bool get isNewUser => _isNewUser;

  void markUserAsActive() {
    _isNewUser = false;
    notifyListeners();
  }

  // En el futuro:
  // - cargar desde storage
  // - backend
}
