import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  AppUser? _user;
  bool _isLoading = false;

  AppUser? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isAuthenticated => isLoggedIn;
  bool get isAdmin => _user?.isAdmin ?? false;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _loadUserSession();
  }

  Future<void> _loadUserSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userString = prefs.getString('auth_user');
      if (userString != null) {
        final Map<String, dynamic> map = json.decode(userString);
        _user = AppUser.fromMap(map);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Erro ao carregar sessão: $e');
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    // Simulação rápida de autenticação
    await Future.delayed(const Duration(milliseconds: 600));

    final trimmedEmail = email.trim().toLowerCase();
    
    // Regra simples: admin@halina.com ou admin@loja.com é Admin.
    // Qualquer outro login é usuário cliente normal.
    final bool isUserAdmin = trimmedEmail == 'admin@halina.com' || 
                            trimmedEmail == 'admin@loja.com' ||
                            trimmedEmail.contains('admin');

    String displayName = 'Usuário';
    if (isUserAdmin) {
      displayName = 'Administrador Halina';
    } else if (trimmedEmail.contains('@')) {
      final parts = trimmedEmail.split('@')[0];
      displayName = parts[0].toUpperCase() + parts.substring(1);
    }

    _user = AppUser(
      email: trimmedEmail,
      name: displayName,
      isAdmin: isUserAdmin,
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_user', json.encode(_user!.toMap()));
    } catch (e) {
      debugPrint('Erro ao salvar sessão: $e');
    }

    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _user = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_user');
    } catch (e) {
      debugPrint('Erro ao deslogar: $e');
    }
    notifyListeners();
  }
}
