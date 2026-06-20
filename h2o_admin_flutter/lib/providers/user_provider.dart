import 'package:flutter/material.dart';
import 'package:h2o_admin_flutter/services/user_service.dart';
import '../models/user_model.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

class UserProvider with ChangeNotifier {
  final UserService _userService;
  bool _isLoading = false;
  String? _lastError;
  List<UserModel> _users = [];
  int _usersCount = 0;

  UserProvider(this._userService) {}

  List<UserModel> get users => _users;
  int get usersCount => _usersCount;
  bool get isLoading => _isLoading;
  String? get lastError => _lastError;

  Future<List<UserModel>> getOperators(
    String? search,
  ) async {
    List<UserModel> operators;
    _isLoading = true;
    notifyListeners();
    try {
      operators = await _userService.getOperators(query: search);
    } catch (e) {
      if (e is ApiException) _lastError = e.message;
      operators = List.empty();
    }
    _isLoading = false;
    notifyListeners();
    return operators;
  }

  Future<void> getAll({
    String? search,
    int page = 1,
    Map<String, dynamic>? filters,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _userService.getAll(
        search: search,
        page: page,
        filters: filters,
      );
      _users = (data['results'] as List<dynamic>).cast<UserModel>();
      _usersCount = data['count'] as int? ?? 0;
    } catch (e) {
      print("Error fetching all reports: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createUser(Map<String, dynamic> userData) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();
    try {
      await _userService.create(userData);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _lastError = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateUser(String id, Map<String, dynamic> userData) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();
    try {
      await _userService.update(id, userData);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _lastError = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteUser(String id) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();
    try {
      await _userService.delete(id);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _lastError = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
