import 'package:flutter/material.dart';

class FilterDialog extends StatefulWidget {
  final Map<String, dynamic> initialFilters;

  const FilterDialog({
    required this.initialFilters,
    super.key,
  });

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  late Map<String, dynamic> _filters;
  String? _ordering;

  // Controllers para campos de texto
  late TextEditingController _idController;
  late TextEditingController _folioController;
  late TextEditingController _latController;
  late TextEditingController _lonController;
  late TextEditingController _reportedAtController;

  // Variables para opciones de rango
  String? _folioOp = 'exact'; // exact, gte, lte, range
  String? _latOp = 'exact';
  String? _lonOp = 'exact';
  String? _reportedAtOp = 'exact';

  static const List<String> statuses = [
    'Recibido',
    'En revisión',
    'En atención',
    'Resuelto',
    'Cerrado'
  ];
  static const List<String> reportTypes = [
    'baja',
    'media',
    'alta',
    'extrema',
  ];
  static const List<String> orderingFields = [
    'reported_at',
    'folio',
    'status',
    'estimated_time_interval'
  ];

  @override
  void initState() {
    super.initState();
    _filters = Map.from(widget.initialFilters);

    _idController =
        TextEditingController(text: _filters['id__icontains'] ?? '');
    _folioController = TextEditingController(text: _filters['folio'] ?? '');
    _latController = TextEditingController(text: _filters['latitude'] ?? '');
    _lonController = TextEditingController(text: _filters['longitude'] ?? '');
    _reportedAtController =
        TextEditingController(text: _filters['reported_at'] ?? '');
  }

  @override
  void dispose() {
    _idController.dispose();
    _folioController.dispose();
    _latController.dispose();
    _lonController.dispose();
    _reportedAtController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    // _filters.clear();

    if (_idController.text.isNotEmpty) {
      _filters['id__icontains'] = _idController.text;
    }
    if (_filters['status'] != null) {
      _filters['status'] = _filters['status'];
    }
    if (_filters['report_type'] != null) {
      _filters['report_type'] = _filters['report_type'];
    }
    if (_folioController.text.isNotEmpty) {
      _filters['folio__$_folioOp'] = _folioController.text;
    }
    if (_latController.text.isNotEmpty) {
      _filters['latitude__$_latOp'] = _latController.text;
    }
    if (_lonController.text.isNotEmpty) {
      _filters['longitude__$_lonOp'] = _lonController.text;
    }
    if (_reportedAtController.text.isNotEmpty) {
      _filters['reported_at__$_reportedAtOp'] = _reportedAtController.text;
    }
    if (_filters['assigned_operator_id'] != null) {
      _filters['assigned_operator_id'] = _filters['assigned_operator_id'];
    }
    if (_ordering != null) {
      _filters['ordering'] = _ordering;
    }

    Navigator.of(context).pop({..._filters});
  }

  void _clearFilters() {
    setState(() {
      _filters.clear();
      _idController.clear();
      _folioController.clear();
      _latController.clear();
      _lonController.clear();
      _reportedAtController.clear();
      _ordering = null;
      _folioOp = 'exact';
      _latOp = 'exact';
      _lonOp = 'exact';
      _reportedAtOp = 'exact';
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filtros avanzados'),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status
              const Text('Estado',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              DropdownButtonFormField<String>(
                initialValue: _filters['status'],
                items: statuses
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => {setState(() => _filters['status'] = v)},
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                ),
              ),
              const SizedBox(height: 16),

              // Report Type
              const Text('Tipo de Fuga',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              DropdownButtonFormField<String>(
                initialValue: _filters['report_type'],
                items: reportTypes
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _filters['report_type'] = v),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                ),
              ),
              const SizedBox(height: 16),

              // ID (icontains)
              const Text('ID (búsqueda)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              TextField(
                controller: _idController,
                decoration: InputDecoration(
                  hintText: 'Buscar en ID...',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                ),
              ),
              const SizedBox(height: 16),

              // Folio con opciones
              const Text('Folio',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _folioController,
                      decoration: InputDecoration(
                        hintText: 'Valor...',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _folioOp,
                      items: ['exact', 'gte', 'lte', 'range']
                          .map((op) =>
                              DropdownMenuItem(value: op, child: Text(op)))
                          .toList(),
                      onChanged: (v) => setState(() => _folioOp = v),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Latitude
              const Text('Latitud',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _latController,
                      decoration: InputDecoration(
                        hintText: 'Valor...',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _latOp,
                      items: ['exact', 'gte', 'lte', 'range']
                          .map((op) =>
                              DropdownMenuItem(value: op, child: Text(op)))
                          .toList(),
                      onChanged: (v) => setState(() => _latOp = v),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Longitude
              const Text('Longitud',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _lonController,
                      decoration: InputDecoration(
                        hintText: 'Valor...',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _lonOp,
                      items: ['exact', 'gte', 'lte', 'range']
                          .map((op) =>
                              DropdownMenuItem(value: op, child: Text(op)))
                          .toList(),
                      onChanged: (v) => setState(() => _lonOp = v),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Reported At
              const Text('Fecha Reportada',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _reportedAtController,
                      decoration: InputDecoration(
                        hintText: 'YYYY-MM-DD',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _reportedAtOp,
                      items: ['exact', 'gte', 'lte', 'range', 'month__gte']
                          .map((op) =>
                              DropdownMenuItem(value: op, child: Text(op)))
                          .toList(),
                      onChanged: (v) => setState(() => _reportedAtOp = v),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Ordering
              const Text('Ordenar por',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              DropdownButtonFormField<String>(
                initialValue: _filters['ordering'],
                items: orderingFields
                    .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                    .toList(),
                onChanged: (v) => (_ordering = v),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        Wrap(
          children: [
            TextButton(
              onPressed: _clearFilters,
              child: const Text('Limpiar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
              style: TextButton.styleFrom(
                alignment:
                    Alignment.centerRight, // Aligns content to the right side
              ),
            ),
            const SizedBox(
              height: 6,
              width: double.infinity,
            ),
            ElevatedButton(
              onPressed: _applyFilters,
              child: const Text('Aplicar'),
            ),
          ],
        )
      ],
    );
  }
}
