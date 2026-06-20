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

  Future<Map<String, dynamic>> getAll(
      {String? search,
      int page = 1,
      int? limit,
      Map<String, dynamic>? filters}) async {
    try {
      Map<String, dynamic> _filters = filters ?? {};
      if (search != null && search.isNotEmpty) _filters['search'] = search;
      if (limit != null && limit > 0) _filters['limit'] = limit;
      _filters['page'] = page;
      final response = await _apiService.get('/usrs/', queryParameters: _filters);

      final int count = response.data['count'] ?? 0;
      final String next = response.data['next'] ?? '';
      final String previous = response.data['previous'] ?? '';
      final List<dynamic> results = response.data['results'] ?? [];
      return {
        'results': results.map((json) => UserModel.fromJson(json)).toList(),
        'count': count,
      };
    } catch (e) {
      rethrow;
    }
  }
}
