import 'api_service.dart';
import '../models/service_model.dart';

class ServiceService {
  final ApiService _apiService;

  ServiceService(this._apiService);

  Future<Map<String, dynamic>> getAll({
    String? search,
    int page = 1,
    int? limit,
    Map<String, dynamic>? filters,
  }) async {
    try {
      Map<String, dynamic> queryParams = filters != null ? Map.from(filters) : {};
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (limit != null && limit > 0) queryParams['limit'] = limit;
      queryParams['page'] = page;

      final response =
          await _apiService.get('/services/', queryParameters: queryParams);
      final int count = response.data['count'] ?? 0;
      final List<dynamic> results = response.data['results'] ?? [];

      return {
        'results': results.map((json) => ServiceModel.fromJson(json)).toList(),
        'count': count,
      };
    } catch (e) {
      rethrow;
    }
  }

  Future<ServiceModel> getDetail(String id) async {
    try {
      final response = await _apiService.get('/services/$id/');
      return ServiceModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<ServiceModel> create(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.post('/services/', data: data);
      return ServiceModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<ServiceModel> update(String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.put('/services/$id/', data: data);
      return ServiceModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> delete(String id) async {
    try {
      await _apiService.delete('/services/$id/');
    } catch (e) {
      rethrow;
    }
  }
}
