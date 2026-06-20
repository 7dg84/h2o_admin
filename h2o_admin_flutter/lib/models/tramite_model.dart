class TramiteDocumentShort {
  final String id;
  final String filename;
  final String name;

  TramiteDocumentShort({
    required this.id,
    required this.filename,
    required this.name,
  });

  factory TramiteDocumentShort.fromJson(Map<String, dynamic> json) {
    return TramiteDocumentShort(
      id: json['id'],
      filename: json['filename'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filename': filename,
      'name': name,
    };
  }
}

class TramiteModel {
  final String id;
  final List<TramiteDocumentShort> documents;
  final String service;
  final String? serviceName;
  final int? folio;
  final DateTime createdAt;
  final String status;
  final String? notes;
  final String user;

  TramiteModel({
    required this.id,
    required this.documents,
    required this.service,
    this.serviceName,
    this.folio,
    required this.createdAt,
    required this.status,
    this.notes,
    required this.user,
  });

  factory TramiteModel.fromJson(Map<String, dynamic> json) {
    var list = json['documents'] as List? ?? [];
    List<TramiteDocumentShort> docList =
        list.map((i) => TramiteDocumentShort.fromJson(i)).toList();

    return TramiteModel(
      id: json['id'],
      documents: docList,
      service: json['service'],
      serviceName: json['service_name'],
      folio: json['folio'],
      createdAt: DateTime.parse(json['created_at']),
      status: json['status'] ?? '',
      notes: json['notes'],
      user: json['user'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'documents': documents.map((e) => e.toJson()).toList(),
      'service': service,
      'service_name': serviceName,
      'folio': folio,
      'created_at': createdAt.toIso8601String(),
      'status': status,
      'notes': notes,
      'user': user,
    };
  }
}
