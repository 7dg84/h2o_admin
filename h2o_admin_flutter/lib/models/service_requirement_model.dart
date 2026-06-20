class ServiceRequirementModel {
  final int id;
  final bool required;
  final String? notes;
  final String service;
  final String documentType;

  ServiceRequirementModel({
    required this.id,
    required this.required,
    this.notes,
    required this.service,
    required this.documentType,
  });

  factory ServiceRequirementModel.fromJson(Map<String, dynamic> json) {
    return ServiceRequirementModel(
      id: json['id'] ?? 0,
      required: json['required'] ?? false,
      notes: json['notes'],
      service: json['service'] ?? '',
      documentType: json['document_type'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'required': required,
      'notes': notes,
      'service': service,
      'document_type': documentType,
    };
  }
}
