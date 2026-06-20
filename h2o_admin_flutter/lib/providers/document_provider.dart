import 'package:flutter/material.dart';
import '../models/document_model.dart';
import '../services/document_service.dart';

class DocumentProvider with ChangeNotifier {
  final DocumentService _documentService;
  bool _isLoading = false;
  String? _lastError;
  List<DocumentModel> _documents = [];
  int _documentsCount = 0;

  DocumentProvider(this._documentService);

  List<DocumentModel> get documents => _documents;
  int get documentsCount => _documentsCount;
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
      final data = await _documentService.getAll(
        search: search,
        page: page,
        filters: filters,
      );
      _documents = (data['results'] as List<dynamic>).cast<DocumentModel>();
      _documentsCount = data['count'] as int? ?? 0;
    } catch (e) {
      _lastError = e.toString();
      print("Error fetching documents: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<DocumentModel?> getDetail(String id) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();
    try {
      final detail = await _documentService.getDetail(id);
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

  Future<bool> createDocument(Map<String, dynamic> data) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();
    try {
      await _documentService.create(data);
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

  Future<bool> updateDocument(String id, Map<String, dynamic> data) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();
    try {
      await _documentService.update(id, data);
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

  Future<bool> deleteDocument(String id) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();
    try {
      await _documentService.delete(id);
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
