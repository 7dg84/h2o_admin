import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
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

  Future<bool> toCSV() async {
    try {
      if (_tramites.isEmpty) {
        throw Exception('No hay trámites para exportar');
      }

      final headers = [
        'ID',
        'Folio',
        'Servicio',
        'Nombre del Servicio',
        'Fecha de Creación',
        'Estado',
        'Notas',
        'Usuario'
      ];

      final rows = <String>[];
      rows.add(headers.map((h) => '"${h.replaceAll('"', '""')}"').join(','));

      for (var tramite in _tramites) {
        rows.add(_toCsvRow([
          tramite.id,
          tramite.folio?.toString() ?? '',
          tramite.service,
          tramite.serviceName ?? '',
          tramite.createdAt.toIso8601String(),
          tramite.status,
          tramite.notes ?? '',
          tramite.user,
        ]));
      }

      final csvContent = rows.join('\n');

      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Guardar Trámites en CSV',
        fileName: 'tramites.csv',
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (outputFile == null) {
        return false;
      }

      if (!outputFile.toLowerCase().endsWith('.csv')) {
        outputFile = '$outputFile.csv';
      }

      final file = File(outputFile);
      await file.writeAsString(csvContent);
      return true;
    } catch (e) {
      print("Error exporting tramites to CSV: $e");
      rethrow;
    }
  }

  String _toCsvRow(List<dynamic> cells) {
    return cells.map((value) {
      if (value == null) return '';
      String str = value.toString();
      if (str.contains(',') || str.contains('"') || str.contains('\n') || str.contains('\r')) {
        return '"${str.replaceAll('"', '""')}"';
      }
      return str;
    }).join(',');
  }
}
