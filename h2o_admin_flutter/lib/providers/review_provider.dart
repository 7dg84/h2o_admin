import 'package:flutter/material.dart';
import '../models/review_model.dart';
import '../services/review_service.dart';

class ReviewProvider with ChangeNotifier {
  final ReviewService _reviewService;
  bool _isLoading = false;
  String? _lastError;
  List<ReviewModel> _reviews = [];
  int _reviewsCount = 0;

  ReviewProvider(this._reviewService);

  List<ReviewModel> get reviews => _reviews;
  int get reviewsCount => _reviewsCount;
  bool get isLoading => _isLoading;
  String? get lastError => _lastError;

  Future<void> getAll({
    String? search,
    int page = 1,
    Map<String, dynamic>? filters,
  }) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();
    try {
      final data = await _reviewService.getAll(
        search: search,
        page: page,
        filters: filters,
      );
      _reviews = (data['results'] as List<dynamic>).cast<ReviewModel>();
      _reviewsCount = data['count'] as int? ?? 0;
    } catch (e) {
      _lastError = e.toString();
      print("Error fetching reviews: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<ReviewModel?> getDetail(String id) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();
    try {
      final detail = await _reviewService.getDetail(id);
      _isLoading = false;
      notifyListeners();
      return detail;
    } catch (e) {
      _lastError = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> deleteReview(String id) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();
    try {
      await _reviewService.delete(id);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _lastError = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
