import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isGuest = false;
  bool get isGuest => _isGuest;

  User? get user => _auth.currentUser;
  bool get isLoggedIn => _isGuest || _auth.currentUser != null;
  String? get email => _auth.currentUser?.email;

  Future<void> login(String email, String password) async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      _isGuest = false;
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapFirebaseError(e));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String email, String password) async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      _isGuest = false;

      await _auth.setLanguageCode('es');
      await credential.user?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapFirebaseError(e));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loginAsGuest() async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 250));
      _isGuest = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isGuest = false;
    await _auth.signOut();
    notifyListeners();
  }

  Future<void> updateDisplayName(String name) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No hay usuario autenticado.');

    _isLoading = true;
    notifyListeners();

    try {
      await user.updateDisplayName(name.trim());
      await user.reload();
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapFirebaseError(e));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfilePhoto(ImageSource source) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No hay usuario autenticado.');

    _isLoading = true;
    notifyListeners();

    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1200,
      );

      if (picked == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      final Uint8List bytes = await picked.readAsBytes();

      final ref = FirebaseStorage.instance
          .ref()
          .child('users/${user.uid}/profile.jpg');

      await ref.putData(
        bytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final downloadUrl = await ref.getDownloadURL();

      await user.updatePhotoURL(downloadUrl);
      await user.reload();
    } on FirebaseException catch (e) {
      throw Exception('No se pudo subir la imagen: ${e.message ?? e.code}');
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapFirebaseError(e));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'El correo no es válido.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Correo o contraseña incorrectos.';
      case 'email-already-in-use':
        return 'Ese correo ya está registrado.';
      case 'weak-password':
        return 'La contraseña es muy débil.';
      case 'too-many-requests':
        return 'Demasiados intentos. Intenta de nuevo más tarde.';
      default:
        return 'No se pudo completar la acción.';
    }
  }
}