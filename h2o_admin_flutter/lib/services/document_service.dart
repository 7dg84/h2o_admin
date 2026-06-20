import 'api_service.dart';
import '../models/document_model.dart';

class DocumentService {
  final ApiService _apiService;

  DocumentService(this._apiService);

  Future<Map<String, dynamic>> getAll({
    String? search,
    int page = 1,
    int? limit = 10,
    Map<String, dynamic>? filters,
  }) async {
    try {
      Map<String, dynamic> queryParams =
          filters != null ? Map.from(filters) : {};
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      // Limit results to 10 by default to save resources (generating presigned URLs)
      int finalLimit = (limit != null && limit > 0) ? limit : 10;
      queryParams['limit'] = finalLimit;
      queryParams['page'] = page;

      final response =
          await _apiService.get('/documents/', queryParameters: queryParams);
      final int count = response.data['count'] ?? 0;
      final List<dynamic> results = response.data['results'] ?? [];

      return {
        'results': results.map((json) => DocumentModel.fromJson(json)).toList(),
        'count': count,
      };
    } catch (e) {
      rethrow;
    }
  }

  Future<DocumentModel> getDetail(String id) async {
    try {
      final response = await _apiService.get('/documents/$id/');
      return DocumentModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<DocumentModel> create(Map<String, dynamic> documentData) async {
    try {
      final response = await _apiService.post('/documents/', data: documentData);
      return DocumentModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<DocumentModel> update(
      String id, Map<String, dynamic> documentData) async {
    try {
      final response =
          await _apiService.put('/documents/$id/', data: documentData);
      return DocumentModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> delete(String id) async {
    try {
      await _apiService.delete('/documents/$id/');
    } catch (e) {
      rethrow;
    }
  }
}
