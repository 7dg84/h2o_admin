import 'package:flutter/material.dart';
import '../models/service_requirement_model.dart';
import '../services/service_requirement_service.dart';

class ServiceRequirementProvider with ChangeNotifier {
  final ServiceRequirementService _service;
  bool _isLoading = false;
  String? _lastError;
  List<ServiceRequirementModel> _requirements = [];
  int _requirementsCount = 0;

  ServiceRequirementProvider(this._service);

  List<ServiceRequirementModel> get requirements => _requirements;
  int get requirementsCount => _requirementsCount;
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
      final data = await _service.getAll(
        search: search,
        page: page,
        filters: filters,
      );
      _requirements = (data['results'] as List<dynamic>).cast<ServiceRequirementModel>();
      _requirementsCount = data['count'] as int? ?? 0;
    } catch (e) {
      _lastError = e.toString();
      print("Error fetching service requirements: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<ServiceRequirementModel?> getDetail(int id) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();
    try {
      final detail = await _service.getDetail(id);
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

  Future<bool> createRequirement(Map<String, dynamic> data) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();
    try {
      await _service.create(data);
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

  Future<bool> updateRequirement(int id, Map<String, dynamic> data) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();
    try {
      await _service.update(id, data);
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

  Future<bool> deleteRequirement(int id) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();
    try {
      await _service.delete(id);
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
