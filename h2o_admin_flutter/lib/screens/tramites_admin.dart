import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/tramite_model.dart';
import '../providers/tramite_provider.dart';
import '../core/routes.dart';
import 'components/reusable_crud_table.dart';
import 'components/statistic_card.dart';

class TramitesAdminPage extends StatefulWidget {
  const TramitesAdminPage({super.key});

  @override
  State<TramitesAdminPage> createState() => _TramitesAdminPageState();
}

class _TramitesAdminPageState extends State<TramitesAdminPage> {
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 1;
  final int _itemsPerPage = 100;
  bool _loading = false;
  Map<String, dynamic> _filters = {};

  @override
  void initState() {
    super.initState();
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
    context
        .read<TramiteProvider>()
        .getAll(
          search: _searchController.text,
          page: _currentPage,
          filters: _filters,
        )
        .then((_) {
      if (mounted) setState(() => _loading = false);
    });
  }

  Future<void> _openFiltersDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => TramiteFilterDialog(
        initialFilters: _filters,
      ),
    );
    if (result != null) {
      setState(() {
        _filters = result;
        _currentPage = 1;
      });
      _loadData();
    }
  }

  Future<void> _confirmDelete(TramiteModel tramite) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Trámite'),
        content: Text(
            '¿Está seguro de que desea eliminar el trámite con Folio "${tramite.folio}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          SizedBox(
            width: 120,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Eliminar'),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _loading = true);
      final success =
          await context.read<TramiteProvider>().deleteTramite(tramite.id);
      setState(() => _loading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'Trámite eliminado con éxito'
                : 'Error al eliminar el trámite'),
          ),
        );
        if (success) _loadData();
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'creado':
        return Colors.orange;
      case 'en proceso':
      case 'en tramite':
        return Colors.blue;
      case 'aprobado':
      case 'completado':
        return Colors.green;
      case 'rechazado':
      case 'cancelado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tramiteProvider = context.watch<TramiteProvider>();
    final tramites = tramiteProvider.tramites;
    final totalCount = tramiteProvider.tramitesCount;
    final totalPages = (totalCount / _itemsPerPage).ceil();

    // Stats calculations
    int createdCount =
        tramites.where((t) => t.status.toLowerCase() == 'creado').length;
    int inProgressCount = tramites
        .where((t) =>
            t.status.toLowerCase() == 'en proceso' ||
            t.status.toLowerCase() == 'en revisión')
        .length;
    int approvedCount = tramites
        .where((t) =>
            t.status.toLowerCase() == 'aprobado' ||
            t.status.toLowerCase() == 'completado')
        .length;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Breadcrumbs and Title
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
                  'Trámites Ciudadanos',
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            const Text(
              'Administración de Trámites',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Supervisión y gestión de trámites y solicitudes presentadas por la ciudadanía de Chimalhucán.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),

            // Statistics Section
            Row(
              children: [
                Expanded(
                  child: StatisticCard(
                    label: 'TOTAL TRÁMITES',
                    value: totalCount.toString(),
                    icon: Icons.assignment,
                    color: Colors.blue[700]!,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StatisticCard(
                    label: 'CREADOS',
                    value: createdCount.toString(),
                    icon: Icons.add_circle_outline,
                    color: Colors.orange[700]!,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StatisticCard(
                    label: 'EN PROCESO',
                    value: inProgressCount.toString(),
                    icon: Icons.hourglass_empty,
                    color: Colors.blue[400]!,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StatisticCard(
                    label: 'APROBADOS',
                    value: approvedCount.toString(),
                    icon: Icons.check_circle_outline,
                    color: Colors.green[600]!,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Search and Filter controls
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Buscar por servicio, folio, notas...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                    onChanged: (value) {
                      setState(() => _currentPage = 1);
                      _loadData();
                    },
                    onSubmitted: (value) {
                      setState(() => _currentPage = 1);
                      _loadData();
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
                    onPressed: _openFiltersDialog,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            if (_loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else
              ReusableCrudTable<TramiteModel>(
                headers: const [
                  'Folio',
                  'Servicio',
                  'Fecha de Creación',
                  'Estado',
                  'Usuario ID',
                  'Acciones'
                ],
                flexes: const [1, 2, 2, 2, 2, 2],
                items: tramites,
                currentPage: _currentPage,
                totalPages: totalPages,
                totalCount: totalCount,
                itemsPerPage: _itemsPerPage,
                emptyMessage: 'No se encontraron trámites registrados.',
                onPageChanged: (page) {
                  setState(() => _currentPage = page);
                  _loadData();
                },
                rowBuilder: (context, tramite, index) {
                  final formattedDate =
                      '${tramite.createdAt.day}/${tramite.createdAt.month}/${tramite.createdAt.year}';
                  return Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            '#${tramite.folio}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            tramite.serviceName ?? 'N/A',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(formattedDate),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(tramite.status)
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              tramite.status,
                              style: TextStyle(
                                color: _getStatusColor(tramite.status),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            tramite.user,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Row(
                          children: [
                            IconButton(
                              tooltip: 'Ver Detalle',
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.tramiteDetail,
                                  arguments: TramiteDetailArguments(
                                    tramiteId: tramite.id,
                                    isEditMode: false,
                                  ),
                                ).then((_) => _loadData());
                              },
                              icon: const Icon(Icons.visibility,
                                  color: Colors.blue),
                              iconSize: 20,
                              splashRadius: 20,
                            ),
                            IconButton(
                              tooltip: 'Editar',
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.tramiteDetail,
                                  arguments: TramiteDetailArguments(
                                    tramiteId: tramite.id,
                                    isEditMode: true,
                                  ),
                                ).then((_) => _loadData());
                              },
                              icon: const Icon(Icons.edit, color: Colors.grey),
                              iconSize: 20,
                              splashRadius: 20,
                            ),
                            IconButton(
                              tooltip: 'Eliminar',
                              onPressed: () => _confirmDelete(tramite),
                              icon: const Icon(Icons.delete, color: Colors.red),
                              iconSize: 20,
                              splashRadius: 20,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class TramiteFilterDialog extends StatefulWidget {
  final Map<String, dynamic> initialFilters;

  const TramiteFilterDialog({required this.initialFilters, super.key});

  @override
  State<TramiteFilterDialog> createState() => _TramiteFilterDialogState();
}

class _TramiteFilterDialogState extends State<TramiteFilterDialog> {
  late Map<String, dynamic> _filters;

  // Controllers
  late TextEditingController _curpController;
  late TextEditingController _serviceController;
  late TextEditingController _folioController;
  late TextEditingController _createdAtController;

  // Operators
  String _folioOp = 'exact';
  String _createdAtOp = 'exact';
  String? _status;

  @override
  void initState() {
    super.initState();
    _filters = Map.from(widget.initialFilters);

    _curpController =
        TextEditingController(text: _filters['user__curp__icontains'] ?? '');
    _serviceController = TextEditingController(text: _filters['service'] ?? '');

    // Resolve folio value and op
    String folioVal = '';
    if (_filters.containsKey('folio')) {
      folioVal = _filters['folio'].toString();
      _folioOp = 'exact';
    } else if (_filters.containsKey('folio__exact')) {
      folioVal = _filters['folio__exact'].toString();
      _folioOp = 'exact';
    } else if (_filters.containsKey('folio__gte')) {
      folioVal = _filters['folio__gte'].toString();
      _folioOp = 'gte';
    } else if (_filters.containsKey('folio__lte')) {
      folioVal = _filters['folio__lte'].toString();
      _folioOp = 'lte';
    } else if (_filters.containsKey('folio__range')) {
      folioVal = _filters['folio__range'].toString();
      _folioOp = 'range';
    }
    _folioController = TextEditingController(text: folioVal);

    // Resolve created_at value and op
    String createdAtVal = '';
    if (_filters.containsKey('created_at')) {
      createdAtVal = _filters['created_at'].toString();
      _createdAtOp = 'exact';
    } else if (_filters.containsKey('created_at__exact')) {
      createdAtVal = _filters['created_at__exact'].toString();
      _createdAtOp = 'exact';
    } else if (_filters.containsKey('created_at__gte')) {
      createdAtVal = _filters['created_at__gte'].toString();
      _createdAtOp = 'gte';
    } else if (_filters.containsKey('created_at__lte')) {
      createdAtVal = _filters['created_at__lte'].toString();
      _createdAtOp = 'lte';
    } else if (_filters.containsKey('created_at__range')) {
      createdAtVal = _filters['created_at__range'].toString();
      _createdAtOp = 'range';
    }
    _createdAtController = TextEditingController(text: createdAtVal);

    _status = _filters['status'];
  }

  @override
  void dispose() {
    _curpController.dispose();
    _serviceController.dispose();
    _folioController.dispose();
    _createdAtController.dispose();
    super.dispose();
  }

  void _apply() {
    _filters.clear();

    if (_curpController.text.isNotEmpty) {
      _filters['user__curp__icontains'] = _curpController.text;
    }
    if (_serviceController.text.isNotEmpty) {
      _filters['service'] = _serviceController.text;
    }
    if (_folioController.text.isNotEmpty) {
      final key = _folioOp == 'exact' ? 'folio' : 'folio__$_folioOp';
      _filters[key] = _folioController.text;
    }
    if (_createdAtController.text.isNotEmpty) {
      final key =
          _createdAtOp == 'exact' ? 'created_at' : 'created_at__$_createdAtOp';
      _filters[key] = _createdAtController.text;
    }
    if (_status != null) {
      _filters['status'] = _status;
    }

    Navigator.of(context).pop({..._filters});
  }

  void _clear() {
    setState(() {
      _filters.clear();
      _curpController.clear();
      _serviceController.clear();
      _folioController.clear();
      _createdAtController.clear();
      _folioOp = 'exact';
      _createdAtOp = 'exact';
      _status = null;
    });
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      final formatted =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      setState(() {
        if (_createdAtOp == 'range') {
          if (_createdAtController.text.isEmpty) {
            _createdAtController.text = formatted;
          } else {
            _createdAtController.text =
                "${_createdAtController.text},$formatted";
          }
        } else {
          _createdAtController.text = formatted;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filtros Avanzados (Trámites)'),
      content: SizedBox(
        width: 450,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Estado
              const Text('Estado del Trámite',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              DropdownButtonFormField<String>(
                value: _status,
                items: const [
                  DropdownMenuItem(value: 'Creado', child: Text('Creado')),
                  DropdownMenuItem(
                      value: 'En tramite', child: Text('En tramite')),
                  DropdownMenuItem(
                      value: 'Completado', child: Text('Completado')),
                ],
                onChanged: (v) => setState(() => _status = v),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                ),
              ),
              const SizedBox(height: 12),

              // CURP del Usuario
              const Text('CURP de Usuario',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              TextField(
                controller: _curpController,
                decoration: InputDecoration(
                  hintText: 'Buscar por CURP del usuario...',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                ),
              ),
              const SizedBox(height: 12),

              // ID del Servicio
              const Text('ID de Servicio (Exacto)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              TextField(
                controller: _serviceController,
                decoration: InputDecoration(
                  hintText: 'UUID del servicio...',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                ),
              ),
              const SizedBox(height: 12),

              // Folio (exact, gte, lte, range)
              const Text('Folio',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _folioController,
                      decoration: InputDecoration(
                        hintText:
                            _folioOp == 'range' ? 'Ej. 10,20' : 'Valor...',
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
                      value: _folioOp,
                      items: const [
                        DropdownMenuItem(value: 'exact', child: Text('Exacto')),
                        DropdownMenuItem(value: 'gte', child: Text('Min (>=)')),
                        DropdownMenuItem(value: 'lte', child: Text('Max (<=)')),
                        DropdownMenuItem(
                            value: 'range', child: Text('Rango (A,B)')),
                      ],
                      onChanged: (v) => setState(() => _folioOp = v ?? 'exact'),
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
              const SizedBox(height: 12),

              // Fecha de Creación
              const Text('Fecha de Creación',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _createdAtController,
                      decoration: InputDecoration(
                        hintText: _createdAtOp == 'range'
                            ? 'YYYY-MM-DD,YYYY-MM-DD'
                            : 'YYYY-MM-DD',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today, size: 16),
                          onPressed: _selectDate,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _createdAtOp,
                      items: const [
                        DropdownMenuItem(value: 'exact', child: Text('Exacta')),
                        DropdownMenuItem(
                            value: 'gte', child: Text('Desde (>=)')),
                        DropdownMenuItem(
                            value: 'lte', child: Text('Hasta (<=)')),
                        DropdownMenuItem(
                            value: 'range', child: Text('Rango (A,B)')),
                      ],
                      onChanged: (v) =>
                          setState(() => _createdAtOp = v ?? 'exact'),
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
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: _clear, child: const Text('Limpiar')),
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar')),
        ElevatedButton(onPressed: _apply, child: const Text('Aplicar')),
      ],
    );
  }
}
