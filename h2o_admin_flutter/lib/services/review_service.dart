import 'api_service.dart';
import '../models/review_model.dart';

class ReviewService {
  final ApiService _apiService;

  ReviewService(this._apiService);

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
          await _apiService.get('/reviews/', queryParameters: queryParams);
      final int count = response.data['count'] ?? 0;
      final List<dynamic> results = response.data['results'] ?? [];

      return {
        'results': results.map((json) => ReviewModel.fromJson(json)).toList(),
        'count': count,
      };
    } catch (e) {
      rethrow;
    }
  }

  Future<ReviewModel> getDetail(String id) async {
    try {
      final response = await _apiService.get('/reviews/$id/');
      return ReviewModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> delete(String id) async {
    try {
      await _apiService.delete('/reviews/$id/');
    } catch (e) {
      rethrow;
    }
  }
}
