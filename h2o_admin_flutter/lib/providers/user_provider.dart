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
  // List<UserModel?> _user;
  bool _isLoading = false;
  String? _lastError;

  UserProvider(this._userService) {}

  Future<List<UserModel>> getOperators(String? search,) async {
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
}
