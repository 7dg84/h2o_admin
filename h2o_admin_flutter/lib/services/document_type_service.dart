import 'api_service.dart';
import '../models/document_type_model.dart';

class DocumentTypeService {
  final ApiService _apiService;

  DocumentTypeService(this._apiService);

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
          await _apiService.get('/document-types/', queryParameters: queryParams);
      final int count = response.data['count'] ?? 0;
      final List<dynamic> results = response.data['results'] ?? [];

      return {
        'results': results.map((json) => DocumentTypeModel.fromJson(json)).toList(),
        'count': count,
      };
    } catch (e) {
      rethrow;
    }
  }

  Future<DocumentTypeModel> getDetail(String id) async {
    try {
      final response = await _apiService.get('/document-types/$id/');
      return DocumentTypeModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<DocumentTypeModel> create(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.post('/document-types/', data: data);
      return DocumentTypeModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<DocumentTypeModel> update(String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.put('/document-types/$id/', data: data);
      return DocumentTypeModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> delete(String id) async {
    try {
      await _apiService.delete('/document-types/$id/');
    } catch (e) {
      rethrow;
    }
  }
}
