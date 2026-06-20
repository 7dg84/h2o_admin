import 'package:flutter/material.dart';
import 'package:h2o_admin_flutter/providers/user_provider.dart';
import 'package:provider/provider.dart';
import '../models/report_model.dart';
import '../models/user_model.dart';
import '../providers/report_provider.dart';
import 'report_detail.dart';

class ReportsAdminPage extends StatefulWidget {
  const ReportsAdminPage({super.key});

  @override
  State<ReportsAdminPage> createState() => _ReportsAdminPageState();
}

class _ReportsAdminPageState extends State<ReportsAdminPage> {
  late TextEditingController _searchController;
  int _currentPage = 1;
  int _itemsPerPage = 100;
  bool _loading = false;

  // Filter state
  Map<String, dynamic> _filters = {};

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadData() {
    setState(() => _loading = true);
    context.read<ReportProvider>().fetchAllReports();
    context.read<ReportProvider>().fetchPendingReports();
    context.read<ReportProvider>().fetchAttentionReports();
    context.read<ReportProvider>().fetchSolvedReports();
    setState(() => _loading = false);
  }

  Future<void> _openFiltersDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => FilterDialog(
        initialFilters: _filters,
      ),
    );
    if (result != null) {
      setState(() {
        _filters = result;
        _currentPage = 1;
      });
      // TODO: Aplicar filtros llamando a fetchAllReports con los parámetros
      print(_filters);
      context.read<ReportProvider>().fetchAllReports(filters: _filters);
    }
  }

  Future<void> _openAssignDialog(String reportId) async {
    final assigned = await showDialog<bool>(
      context: context,
      builder: (ctx) => AssignDialog(reportId: reportId),
    );
    if (assigned == true) _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final reportProvider = context.watch<ReportProvider>();
    final reports = reportProvider.allReports;

    // TODO: Implementar filtrado por búsqueda
    final filteredReports = reports;

    final totalPages = (reportProvider.allReportsCount / _itemsPerPage).ceil();
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex =
        (startIndex + _itemsPerPage).clamp(0, reportProvider.allReportsCount);
    final paginatedReports = filteredReports.sublist(
      startIndex,
      endIndex,
    );

    // TODO: Obtener datos reales de estadísticas
    final pendingCount = reportProvider.pendingReportscount;
    final inProgressCount = reportProvider.attentionReportsCount;
    final resolvedCount = reportProvider.solvedReportsCount;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Breadcrumb
            Row(
              children: [
                const Text(
                  'Gestión de Red',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(width: 8),
                const Text('/', style: TextStyle(color: Colors.grey)),
                const SizedBox(width: 8),
                Text(
                  'Fugas Reportadas',
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Title and Description
            const Text(
              'Control de Fugas',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Supervisión en tiempo real de incidencias en la red hidráulica de Chimalhucán.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),

            // Statistics Cards
            Row(
              children: [
                _StatisticCard(
                  label: 'PENDIENTES',
                  value: pendingCount.toString(),
                  icon: Icons.warning_amber,
                  color: Colors.orange,
                  trend: 'hoy',
                ),
                const SizedBox(width: 16),
                _StatisticCard(
                  label: 'EN ATENCIÓN',
                  value: inProgressCount.toString(),
                  icon: Icons.build,
                  color: Colors.blue,
                  trend: 'activos',
                ),
                const SizedBox(width: 16),
                _StatisticCard(
                  label: 'RESUELTAS (MES)',
                  value: resolvedCount.toString(),
                  icon: Icons.check_circle,
                  color: Colors.green,
                  trend: 'Total',
                ),
                const SizedBox(width: 16),
                _StatisticCard(
                  label: 'TIEMPO PROMEDIO',
                  value: reportProvider.getAvrageTime().toStringAsFixed(1),
                  icon: Icons.schedule,
                  color: Colors.purple,
                  trend: '(Reportes actuales)',
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Filter and Export Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText:
                          'Buscar por folio, descripción, ubicación o curp...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                    onChanged: (value) {
                      // setState(() => _currentPage = 1);
                      reportProvider.fetchAllReports(search: value);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                // Filtros
                SizedBox(
                  width: 120,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.filter_list),
                    label: const Text('Filtrar'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _openFiltersDialog,
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 130,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.download),
                    label: const Text('Exportar'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      // TODO: Implementar exportación de datos
                    },
                  ),
                )
              ],
            ),
            const SizedBox(height: 16),

            if (_loading) const LinearProgressIndicator(),
            const SizedBox(height: 16),

            // Reports Table
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  // Table Header
                  Container(
                    color: Colors.blue[50],
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        _buildTableHeaderCell('Folio', flex: 1),
                        _buildTableHeaderCell('Fecha', flex: 1),
                        _buildTableHeaderCell('Ubicación', flex: 2),
                        _buildTableHeaderCell('Tipo de Fuga', flex: 1),
                        _buildTableHeaderCell('Estado', flex: 1),
                        _buildTableHeaderCell('Acciones', flex: 1),
                      ],
                    ),
                  ),
                  // Table Body
                  if (paginatedReports.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Text(
                        'No hay reportes',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    )
                  else
                    ...List.generate(
                      paginatedReports.length,
                      (index) {
                        final report = paginatedReports[index];
                        final isLastItem = index == paginatedReports.length - 1;
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                children: [
                                  _buildTableCell(
                                    report.folio,
                                    flex: 1,
                                    isBold: true,
                                    color: Colors.blue[700],
                                  ),
                                  _buildTableCell(
                                    '${report.reportedAt.day ?? ''}/${report.reportedAt.month ?? ''}/${report.reportedAt.year ?? ''}',
                                    flex: 1,
                                  ),
                                  _buildTableCell(
                                    report.locationText ?? '',
                                    flex: 2,
                                  ),
                                  _buildTableCell(
                                    report.reportType ?? '',
                                    flex: 1,
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: _buildStatusBadge(report),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Wrap(
                                      children: [
                                        IconButton(
                                          tooltip: 'Asignar operador',
                                          onPressed: () =>
                                              _openAssignDialog(report.id),
                                          icon: const Icon(Icons.person_add),
                                          iconSize: 20,
                                          splashRadius: 20,
                                        ),
                                        IconButton(
                                          tooltip: 'Ver detalle',
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => ReportDetailScreen(
                                                  reportId: report.id,
                                                  isEditMode: false,
                                                ),
                                              ),
                                            ).then((value) {
                                              if (value == true) {
                                                _loadData();
                                              }
                                            });
                                          },
                                          icon: const Icon(Icons.visibility),
                                          iconSize: 20,
                                          splashRadius: 20,
                                        ),
                                        IconButton(
                                          tooltip: 'Editar',
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => ReportDetailScreen(
                                                  reportId: report.id,
                                                  isEditMode: true,
                                                ),
                                              ),
                                            ).then((value) {
                                              if (value == true) {
                                                _loadData();
                                              }
                                            });
                                          },
                                          icon: const Icon(Icons.edit),
                                          iconSize: 20,
                                          splashRadius: 20,
                                        ),
                                        IconButton(
                                          tooltip: 'Eliminar',
                                          onPressed: () async {
                                            final confirm = await showDialog<bool>(
                                              context: context,
                                              builder: (ctx) => AlertDialog(
                                                title: const Text('Eliminar reporte'),
                                                content: Text(
                                                    '¿Estás seguro de que deseas eliminar el reporte #${report.folio}?'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(ctx).pop(false),
                                                    child: const Text('Cancelar'),
                                                  ),
                                                  ElevatedButton(
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: Colors.red,
                                                      foregroundColor: Colors.white,
                                                    ),
                                                    onPressed: () =>
                                                        Navigator.of(ctx).pop(true),
                                                    child: const Text('Eliminar'),
                                                  ),
                                                ],
                                              ),
                                            );
                                            if (confirm == true) {
                                              final success = await context
                                                  .read<ReportProvider>()
                                                  .deleteReport(report.id);
                                              if (success) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                        'Reporte eliminado con éxito'),
                                                  ),
                                                );
                                                _loadData();
                                              } else {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                        'Error al eliminar el reporte'),
                                                  ),
                                                );
                                              }
                                            }
                                          },
                                          icon: const Icon(Icons.delete,
                                              color: Colors.red),
                                          iconSize: 20,
                                          splashRadius: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (!isLastItem)
                              Divider(
                                height: 1,
                                color: Colors.grey[300],
                              ),
                          ],
                        );
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Pagination
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mostrando 1-${endIndex} de ${filteredReports.length} reportes',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: _currentPage > 1
                          ? () => setState(() => _currentPage--)
                          : null,
                    ),
                    ..._buildPageButtons(totalPages),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: _currentPage < totalPages
                          ? () => setState(() => _currentPage++)
                          : null,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeaderCell(String text, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildTableCell(
    String text, {
    required int flex,
    bool isBold = false,
    Color? color,
  }) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          text,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(ReportModel report) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: report.statusColor.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        report.statusText,
        style: TextStyle(
          color: report.statusColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  List<Widget> _buildPageButtons(int totalPages) {
    final List<Widget> buttons = [];
    final int maxButtons = 5;
    int startPage = 1;
    int endPage = totalPages;

    if (totalPages > maxButtons) {
      if (_currentPage <= (maxButtons ~/ 2)) {
        endPage = maxButtons;
      } else if (_currentPage > totalPages - (maxButtons ~/ 2)) {
        startPage = totalPages - maxButtons + 1;
      } else {
        startPage = _currentPage - (maxButtons ~/ 2);
        endPage = _currentPage + (maxButtons ~/ 2);
      }
    }

    for (int i = startPage; i <= endPage; i++) {
      buttons.add(
        _buildPageButton(i),
      );
    }

    return buttons;
  }

  Widget _buildPageButton(int pageNumber) {
    final isSelected = _currentPage == pageNumber;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: SizedBox(
        width: 120,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected ? Colors.blue[700] : Colors.white,
            foregroundColor: isSelected ? Colors.white : Colors.grey[700],
            elevation: isSelected ? 2 : 0,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
              side: BorderSide(
                color: isSelected ? Colors.blue[700]! : Colors.grey[300]!,
              ),
            ),
          ),
          onPressed: () => setState(() => _currentPage = pageNumber),
          child: Text(pageNumber.toString()),
        ),
      ),
    );
  }
}

class _StatisticCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String trend;

  const _StatisticCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.trend,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              trend,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AssignDialog extends StatefulWidget {
  final String reportId;

  const AssignDialog({
    required this.reportId,
    super.key,
  });

  @override
  State<AssignDialog> createState() => _AssignDialogState();
}

class _AssignDialogState extends State<AssignDialog> {
  final TextEditingController _search = TextEditingController();
  List<UserModel> _operators = [];
  String? _selectedOperatorId;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchOperators();
    });
  }

  Future<void> _fetchOperators([String? q]) async {
    setState(() => _loading = true);
    try {
      final list = await context.read<UserProvider>().getOperators(q);
      setState(() => _operators = list);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error cargando operadores: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _assign() async {
    if (_selectedOperatorId == null) return;
    print(_selectedOperatorId);
    print(widget.reportId);
    setState(() => _loading = true);
    try {
      final reportProvider = context.read<ReportProvider>();
      await reportProvider.assignReport(widget.reportId, _selectedOperatorId!);
      Navigator.of(context).pop(true);
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error asignando: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reportProvider = context.watch<ReportProvider>();

    return AlertDialog(
      title: const Text('Asignar operador'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _search,
              decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Buscar operador...'),
              onSubmitted: (v) => _fetchOperators(v),
            ),
            const SizedBox(height: 8),
            if (_loading) const LinearProgressIndicator(),
            Flexible(
              child: _operators.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('No se encontraron operadores'))
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: _operators.length,
                      itemBuilder: (context, index) {
                        final u = _operators[index];
                        return RadioListTile<String>(
                          title: Text(u.name ?? u.email),
                          subtitle: Text(u.email),
                          value: u.id,
                          groupValue: _selectedOperatorId,
                          onChanged: (v) =>
                              setState(() => _selectedOperatorId = v),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar')),
        SizedBox(
          width: 120,
          child:
              ElevatedButton(onPressed: _assign, child: const Text('Asignar')),
        ),
      ],
    );
  }
}

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
            SizedBox(
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
