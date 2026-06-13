import 'package:flutter/material.dart';
import '../core/config.dart';

// 1. El enum DEBE estar definido aquí, fuera de la clase.
enum ReportStatus { recibido, enRevision, enAtencion, resuelto, cerrado }

class ReportModel {
  final String id;
  final String folio;
  final DateTime reportedAt;
  final double latitude;
  final double longitude;
  final String locationText;
  final String reportType;
  final String description;
  final ReportStatus status; // Aquí se usa el enum
  final String? assignedOperatorId;
  final String? estimatedTime;
  final List<String> media;

  ReportModel({
    required this.id,
    required this.folio,
    required this.reportedAt,
    required this.latitude,
    required this.longitude,
    required this.locationText,
    required this.reportType,
    required this.description,
    required this.status,
    this.assignedOperatorId,
    this.estimatedTime,
    this.media = const [],
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'],
      folio: json['folio'].toString(),
      reportedAt: DateTime.parse(json['reported_at']),
      latitude: double.parse(json['latitude'].toString()),
      longitude: double.parse(json['longitude'].toString()),
      locationText: json['location_text'] ?? '',
      reportType: json['report_type'] ?? '',
      description: json['description'] ?? '',
      status: _parseStatus(json['status']),
      assignedOperatorId: json['assigned_operator_id'],
      estimatedTime: json['estimated_time_interval'],
      media: List<String>.from(json['media'] ?? []),
    );
  }

  // 2. Este método estático mapea los strings de la API al Enum
  static ReportStatus _parseStatus(String? status) {
    switch (status) {
      case 'En revisión':
        return ReportStatus.enRevision;
      case 'En atención':
        return ReportStatus.enAtencion;
      case 'Resuelto':
        return ReportStatus.resuelto;
      case 'Cerrado':
        return ReportStatus.cerrado;
      default:
        return ReportStatus.recibido;
    }
  }

  String get statusText {
    switch (status) {
      case ReportStatus.enRevision: return 'En revisión';
      case ReportStatus.enAtencion: return 'En atención';
      case ReportStatus.resuelto: return 'Resuelto';
      case ReportStatus.cerrado: return 'Cerrado';
      default: return 'Recibido';
    }
  }

  Color get statusColor {
    switch (status) {
      case ReportStatus.enRevision: return AppConfig.statusInReview;
      case ReportStatus.enAtencion: return AppConfig.statusInAttention;
      case ReportStatus.resuelto: return AppConfig.statusResolved;
      case ReportStatus.cerrado: return AppConfig.statusClosed;
      default: return AppConfig.statusPending;
    }
  }
}