import 'package:flutter/material.dart';
import '../models/tramite_model.dart';
import '../services/tramite_service.dart';

class TramiteProvider with ChangeNotifier {
  final TramiteService _tramiteService;
  bool _isLoading = false;
  String? _lastError;
  List<TramiteModel> _tramites = [];
  int _tramitesCount = 0;

  TramiteProvider(this._tramiteService);

  List<TramiteModel> get tramites => _tramites;
  int get tramitesCount => _tramitesCount;
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
      final data = await _tramiteService.getAll(
        search: search,
        page: page,
        filters: filters,
      );
      _tramites = (data['results'] as List<dynamic>).cast<TramiteModel>();
      _tramitesCount = data['count'] as int? ?? 0;
    } catch (e) {
      _lastError = e.toString();
      print("Error fetching tramites: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<TramiteModel?> getDetail(String id) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();
    try {
      final detail = await _tramiteService.getDetail(id);
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

  Future<bool> createTramite(Map<String, dynamic> data) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();
    try {
      await _tramiteService.create(data);
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

  Future<bool> updateTramite(String id, Map<String, dynamic> data) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();
    try {
      await _tramiteService.update(id, data);
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

  Future<bool> deleteTramite(String id) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();
    try {
      await _tramiteService.delete(id);
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
