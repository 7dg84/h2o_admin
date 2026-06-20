class ReviewModel {
  final String id;
  final int value;
  final DateTime createdAt;
  final String user;
  final String? report;
  final String? tramite;

  ReviewModel({
    required this.id,
    required this.value,
    required this.createdAt,
    required this.user,
    this.report,
    this.tramite,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'],
      value: json['value'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      user: json['user'] ?? '',
      report: json['report'],
      tramite: json['tramite'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'value': value,
      'created_at': createdAt.toIso8601String(),
      'user': user,
      'report': report,
      'tramite': tramite,
    };
  }
}
