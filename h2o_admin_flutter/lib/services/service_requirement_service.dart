import 'api_service.dart';
import '../models/service_requirement_model.dart';

class ServiceRequirementService {
  final ApiService _apiService;

  ServiceRequirementService(this._apiService);

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
          await _apiService.get('/service-requirements/', queryParameters: queryParams);
      final int count = response.data['count'] ?? 0;
      final List<dynamic> results = response.data['results'] ?? [];

      return {
        'results': results.map((json) => ServiceRequirementModel.fromJson(json)).toList(),
        'count': count,
      };
    } catch (e) {
      rethrow;
    }
  }

  Future<ServiceRequirementModel> getDetail(int id) async {
    try {
      final response = await _apiService.get('/service-requirements/$id/');
      return ServiceRequirementModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<ServiceRequirementModel> create(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.post('/service-requirements/', data: data);
      return ServiceRequirementModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<ServiceRequirementModel> update(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.put('/service-requirements/$id/', data: data);
      return ServiceRequirementModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> delete(int id) async {
    try {
      await _apiService.delete('/service-requirements/$id/');
    } catch (e) {
      rethrow;
    }
  }
}
