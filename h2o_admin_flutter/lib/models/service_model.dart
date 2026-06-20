class ServiceRequirementShort {
  final String documentTypeId;
  final String documentTypeName;
  final bool required;
  final String? notes;

  ServiceRequirementShort({
    required this.documentTypeId,
    required this.documentTypeName,
    required this.required,
    this.notes,
  });

  factory ServiceRequirementShort.fromJson(Map<String, dynamic> json) {
    return ServiceRequirementShort(
      documentTypeId: json['document_type_id'] ?? '',
      documentTypeName: json['document_type_name'] ?? '',
      required: json['required'] ?? false,
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'document_type_id': documentTypeId,
      'document_type_name': documentTypeName,
      'required': required,
      'notes': notes,
    };
  }
}

class ServiceModel {
  final String id;
  final String name;
  final String description;
  final String responseTime;
  final List<ServiceRequirementShort> requirements;

  ServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.responseTime,
    required this.requirements,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    var reqList = json['requirements'] as List? ?? [];
    List<ServiceRequirementShort> reqs =
        reqList.map((i) => ServiceRequirementShort.fromJson(i)).toList();

    return ServiceModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      responseTime: json['response_time'] ?? '',
      requirements: reqs,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'response_time': responseTime,
      'requirements': requirements.map((e) => e.toJson()).toList(),
    };
  }
}
