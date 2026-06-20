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
}
