import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  UserModel? _user;
  bool _isLoading = false;
  String? _lastError;

  AuthProvider(this._authService) {
    _checkCurrentUser();
  }

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  String? get lastError => _lastError;

  Future<void> _checkCurrentUser() async {
    _isLoading = true;
    notifyListeners();
    try {
      _user = await _authService.getCurrentUser();
    } catch (e) {
      if (e is ApiException) _lastError = e.message;
      _user = null;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      _user = await _authService.login(email, password);
      _lastError = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      if (e is ApiException)
        _lastError = e.message;
      else
        _lastError = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String curp,
    required String name,
    required String phone,
    required String postalCode,
    required String colonia,
    required String street,
    String? block,
    String? exteriorNumber,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      _user = await _authService.register({
        'email': email,
        'password': password,
        'curp': curp,
        'name': name,
        'phone': phone,
        'postal_code': postalCode,
        'colonia': colonia,
        'street': street,
        'block': block,
        'exterior_number': exteriorNumber,
      });
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      if (e is ApiException)
        _lastError = e.message;
      else
        _lastError = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<Map<String, dynamic>?> updateProfile({
    required String email,
    required String curp,
    required String password,
    required String name,
    required String phone,
    required String postalCode,
    required String colonia,
    required String street,
    String? block,
    String? exteriorNumber,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.updateInfo({
        // 'email': email,
        // 'curp': curp,
        'password': password,
        'name': name,
        'phone': phone,
        'postal_code': postalCode,
        'colonia': colonia,
        'street': street,
        'block': block,
        'exterior_number': exteriorNumber,
      });

      // Refrescamos los datos del usuario después de la actualización exitosa
      _user = await _authService.getCurrentUser();

      _isLoading = false;
      notifyListeners();
      return null; // Éxito
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      if (e is Map<String, dynamic>) {
        return e; // Devolvemos el mapa de errores del servidor
      }
      if (e is ApiException) return {'error': e.message};
      return {'error': 'Ocurrió un error inesperado'};
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
    } finally {
      _user = null;
      notifyListeners();
    }
  }
}
