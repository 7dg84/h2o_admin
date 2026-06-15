Map<String, dynamic> buildQuerryParameters({
  String? search,
  int? limit,
  required int page,
  String? status,
  String? createdAt,
}) {
  // Inicializamos el mapa con los valores obligatorios o por defecto
  final Map<String, dynamic> params = {
    'page': page,
    'ordering': '-reported_at', // Orden por defecto
  };

  // Validar y agregar 'search'
  if (search != null && search.trim().isNotEmpty) {
    params['search'] = search.trim();
  }

  // Validar y agregar 'limit'
  if (limit != null && limit > 0) {
    params['limit'] = limit;
  }

  // Validar y agregar 'status'
  if (status != null && status.trim().isNotEmpty) {
    params['status'] = status.trim();
  }

  // Validar y agregar 'created_at' o 'reported_at__gte'
  if (createdAt != null && createdAt.trim().isNotEmpty) {
    params['reported_at__gte'] = createdAt.trim();
  }

  return params;
}