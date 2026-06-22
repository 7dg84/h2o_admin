import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Models
import '../models/document_type_model.dart';
import '../models/service_model.dart';
import '../models/service_requirement_model.dart';
import '../models/payment_model.dart';

// Providers
import '../providers/document_type_provider.dart';
import '../providers/service_provider.dart';
import '../providers/service_requirement_provider.dart';
import '../providers/payment_provider.dart';

// Components
import 'components/reusable_crud_table.dart';

class AjustesAdminPage extends StatefulWidget {
  const AjustesAdminPage({super.key});

  @override
  State<AjustesAdminPage> createState() => _AjustesAdminPageState();
}

class _AjustesAdminPageState extends State<AjustesAdminPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _activeTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (mounted) {
        setState(() {
          _activeTab = _tabController.index;
        });
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Pre-load dropdown data globally
      context.read<ServiceProvider>().getAll(page: 1, filters: {'limit': 100});
      context
          .read<DocumentTypeProvider>()
          .getAll(page: 1, filters: {'limit': 100});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildActiveTab() {
    switch (_activeTab) {
      case 0:
        return const _DocumentTypesTab();
      case 1:
        return const _ServicesTab();
      case 2:
        return const _ServiceRequirementsTab();
      case 3:
        return const _PaymentsTab();
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  'Configuración',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(width: 8),
                const Text('/', style: TextStyle(color: Colors.grey)),
                const SizedBox(width: 8),
                Text(
                  'Ajustes del Sistema',
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
              'Ajustes y Parametrización',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Administra los tipos de documentos, los servicios ciudadanos disponibles, los requisitos obligatorios y las tarifas de pago del sistema.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),

            // Custom TabBar with beautiful styling
            Card(
              margin: EdgeInsets.zero,
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorColor: Colors.blue[700],
                labelColor: Colors.blue[700],
                unselectedLabelColor: Colors.grey[600],
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                tabs: const [
                  Tab(
                      icon: Icon(Icons.description),
                      text: 'Tipos de Documento'),
                  Tab(icon: Icon(Icons.room_service), text: 'Servicios'),
                  Tab(icon: Icon(Icons.rule), text: 'Requisitos de Servicio'),
                  Tab(icon: Icon(Icons.payment), text: 'Pagos'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Active Tab View Content
            _buildActiveTab(),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// TAB 1: TIPOS DE DOCUMENTO
// ==========================================
class _DocumentTypesTab extends StatefulWidget {
  const _DocumentTypesTab();

  @override
  State<_DocumentTypesTab> createState() => _DocumentTypesTabState();
}

class _DocumentTypesTabState extends State<_DocumentTypesTab> {
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 1;
  final int _itemsPerPage = 10;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadData() {
    setState(() => _loading = true);
    context
        .read<DocumentTypeProvider>()
        .getAll(
          search: _searchController.text,
          page: _currentPage,
        )
        .then((_) {
      if (mounted) setState(() => _loading = false);
    });
  }

  Future<void> _openFormDialog([DocumentTypeModel? docType]) async {
    final isEdit = docType != null;
    final nameController = TextEditingController(text: docType?.name ?? '');
    final descController =
        TextEditingController(text: docType?.description ?? '');
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
            isEdit ? 'Editar Tipo de Documento' : 'Nuevo Tipo de Documento'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (result == true && formKey.currentState!.validate()) {
      setState(() => _loading = true);
      final data = {
        'name': nameController.text,
        'description': descController.text,
      };

      bool success;
      if (isEdit) {
        success = await context
            .read<DocumentTypeProvider>()
            .updateDocumentType(docType!.id, data);
      } else {
        success =
            await context.read<DocumentTypeProvider>().createDocumentType(data);
      }

      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(success ? 'Guardado con éxito' : 'Error al guardar'),
        ));
        if (success) _loadData();
      }
    }
  }

  Future<void> _confirmDelete(DocumentTypeModel docType) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Tipo de Documento'),
        content: Text('¿Está seguro de eliminar "${docType.name}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _loading = true);
      final success = await context
          .read<DocumentTypeProvider>()
          .deleteDocumentType(docType.id);
      setState(() => _loading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(success ? 'Eliminado con éxito' : 'Error al eliminar'),
        ));
        if (success) {
          _loadData();
          // Update global list
          context
              .read<DocumentTypeProvider>()
              .getAll(page: 1, filters: {'limit': 100});
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<DocumentTypeProvider>();
    final items = prov.documentTypes;
    final totalCount = prov.documentTypesCount;
    final totalPages = (totalCount / _itemsPerPage).ceil();

    return Column(
      children: [
        // Controls
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Buscar por nombre o descripción...',
                ),
                onChanged: (_) {
                  setState(() => _currentPage = 1);
                  _loadData();
                },
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Nuevo'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(120, 50)),
              onPressed: () => _openFormDialog(),
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (_loading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          )
        else
          ReusableCrudTable<DocumentTypeModel>(
            headers: const ['ID', 'Nombre', 'Descripción', 'Acciones'],
            flexes: const [1, 2, 4, 1],
            items: items,
            currentPage: _currentPage,
            totalPages: totalPages,
            totalCount: totalCount,
            itemsPerPage: _itemsPerPage,
            emptyMessage: 'No hay tipos de documentos configurados.',
            onPageChanged: (p) {
              setState(() => _currentPage = p);
              _loadData();
            },
            rowBuilder: (context, doc, index) => Row(
              children: [
                Expanded(
                    flex: 1,
                    child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(doc.id.substring(0, 8),
                            style: const TextStyle(fontFamily: 'monospace')))),
                Expanded(
                    flex: 2,
                    child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(doc.name,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)))),
                Expanded(
                    flex: 4,
                    child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(doc.description))),
                Expanded(
                  flex: 1,
                  child: Wrap(
                    children: [
                      IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _openFormDialog(doc)),
                      IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDelete(doc)),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ==========================================
// TAB 2: SERVICIOS
// ==========================================
class _ServicesTab extends StatefulWidget {
  const _ServicesTab();

  @override
  State<_ServicesTab> createState() => _ServicesTabState();
}

class _ServicesTabState extends State<_ServicesTab> {
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 1;
  final int _itemsPerPage = 10;
  bool _loading = false;
  Map<String, dynamic> _filters = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadData() {
    setState(() => _loading = true);
    context
        .read<ServiceProvider>()
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
    final nameController =
        TextEditingController(text: _filters['name__icontains'] ?? '');
    final descController =
        TextEditingController(text: _filters['description__icontains'] ?? '');

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Filtros de Servicios'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nombre contiene'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              decoration:
                  const InputDecoration(labelText: 'Descripción contiene'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              nameController.clear();
              descController.clear();
            },
            child: const Text('Limpiar'),
          ),
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              Map<String, dynamic> out = {};
              if (nameController.text.isNotEmpty)
                out['name__icontains'] = nameController.text;
              if (descController.text.isNotEmpty)
                out['description__icontains'] = descController.text;
              Navigator.pop(ctx, out);
            },
            child: const Text('Aplicar'),
          ),
        ],
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

  Future<void> _openFormDialog([ServiceModel? service]) async {
    final isEdit = service != null;
    final nameController = TextEditingController(text: service?.name ?? '');
    final descController =
        TextEditingController(text: service?.description ?? '');
    final timeController =
        TextEditingController(text: service?.responseTime ?? '');
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEdit ? 'Editar Servicio' : 'Nuevo Servicio'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: timeController,
                decoration: const InputDecoration(
                    labelText: 'Tiempo de Respuesta (Ej. 72h)'),
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (result == true && formKey.currentState!.validate()) {
      setState(() => _loading = true);
      final data = {
        'name': nameController.text,
        'description': descController.text,
        'response_time': timeController.text,
      };

      bool success;
      if (isEdit) {
        success = await context
            .read<ServiceProvider>()
            .updateService(service!.id, data);
      } else {
        success = await context.read<ServiceProvider>().createService(data);
      }

      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(success ? 'Guardado con éxito' : 'Error al guardar'),
        ));
        if (success) _loadData();
      }
    }
  }

  Future<void> _confirmDelete(ServiceModel service) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Servicio'),
        content: Text('¿Está seguro de eliminar "${service.name}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _loading = true);
      final success =
          await context.read<ServiceProvider>().deleteService(service.id);
      setState(() => _loading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(success ? 'Eliminado con éxito' : 'Error al eliminar'),
        ));
        if (success) {
          _loadData();
          // Update global list
          context
              .read<ServiceProvider>()
              .getAll(page: 1, filters: {'limit': 100});
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ServiceProvider>();
    final items = prov.services;
    final totalCount = prov.servicesCount;
    final totalPages = (totalCount / _itemsPerPage).ceil();

    return Column(
      children: [
        // Controls
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Buscar servicios...',
                ),
                onChanged: (_) {
                  setState(() => _currentPage = 1);
                  _loadData();
                },
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.filter_list),
              label: const Text('Filtrar'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(120, 50)),
              onPressed: _openFiltersDialog,
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Nuevo'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(120, 50)),
              onPressed: () => _openFormDialog(),
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (_loading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          )
        else
          ReusableCrudTable<ServiceModel>(
            headers: const [
              'ID',
              'Nombre',
              'Descripción',
              'Tiempo Resp.',
              'Requisitos',
              'Acciones'
            ],
            flexes: const [1, 2, 3, 1, 2, 1],
            items: items,
            currentPage: _currentPage,
            totalPages: totalPages,
            totalCount: totalCount,
            itemsPerPage: _itemsPerPage,
            emptyMessage: 'No hay servicios configurados.',
            onPageChanged: (p) {
              setState(() => _currentPage = p);
              _loadData();
            },
            rowBuilder: (context, s, index) => Row(
              children: [
                Expanded(
                    flex: 1,
                    child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(s.id.substring(0, 8),
                            style: const TextStyle(fontFamily: 'monospace')))),
                Expanded(
                    flex: 2,
                    child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(s.name,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)))),
                Expanded(
                    flex: 3,
                    child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(s.description))),
                Expanded(
                    flex: 1,
                    child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(s.responseTime))),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Wrap(
                      spacing: 4,
                      children: s.requirements.isEmpty
                          ? [
                              const Text('Sin requisitos',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey))
                            ]
                          : s.requirements
                              .map((req) => Chip(
                                    label: Text(req.documentTypeName,
                                        style: const TextStyle(fontSize: 10)),
                                    backgroundColor: req.required
                                        ? Colors.red[50]
                                        : Colors.grey[100],
                                    padding: EdgeInsets.zero,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ))
                              .toList(),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Wrap(
                    children: [
                      IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _openFormDialog(s)),
                      IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDelete(s)),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ==========================================
// TAB 3: REQUISITOS DE SERVICIO
// ==========================================
class _ServiceRequirementsTab extends StatefulWidget {
  const _ServiceRequirementsTab();

  @override
  State<_ServiceRequirementsTab> createState() =>
      _ServiceRequirementsTabState();
}

class _ServiceRequirementsTabState extends State<_ServiceRequirementsTab> {
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 1;
  final int _itemsPerPage = 10;
  bool _loading = false;
  Map<String, dynamic> _filters = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadData() {
    setState(() => _loading = true);
    context
        .read<ServiceRequirementProvider>()
        .getAll(
          search: _searchController.text,
          page: _currentPage,
          filters: _filters,
        )
        .then((_) {
      if (mounted) setState(() => _loading = false);
    });
  }

  String _getServiceName(String id, List<ServiceModel> services) {
    final s = services.firstWhere((x) => x.id == id,
        orElse: () => ServiceModel(
            id: '',
            name: 'Cargando...',
            description: '',
            responseTime: '',
            requirements: []));
    return s.name.isNotEmpty ? s.name : id;
  }

  String _getDocTypeName(String id, List<DocumentTypeModel> docs) {
    final d = docs.firstWhere((x) => x.id == id,
        orElse: () =>
            DocumentTypeModel(id: '', name: 'Cargando...', description: ''));
    return d.name.isNotEmpty ? d.name : id;
  }

  Future<void> _openFiltersDialog() async {
    final services = context.read<ServiceProvider>().services;
    final docTypes = context.read<DocumentTypeProvider>().documentTypes;

    String? selService = _filters['service'];
    String? selDocType = _filters['document_type'];
    bool? selRequired;
    if (_filters['required'] != null) {
      if (_filters['required'] is bool) {
        selRequired = _filters['required'];
      } else {
        selRequired = _filters['required'].toString() == 'true';
      }
    }

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Filtrar Requisitos'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Servicio',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              DropdownButtonFormField<String>(
                value: selService,
                items: services
                    .map((s) =>
                        DropdownMenuItem(value: s.id, child: Text(s.name)))
                    .toList(),
                onChanged: (v) => setDialogState(() => selService = v),
              ),
              const SizedBox(height: 12),
              const Text('Tipo de Documento',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              DropdownButtonFormField<String>(
                value: selDocType,
                items: docTypes
                    .map((d) =>
                        DropdownMenuItem(value: d.id, child: Text(d.name)))
                    .toList(),
                onChanged: (v) => setDialogState(() => selDocType = v),
              ),
              const SizedBox(height: 12),
              const Text('Obligatorio',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              DropdownButtonFormField<bool>(
                value: selRequired,
                items: const [
                  DropdownMenuItem(value: true, child: Text('Sí')),
                  DropdownMenuItem(value: false, child: Text('No')),
                ],
                onChanged: (v) => setDialogState(() => selRequired = v),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setDialogState(() {
                  selService = null;
                  selDocType = null;
                  selRequired = null;
                });
              },
              child: const Text('Limpiar'),
            ),
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                Map<String, dynamic> out = {};
                if (selService != null) out['service'] = selService;
                if (selDocType != null) out['document_type'] = selDocType;
                if (selRequired != null) out['required'] = selRequired;
                Navigator.pop(ctx, out);
              },
              child: const Text('Aplicar'),
            ),
          ],
        ),
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

  Future<void> _openFormDialog([ServiceRequirementModel? req]) async {
    final isEdit = req != null;
    final services = context.read<ServiceProvider>().services;
    final docTypes = context.read<DocumentTypeProvider>().documentTypes;

    String? selService = req?.service;
    String? selDocType = req?.documentType;
    bool isRequired = req?.required ?? false;
    final notesController = TextEditingController(text: req?.notes ?? '');
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(isEdit ? 'Editar Requisito' : 'Nuevo Requisito'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Servicio',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  DropdownButtonFormField<String>(
                    value: selService,
                    items: services
                        .map((s) =>
                            DropdownMenuItem(value: s.id, child: Text(s.name)))
                        .toList(),
                    onChanged: isEdit
                        ? null
                        : (v) => setDialogState(() => selService = v),
                    validator: (v) => v == null ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 12),
                  const Text('Tipo de Documento',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  DropdownButtonFormField<String>(
                    value: selDocType,
                    items: docTypes
                        .map((d) =>
                            DropdownMenuItem(value: d.id, child: Text(d.name)))
                        .toList(),
                    onChanged: isEdit
                        ? null
                        : (v) => setDialogState(() => selDocType = v),
                    validator: (v) => v == null ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('¿Obligatorio?'),
                    value: isRequired,
                    onChanged: (v) => setDialogState(() => isRequired = v),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: notesController,
                    decoration: const InputDecoration(
                        labelText: 'Notas / Instrucciones'),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );

    if (result == true && formKey.currentState!.validate()) {
      setState(() => _loading = true);
      final data = {
        'service': selService,
        'document_type': selDocType,
        'required': isRequired,
        'notes': notesController.text.isNotEmpty ? notesController.text : null,
      };

      bool success;
      if (isEdit) {
        success = await context
            .read<ServiceRequirementProvider>()
            .updateRequirement(req!.id, data);
      } else {
        success = await context
            .read<ServiceRequirementProvider>()
            .createRequirement(data);
      }

      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(success ? 'Guardado con éxito' : 'Error al guardar'),
        ));
        if (success) {
          _loadData();
          // Reload Service list to sync display requirements
          context
              .read<ServiceProvider>()
              .getAll(page: 1, filters: {'limit': 100});
        }
      }
    }
  }

  Future<void> _confirmDelete(ServiceRequirementModel req) async {
    final services = context.read<ServiceProvider>().services;
    final docTypes = context.read<DocumentTypeProvider>().documentTypes;
    final serviceName = _getServiceName(req.service, services);
    final docName = _getDocTypeName(req.documentType, docTypes);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Requisito'),
        content: Text(
            '¿Desea eliminar el requisito "$docName" para el servicio "$serviceName"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _loading = true);
      final success = await context
          .read<ServiceRequirementProvider>()
          .deleteRequirement(req.id);
      setState(() => _loading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(success ? 'Eliminado con éxito' : 'Error al eliminar'),
        ));
        if (success) {
          _loadData();
          context
              .read<ServiceProvider>()
              .getAll(page: 1, filters: {'limit': 100});
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ServiceRequirementProvider>();
    final items = prov.requirements;
    final totalCount = prov.requirementsCount;
    final totalPages = (totalCount / _itemsPerPage).ceil();

    final services = context.watch<ServiceProvider>().services;
    final docTypes = context.watch<DocumentTypeProvider>().documentTypes;

    return Column(
      children: [
        // Controls
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Buscar requisitos...',
                ),
                onChanged: (_) {
                  setState(() => _currentPage = 1);
                  _loadData();
                },
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.filter_list),
              label: const Text('Filtrar'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(120, 50)),
              onPressed: _openFiltersDialog,
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Nuevo'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(120, 50)),
              onPressed: () => _openFormDialog(),
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (_loading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          )
        else
          ReusableCrudTable<ServiceRequirementModel>(
            headers: const [
              'ID',
              'Servicio',
              'Tipo de Documento',
              'Obligatorio',
              'Notas',
              'Acciones'
            ],
            flexes: const [1, 3, 3, 1, 3, 1],
            items: items,
            currentPage: _currentPage,
            totalPages: totalPages,
            totalCount: totalCount,
            itemsPerPage: _itemsPerPage,
            emptyMessage: 'No hay requisitos de servicio configurados.',
            onPageChanged: (p) {
              setState(() => _currentPage = p);
              _loadData();
            },
            rowBuilder: (context, req, index) => Row(
              children: [
                Expanded(
                    flex: 1,
                    child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(req.id.toString(),
                            style: const TextStyle(fontFamily: 'monospace')))),
                Expanded(
                    flex: 3,
                    child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(_getServiceName(req.service, services),
                            style:
                                const TextStyle(fontWeight: FontWeight.w500)))),
                Expanded(
                    flex: 3,
                    child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child:
                            Text(_getDocTypeName(req.documentType, docTypes)))),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: req.required ? Colors.red[50] : Colors.green[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        req.required ? 'Obligatorio' : 'Opcional',
                        style: TextStyle(
                            color: req.required
                                ? Colors.red[700]
                                : Colors.green[700],
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                Expanded(
                    flex: 3,
                    child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(req.notes ?? 'Sin notas',
                            style: TextStyle(
                                color: req.notes == null
                                    ? Colors.grey
                                    : Colors.black,
                                fontSize: 13)))),
                Expanded(
                  flex: 1,
                  child: Wrap(
                    children: [
                      IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _openFormDialog(req)),
                      IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDelete(req)),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ==========================================
// TAB 4: PAGOS
// ==========================================
class _PaymentsTab extends StatefulWidget {
  const _PaymentsTab();

  @override
  State<_PaymentsTab> createState() => _PaymentsTabState();
}

class _PaymentsTabState extends State<_PaymentsTab> {
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 1;
  final int _itemsPerPage = 10;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadData() {
    setState(() => _loading = true);
    context
        .read<PaymentProvider>()
        .getAll(
          search: _searchController.text,
          page: _currentPage,
        )
        .then((_) {
      if (mounted) setState(() => _loading = false);
    });
  }

  Future<void> _openFormDialog([PaymentModel? payment]) async {
    final isEdit = payment != null;
    final services = context.read<ServiceProvider>().services;

    String? selService = payment?.service;
    bool requiresPayment = payment?.requiresPayment ?? true;
    final amountController =
        TextEditingController(text: payment?.amount ?? '0.00');
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(isEdit
              ? 'Editar Configuración de Pago'
              : 'Nueva Configuración de Pago'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Servicio',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                DropdownButtonFormField<String>(
                  value: selService,
                  items: services
                      .map((s) =>
                          DropdownMenuItem(value: s.id, child: Text(s.name)))
                      .toList(),
                  onChanged: isEdit
                      ? null
                      : (v) => setDialogState(() => selService = v),
                  validator: (v) => v == null ? 'Requerido' : null,
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('¿Requiere pago?'),
                  value: requiresPayment,
                  onChanged: (v) => setDialogState(() => requiresPayment = v),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: amountController,
                  decoration: const InputDecoration(labelText: 'Monto (\$)'),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Requerido';
                    if (double.tryParse(v) == null) return 'Monto inválido';
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );

    if (result == true && formKey.currentState!.validate()) {
      setState(() => _loading = true);
      final data = {
        'service': selService,
        'requires_payment': requiresPayment,
        'amount': amountController.text,
      };

      bool success;
      if (isEdit) {
        success = await context
            .read<PaymentProvider>()
            .updatePayment(payment!.id, data);
      } else {
        success = await context.read<PaymentProvider>().createPayment(data);
      }

      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(success ? 'Guardado con éxito' : 'Error al guardar'),
        ));
        if (success) _loadData();
      }
    }
  }

  Future<void> _confirmDelete(PaymentModel payment) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Configuración de Pago'),
        content: Text(
            '¿Desea eliminar la configuración de pago para "${payment.serviceName ?? payment.service}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _loading = true);
      final success =
          await context.read<PaymentProvider>().deletePayment(payment.id);
      setState(() => _loading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(success ? 'Eliminado con éxito' : 'Error al eliminar'),
        ));
        if (success) _loadData();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<PaymentProvider>();
    final items = prov.payments;
    final totalCount = prov.paymentsCount;
    final totalPages = (totalCount / _itemsPerPage).ceil();

    final services = context.watch<ServiceProvider>().services;

    return Column(
      children: [
        // Controls
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Buscar por nombre de servicio...',
                ),
                onChanged: (_) {
                  setState(() => _currentPage = 1);
                  _loadData();
                },
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Nuevo'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(120, 50)),
              onPressed: () => _openFormDialog(),
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (_loading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          )
        else
          ReusableCrudTable<PaymentModel>(
            headers: const [
              'ID',
              'Servicio',
              'Requiere Pago',
              'Monto',
              'Acciones'
            ],
            flexes: const [1, 4, 2, 2, 1],
            items: items,
            currentPage: _currentPage,
            totalPages: totalPages,
            totalCount: totalCount,
            itemsPerPage: _itemsPerPage,
            emptyMessage: 'No hay configuraciones de pago registradas.',
            onPageChanged: (p) {
              setState(() => _currentPage = p);
              _loadData();
            },
            rowBuilder: (context, p, index) {
              // Find service name locally if null in API
              String name = p.serviceName ?? '';
              if (name.isEmpty) {
                final s = services.firstWhere((x) => x.id == p.service,
                    orElse: () => ServiceModel(
                        id: '',
                        name: '',
                        description: '',
                        responseTime: '',
                        requirements: []));
                name = s.name.isNotEmpty ? s.name : p.service;
              }

              return Row(
                children: [
                  Expanded(
                      flex: 1,
                      child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(p.id.substring(0, 8),
                              style:
                                  const TextStyle(fontFamily: 'monospace')))),
                  Expanded(
                      flex: 4,
                      child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold)))),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: p.requiresPayment
                              ? Colors.orange[50]
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          p.requiresPayment ? 'Requiere Pago' : 'Gratuito',
                          style: TextStyle(
                              color: p.requiresPayment
                                  ? Colors.orange[700]
                                  : Colors.grey[700],
                              fontSize: 10,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                      flex: 2,
                      child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text('\$${p.amount}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green)))),
                  Expanded(
                    flex: 1,
                    child: Wrap(
                      children: [
                        IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _openFormDialog(p)),
                        IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confirmDelete(p)),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
      ],
    );
  }
}
