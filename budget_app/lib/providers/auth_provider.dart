import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isGuest = false;
  bool get isGuest => _isGuest;

  User? get user => _auth.currentUser;

  bool get isLoggedIn => _isGuest || _auth.currentUser != null;

  String? get email => _auth.currentUser?.email;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    if (_isLoading) return;

    _setLoading(true);

    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      _isGuest = false;
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapFirebaseError(e));
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signInWithGoogle() async {
  if (_isLoading) return;

  _setLoading(true);

  try {
    final GoogleSignInAccount? googleUser =
        await _googleSignIn.signIn();

    if (googleUser == null) {
      _setLoading(false);
      return;
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await _auth.signInWithCredential(credential);

    _isGuest = false;
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapFirebaseError(e));
    } finally {
      _setLoading(false);
    }
  }

  Future<void> register(String email, String password) async {
    if (_isLoading) return;

    _setLoading(true);

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
      _setLoading(false);
    }
  }

  Future<void> loginAsGuest() async {
    if (_isLoading) return;

    _setLoading(true);

    try {
      await _auth.signInAnonymously();
      _isGuest = true;
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapFirebaseError(e));
    } finally {
      _setLoading(false);
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

    _setLoading(true);

    try {
      await user.updateDisplayName(name.trim());
      await user.reload();
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapFirebaseError(e));
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateProfilePhoto(ImageSource source) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No hay usuario autenticado.');

    _setLoading(true);

    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1200,
      );

      if (picked == null) {
        _setLoading(false);
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
      _setLoading(false);
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
        return 'Demasiados intentos. Intenta más tarde.';
      default:
        return 'No se pudo completar la acción.';
    }
  }
}