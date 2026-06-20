class DocumentModel {
  final String id;
  final String? presignedUrl;
  final String? storageKey;
  final String filename;
  final String? mimeType;
  final int? size;
  final DateTime? uploadedAt;
  final String? tramite;
  final String? documentType;

  DocumentModel({
    required this.id,
    this.presignedUrl,
    this.storageKey,
    required this.filename,
    this.mimeType,
    this.size,
    this.uploadedAt,
    this.tramite,
    this.documentType,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id'],
      presignedUrl: json['presigned_url'],
      storageKey: json['storage_key'],
      filename: json['filename'] ?? '',
      mimeType: json['mime_type'],
      size: json['size'],
      uploadedAt: json['uploaded_at'] != null
          ? DateTime.parse(json['uploaded_at'])
          : null,
      tramite: json['tramite'],
      documentType: json['document_type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'presigned_url': presignedUrl,
      'storage_key': storageKey,
      'filename': filename,
      'mime_type': mimeType,
      'size': size,
      'uploaded_at': uploadedAt?.toIso8601String(),
      'tramite': tramite,
      'document_type': documentType,
    };
  }
}
