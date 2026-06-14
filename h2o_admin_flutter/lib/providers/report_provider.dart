import 'dart:io';
import 'package:flutter/material.dart';
import '../models/report_model.dart';
import '../models/media_model.dart';
import '../services/report_service.dart';

class ReportProvider with ChangeNotifier {
  final ReportService _reportService;
  List<ReportModel> _recentReports = [];
  List<ReportModel> _allReports = [];
  int _allReportsCount = 0;
  List<ReportCoordinate> _reportCoordinates = [];
  int _pendingReportsCount = 0;
  int _attentionReportsCount = 0;
  int _solvedReportsCount = 0;
  bool _isLoading = false;

  ReportProvider(this._reportService);

  List<ReportModel> get recentReports => _recentReports;
  List<ReportModel> get allReports => _allReports;
  int get allReportsCount => _allReportsCount;
  List<ReportCoordinate> get reportCoordinates => _reportCoordinates;
  bool get isLoading => _isLoading;
  int get pendingReportscount => _pendingReportsCount;
  int get attentionReportsCount => _attentionReportsCount;
  int get solvedReportsCount => _solvedReportsCount;

  Future<void> fetchRecentReports() async {
    _isLoading = true;
    notifyListeners();
    try {
      _recentReports = await _reportService.getRecentReports();
    } catch (e) {
      print("Error fetching recent reports: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllReports({String? search}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _reportService.getReports(search: search);
      _allReports = (data['results'] as List<dynamic>).cast<ReportModel>();
      _allReportsCount = data['count'] as int? ?? 0;
    } catch (e) {
      print("Error fetching all reports: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchReportCoordinates() async {
    _isLoading = true;
    notifyListeners();
    try {
      _reportCoordinates = await _reportService.getReportCoordinates();
    } catch (e) {
      print("Error fetching report coordinates: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchPendingReports() async {
    _isLoading = true;
    notifyListeners();
    try {
      final data =
          await _reportService.getReports(status: 'Recibido', limit: 1);
      _pendingReportsCount = data['count'] as int? ?? 0;
    } catch (e) {
      print("Error fetching all reports: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchSolvedReports() async {
    _isLoading = true;
    notifyListeners();
    final lastMonth = DateTime.now().subtract(Duration(days: 30));
    try {
      final data = await _reportService.getReports(
          status: 'Resuelto',
          created_at:
              "${lastMonth.year}-${lastMonth.month.toString().padLeft(2, '0')}-${lastMonth.day.toString().padLeft(2, '0')}",
          limit: 1);
      _solvedReportsCount = data['count'] as int? ?? 0;
    } catch (e) {
      print("Error fetching all reports: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAttentionReports() async {
    _isLoading = true;
    notifyListeners();
    try {
      final data =
          await _reportService.getReports(status: 'En atención', limit: 1);
      _attentionReportsCount = data['count'] as int? ?? 0;
    } catch (e) {
      print("Error fetching all reports: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<ReportModel?> getReportDetail(String id) async {
    _isLoading = true;
    // Usamos microtask para evitar el error de notifyListeners durante el build
    Future.microtask(() => notifyListeners());
    try {
      return await _reportService.getReportDetail(id);
    } catch (e) {
      print("Error fetching report detail: $e");
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<MediaModel?> getMediaDetail(String mediaId) async {
    try {
      return await _reportService.getMedia(mediaId);
    } catch (e) {
      print("Error fetching media detail: $e");
      return null;
    }
  }

  Future<List<MediaModel>> getReportMedia(List<String> mediaIds) async {
    List<MediaModel> mediaList = [];
    for (var id in mediaIds) {
      final media = await getMediaDetail(id);
      if (media != null) {
        mediaList.add(media);
      }
    }
    return mediaList;
  }

  Future<ReportModel?> createReport({
    required double latitude,
    required double longitude,
    required String locationText,
    required String reportType,
    required String description,
    List<File> images = const [],
  }) async {
    _isLoading = true;
    notifyListeners();

    // Limpiar coordenadas a 10 decimales
    double cleanLat = double.parse(latitude.toStringAsFixed(10));
    double cleanLong = double.parse(longitude.toStringAsFixed(10));

    try {
      final report = await _reportService.createReport(
        latitude: cleanLat,
        longitude: cleanLong,
        locationText: locationText,
        reportType: reportType,
        description: description,
      );

      for (var image in images) {
        try {
          await _reportService.uploadMedia(report.id, image);
        } catch (e) {
          print("Error uploading image: $e");
        }
      }

      await fetchRecentReports();
      await fetchReportCoordinates();
      await fetchAllReports();
      return report;
    } catch (e) {
      print("Error creating report: $e");
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateReport(
    String id, {
    required double latitude,
    required double longitude,
    required String locationText,
    required String reportType,
    required String description,
  }) async {
    _isLoading = true;
    notifyListeners();

    double cleanLat = double.parse(latitude.toStringAsFixed(10));
    double cleanLong = double.parse(longitude.toStringAsFixed(10));

    try {
      await _reportService.updateReport(
        id,
        latitude: cleanLat,
        longitude: cleanLong,
        locationText: locationText,
        reportType: reportType,
        description: description,
      );
      await fetchRecentReports();
      await fetchReportCoordinates();
      return true;
    } catch (e) {
      print("Error updating report: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteReport(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _reportService.deleteReport(id);
      _recentReports.removeWhere((r) => r.id == id);
      await fetchRecentReports();
      _reportCoordinates.removeWhere((c) => c.id == id);
      _allReports.removeWhere((r) => r.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      print("Error deleting report: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> assignReport(String reportId, String operatorId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _reportService.assignReport(reportId, operatorId);
      await fetchAllReports();
      await fetchRecentReports();
      return true;
    } catch (e) {
      print("Error assigning report: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  double getAvrageTime() {
    List<double> allReportTime = allReports
        .map((r) => r.estimatedTime) // Extrae el tiempo estimado
        .toList()
        .where((t) => t != null) // Quita los nulos
        .map((e) => e!.replaceAll('h', '').trim()) // quitamos la h
        .map((ts) => double.tryParse(ts!)) // Intenta convertir a número
        .whereType<double>() // Quita los que fallaron (fueron null)
        .toList();
    ;
    if (allReportTime.isEmpty) {
      return 0;
    } else {
      double avr = allReportTime.reduce((a, b) => a + b) / allReportTime.length;
      return avr;
    }
  }
}
