import 'package:dio/dio.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

class AuthService {
  final ApiService _apiService;

  AuthService(this._apiService);

  Future<UserModel> login(String email, String password) async {
    // 1. Intentar login
    final response = await _apiService.post('/auth/login/', data: {
      'email': email,
      'password': password,
    });

    if (response.statusCode == 200) {
      if (response.data is Map && response.data.containsKey('detail')) {
        throw ApiException(response.data['detail'].toString());
      }
      // 2. Si el login es exitoso, obtenemos los datos del usuario (la cookie ya está guardada)
      final user = await getCurrentUser();
      if (user == null) throw ApiException('No se pudo obtener el perfil');
      return user;
    } else {
      // try to surface server message
      if (response.data is Map && response.data.containsKey('detail')) {
        throw ApiException(response.data['detail'].toString());
      }
      throw ApiException('Credenciales inválidas');
    }
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      final response = await _apiService.get('/auth/user/');
      if (response.data is Map && response.data.containsKey('detail')) {
        throw ApiException(response.data['detail'].toString());
      }
      return UserModel.fromJson(response.data);
    } catch (e) {
      if (e is DioException && e.response != null && e.response!.data is Map && e.response!.data['detail'] != null) {
        throw ApiException(e.response!.data['detail'].toString());
      }
      // Propagate other exceptions to caller
      rethrow;
    }
  }

  // El registro devuelve id y email, podemos usar eso para crear un UserModel parcial o llamar a user/
  Future<UserModel> register(Map<String, dynamic> data) async {
    final response = await _apiService.post('/auth/register/', data: data);
    if (response.statusCode == 201) {
      if (response.data is Map && response.data.containsKey('detail')) {
        throw ApiException(response.data['detail'].toString());
      }
      final user = await getCurrentUser();
      return user ?? UserModel.fromJson(response.data);
    }
    if (response.data is Map && response.data.containsKey('detail')) {
      throw ApiException(response.data['detail'].toString());
    }
    throw ApiException('Error en el registro');
  }

  Future<void> logout() async {
    await _apiService.post('/auth/logout/');
  }

  Future<void> updateInfo(Map<String, dynamic> data) async {
    try {
      await _apiService.put('/auth/update_info/', data: data);
    } on DioException catch (e) {
      if (e.response != null && e.response!.data is Map) {
        final map = e.response!.data as Map;
        if (map.containsKey('detail')) throw ApiException(map['detail'].toString());
        throw map;
      }
      rethrow;
    }
  }
}