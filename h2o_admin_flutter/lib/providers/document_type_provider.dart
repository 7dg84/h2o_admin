import 'package:flutter/material.dart';
import '../models/document_type_model.dart';
import '../services/document_type_service.dart';

class DocumentTypeProvider with ChangeNotifier {
  final DocumentTypeService _service;
  bool _isLoading = false;
  String? _lastError;
  List<DocumentTypeModel> _documentTypes = [];
  int _documentTypesCount = 0;

  DocumentTypeProvider(this._service);

  List<DocumentTypeModel> get documentTypes => _documentTypes;
  int get documentTypesCount => _documentTypesCount;
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
      _documentTypes = (data['results'] as List<dynamic>).cast<DocumentTypeModel>();
      _documentTypesCount = data['count'] as int? ?? 0;
    } catch (e) {
      _lastError = e.toString();
      print("Error fetching document types: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<DocumentTypeModel?> getDetail(String id) async {
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

  Future<bool> createDocumentType(Map<String, dynamic> data) async {
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

  Future<bool> updateDocumentType(String id, Map<String, dynamic> data) async {
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

  Future<bool> deleteDocumentType(String id) async {
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
