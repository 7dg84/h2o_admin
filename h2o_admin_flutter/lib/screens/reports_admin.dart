import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/report_service.dart';
import '../services/user_service.dart';
import '../models/report_model.dart';
import '../models/user_model.dart';
import '../providers/report_provider.dart';

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
    setState(() => _loading = false);
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

    final totalPages = (filteredReports.length / _itemsPerPage).ceil();
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex =
        (startIndex + _itemsPerPage).clamp(0, filteredReports.length);
    final paginatedReports = filteredReports.sublist(
      startIndex,
      endIndex,
    );

    // TODO: Obtener datos reales de estadísticas
    final pendingCount = reports.where((r) => r.status == 'pending').length;
    final inProgressCount =
        reports.where((r) => r.status == 'in_progress').length;
    final resolvedCount = reports.where((r) => r.status == 'resolved').length;

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
                  trend: '+2 hoy',
                ),
                const SizedBox(width: 16),
                _StatisticCard(
                  label: 'EN ATENCIÓN',
                  value: inProgressCount.toString(),
                  icon: Icons.build,
                  color: Colors.blue,
                  trend: '3 activos',
                ),
                const SizedBox(width: 16),
                _StatisticCard(
                  label: 'RESUELTAS (MES)',
                  value: resolvedCount.toString(),
                  icon: Icons.check_circle,
                  color: Colors.green,
                  trend: '94% efec.',
                ),
                const SizedBox(width: 16),
                _StatisticCard(
                  label: 'TIEMPO PROMEDIO',
                  value: '4.5h',
                  icon: Icons.schedule,
                  color: Colors.purple,
                  trend: '-15% vs ayer',
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
                      hintText: 'Buscar por folio o ubicación...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                    onChanged: (value) {
                      // TODO: Implementar búsqueda en tiempo real
                      setState(() => _currentPage = 1);
                    },
                  ),
                ),
                const SizedBox(width: 16),
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
                    onPressed: () {
                      // TODO: Implementar diálogo de filtros avanzados
                    },
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
                                    child: _buildStatusBadge(report.status
                                        .toString()
                                        .split('.')
                                        .last),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
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
                                            // TODO: Implementar vista de detalle
                                          },
                                          icon: const Icon(Icons.visibility),
                                          iconSize: 20,
                                          splashRadius: 20,
                                        ),
                                        IconButton(
                                          tooltip: 'Editar',
                                          onPressed: () {
                                            // TODO: Implementar edición
                                          },
                                          icon: const Icon(Icons.edit),
                                          iconSize: 20,
                                          splashRadius: 20,
                                        ),
                                        IconButton(
                                          tooltip: 'Eliminar',
                                          onPressed: () {
                                            // TODO: Implementar eliminación
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

  Widget _buildStatusBadge(String status) {
    late Color bgColor;
    late Color textColor;
    late String label;

    switch (status.toLowerCase()) {
      case 'resolved':
      case 'resuelto':
        bgColor = Colors.red[50]!;
        textColor = Colors.red;
        label = 'Resuelto';
        break;
      case 'in_progress':
      case 'en_revision':
        bgColor = Colors.blue[50]!;
        textColor = Colors.blue;
        label = 'En revisión';
        break;
      case 'pending':
      case 'pendiente':
      default:
        bgColor = Colors.amber[50]!;
        textColor = Colors.amber[800]!;
        label = 'Pendiente';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
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
    _fetchOperators();
  }

  Future<void> _fetchOperators([String? q]) async {
    setState(() => _loading = true);
    try {
      // final list = await widget.userService.getOperators(query: q);
      // for now return dummy data
      final list = [
        UserModel(
            id: '1',
            name: 'Operador 1',
            email: 'op1@mail.com',
            role: UserRole.operator),
        UserModel(
            id: '2',
            name: 'Operador 2',
            email: 'op2@mail.com',
            role: UserRole.operator),
      ];
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
    setState(() => _loading = true);
    try {
      final reportProvider = context.watch<ReportProvider>();
      await reportProvider.assignReport(widget.reportId, _selectedOperatorId!);
      Navigator.of(context).pop(true);
    } catch (e) {
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
