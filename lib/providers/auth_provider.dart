import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/foundation.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  final fb_auth.FirebaseAuth _auth = fb_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AppUser? _user;
  bool _isLoading = false;
  String? _errorMessage;

  AppUser? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isAuthenticated => isLoggedIn;
  bool get isAdmin => _user?.isAdmin ?? false;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(fb_auth.User? firebaseUser) async {
    if (firebaseUser == null) {
      _user = null;
      notifyListeners();
      return;
    }
    await _loadUserProfile(firebaseUser);
  }

  Future<void> _loadUserProfile(fb_auth.User firebaseUser) async {
    try {
      final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
      if (doc.exists) {
        _user = AppUser.fromMap(doc.data()!);
      } else {
        _user = AppUser(
          uid: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          name: firebaseUser.email?.split('@').first ?? 'Usuário',
        );
      }
    } catch (e) {
      debugPrint('Erro ao carregar perfil do usuário: $e');
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      if (credential.user != null) {
        await _loadUserProfile(credential.user!);
      }
      return true;
    } on fb_auth.FirebaseAuthException catch (e) {
      _errorMessage = _mapAuthError(e.code);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signUp(String name, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final firebaseUser = credential.user;
      if (firebaseUser != null) {
        final newUser = AppUser(
          uid: firebaseUser.uid,
          email: email.trim().toLowerCase(),
          name: name.trim(),
        );
        await _firestore.collection('users').doc(firebaseUser.uid).set(newUser.toMap());
        _user = newUser;
      }
      return true;
    } on fb_auth.FirebaseAuthException catch (e) {
      _errorMessage = _mapAuthError(e.code);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    _user = null;
    notifyListeners();
  }

  String _mapAuthError(String code) {
    switch (code) {
      case 'invalid-email':
        return 'E-mail inválido.';
      case 'user-not-found':
        return 'Não existe conta com esse e-mail.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'E-mail ou senha incorretos.';
      case 'email-already-in-use':
        return 'Já existe uma conta com esse e-mail.';
      case 'weak-password':
        return 'A senha é muito fraca. Use pelo menos 6 caracteres.';
      default:
        return 'Não foi possível concluir. Tente novamente.';
    }
  }
}
