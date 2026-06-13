import 'dart:io';
import 'package:dio/dio.dart';
import '../models/report_model.dart';
import '../models/media_model.dart';
import 'api_service.dart';

class ReportCoordinate {
  final String id;
  final double latitude;
  final double longitude;
  final String reportType;

  ReportCoordinate({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.reportType,
  });

  factory ReportCoordinate.fromJson(Map<String, dynamic> json) {
    return ReportCoordinate(
      id: json['id'],
      latitude: double.parse(json['latitude'].toString()),
      longitude: double.parse(json['longitude'].toString()),
      reportType: json['report_type'],
    );
  }
}

class ReportService {
  final ApiService _apiService;

  ReportService(this._apiService);

  Future<List<ReportModel>> getRecentReports({int limit = 2}) async {
    try {
      final response = await _apiService.get('/reports/', queryParameters: {
        'limit': limit,
        'ordering': '-reported_at',
      });

      final List<dynamic> results = response.data['results'] ?? [];
      return results.map((json) => ReportModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getAllReports({int limit = 20}) async {
    try {
      final response = await _apiService.get('/reports/', queryParameters: {
        'limit': limit,
        'ordering': '-reported_at',
      });

      final int count = response.data['count'] ?? 0;
      final String next = response.data['next'] ?? '';
      final String previous = response.data['previous'] ?? '';
      final List<dynamic> results = response.data['results'] ?? [];
      return {
        'results': results.map((json) => ReportModel.fromJson(json)).toList(),
        'count': count,
      };
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ReportCoordinate>> getReportCoordinates() async {
    try {
      final response = await _apiService.get('/report-coordinates/');
      final List<dynamic> results = response.data['results'] ?? [];
      return results.map((json) => ReportCoordinate.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<ReportModel> getReportDetail(String id) async {
    try {
      final response = await _apiService.get('/reports/$id/');
      return ReportModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<ReportModel> createReport({
    required double latitude,
    required double longitude,
    required String locationText,
    required String reportType,
    required String description,
  }) async {
    try {
      final response = await _apiService.post('/reports/', data: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'location_text': locationText,
        'report_type': reportType,
        'description': description,
      });

      return ReportModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<ReportModel> updateReport(
    String id, {
    required double? latitude,
    required double? longitude,
    required String? locationText,
    required String? reportType,
    required String? description,
  }) async {
    try {
      final Map<String, dynamic> data = {};
      if (latitude != null) data['latitude'] = latitude.toString();
      if (longitude != null) data['longitude'] = longitude.toString();
      if (locationText != null) data['location_text'] = locationText;
      if (reportType != null) data['report_type'] = reportType;
      if (description != null) data['description'] = description;

      final response = await _apiService.put('/reports/$id/', data: data);
      return ReportModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteReport(String id) async {
    try {
      await _apiService.delete('/reports/$id/');
    } catch (e) {
      rethrow;
    }
  }

  Future<MediaModel> getMedia(String mediaId) async {
    try {
      final response = await _apiService.get('/media/$mediaId/');
      return MediaModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> uploadMedia(String reportId, File file) async {
    try {
      String fileName = file.path.split('/').last;
      FormData formData = FormData.fromMap({
        'report': reportId,
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
      });

      await _apiService.post('/media/', data: formData);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteMedia(String mediaId) async {
    try {
      await _apiService.delete('/media/$mediaId/');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> assignReport(String reportId, String operatorId) async {
    try {
      await _apiService.post('/reports/$reportId/assign/', data: {
        'operator': operatorId,
      });
    } catch (e) {
      rethrow;
    }
  }
}
