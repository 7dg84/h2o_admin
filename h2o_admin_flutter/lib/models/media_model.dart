class MediaModel {
  final String id;
  final String presignedUrl;
  final String storageKey;
  final String filename;
  final String mimeType;
  final DateTime uploadedAt;
  final String reportId;

  MediaModel({
    required this.id,
    required this.presignedUrl,
    required this.storageKey,
    required this.filename,
    required this.mimeType,
    required this.uploadedAt,
    required this.reportId,
  });

  factory MediaModel.fromJson(Map<String, dynamic> json) {
    return MediaModel(
      id: json['id'],
      presignedUrl: json['presigned_url'] ?? '',
      storageKey: json['storage_key'] ?? '',
      filename: json['filename'] ?? '',
      mimeType: json['mime_type'] ?? '',
      uploadedAt: DateTime.parse(json['uploaded_at']),
      reportId: json['report'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'presigned_url': presignedUrl,
      'storage_key': storageKey,
      'filename': filename,
      'mime_type': mimeType,
      'uploaded_at': uploadedAt.toIso8601String(),
      'report': reportId,
    };
  }
}
