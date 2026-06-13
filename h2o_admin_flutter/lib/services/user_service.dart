import 'api_service.dart';
import '../models/user_model.dart';

class UserService {
  final ApiService _apiService;

  UserService(this._apiService);

  Future<List<UserModel>> getOperators({String? query, int limit = 20}) async {
    final Map<String, dynamic> qp = {
      'role': 'operator',
      'limit': limit,
    };
    if (query != null && query.trim().isNotEmpty) qp['search'] = query.trim();

    final response = await _apiService.get('/users/', queryParameters: qp);
    final List<dynamic> results = response.data['results'] ?? [];
    return results.map((j) => UserModel.fromJson(j)).toList();
  }
}
