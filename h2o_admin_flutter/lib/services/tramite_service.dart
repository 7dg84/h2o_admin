import 'api_service.dart';
import '../models/tramite_model.dart';

class TramiteService {
  final ApiService _apiService;

  TramiteService(this._apiService);

  Future<Map<String, dynamic>> getAll({
    String? search,
    int page = 1,
    int? limit,
    Map<String, dynamic>? filters,
  }) async {
    try {
      Map<String, dynamic> queryParams =
          filters != null ? Map.from(filters) : {};
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (limit != null && limit > 0) queryParams['limit'] = limit;
      queryParams['page'] = page;

      final response =
          await _apiService.get('/tramites/', queryParameters: queryParams);
      final int count = response.data['count'] ?? 0;
      final List<dynamic> results = response.data['results'] ?? [];

      return {
        'results': results.map((json) => TramiteModel.fromJson(json)).toList(),
        'count': count,
      };
    } catch (e) {
      rethrow;
    }
  }

  Future<TramiteModel> getDetail(String id) async {
    try {
      final response = await _apiService.get('/tramites/$id/');
      return TramiteModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<TramiteModel> create(Map<String, dynamic> tramiteData) async {
    try {
      final response = await _apiService.post('/tramites/', data: tramiteData);
      return TramiteModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<TramiteModel> update(
      String id, Map<String, dynamic> tramiteData) async {
    try {
      final response = await _apiService.post('/tramites/$id/change_status/',
          data: tramiteData);
      print(response.data);
      if (response.data['status'] != 'ok') {
        throw response.data['status'];
      }
      return TramiteModel.fromJson(response.data['tramite']);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> delete(String id) async {
    try {
      await _apiService.delete('/tramites/$id/');
    } catch (e) {
      rethrow;
    }
  }
}
