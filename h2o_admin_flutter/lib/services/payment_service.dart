import 'api_service.dart';
import '../models/payment_model.dart';

class PaymentService {
  final ApiService _apiService;

  PaymentService(this._apiService);

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
          await _apiService.get('/payment/', queryParameters: queryParams);
      final int count = response.data['count'] ?? 0;
      final List<dynamic> results = response.data['results'] ?? [];

      return {
        'results': results.map((json) => PaymentModel.fromJson(json)).toList(),
        'count': count,
      };
    } catch (e) {
      rethrow;
    }
  }

  Future<PaymentModel> getDetail(String id) async {
    try {
      final response = await _apiService.get('/payment/$id/');
      return PaymentModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<PaymentModel> create(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.post('/payment/', data: data);
      return PaymentModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<PaymentModel> update(String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.put('/payment/$id/', data: data);
      return PaymentModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> delete(String id) async {
    try {
      await _apiService.delete('/payment/$id/');
    } catch (e) {
      rethrow;
    }
  }
}
