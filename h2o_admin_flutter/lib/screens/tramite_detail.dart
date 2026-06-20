import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/tramite_model.dart';
import '../providers/tramite_provider.dart';
import '../providers/document_provider.dart';

class TramiteDetailScreen extends StatefulWidget {
  final String tramiteId;
  final bool isEditMode;

  const TramiteDetailScreen({
    required this.tramiteId,
    this.isEditMode = false,
    super.key,
  });

  @override
  State<TramiteDetailScreen> createState() => _TramiteDetailScreenState();
}

class _TramiteDetailScreenState extends State<TramiteDetailScreen> {
  bool _isEdit = false;
  bool _loading = true;
  bool _saving = false;
  TramiteModel? _tramite;

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _notesController;
  String? _selectedStatus;
  String? _fetchingDocId;

  static const List<String> _statuses = [
    'Creado',
    'En tramite',
    'Completado',
  ];

  @override
  void initState() {
    super.initState();
    _isEdit = widget.isEditMode;
    _notesController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _loadData() {
    setState(() => _loading = true);
    context.read<TramiteProvider>().getDetail(widget.tramiteId).then((value) {
      if (value != null && mounted) {
        setState(() {
          _tramite = value;
          _notesController.text = value.notes ?? '';
          _selectedStatus = value.status;
          _loading = false;
        });
      } else if (mounted) {
        setState(() => _loading = false);
      }
    });
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _saving = true);

      final Map<String, dynamic> data = {
        'status': _selectedStatus,
        'notes':
            _notesController.text.isNotEmpty ? _notesController.text : null,
        'service': _tramite!.service,
        'user': _tramite!.user,
      };

      final success = await context
          .read<TramiteProvider>()
          .updateTramite(_tramite!.id, data);

      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'Trámite actualizado con éxito'
                : 'Error al actualizar el trámite'),
          ),
        );
        if (success) {
          Navigator.of(context).pop(true);
        }
      }
    }
  }

  void _fetchAndCopyDocumentUrl(TramiteDocumentShort doc) async {
    setState(() => _fetchingDocId = doc.id);
    final detail = await context.read<DocumentProvider>().getDetail(doc.id);
    setState(() => _fetchingDocId = null);

    if (detail != null && detail.presignedUrl != null && mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Enlace del Documento: ${doc.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Se ha generado un enlace pre-firmado temporal válido por unos minutos:',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              SelectableText(
                detail.presignedUrl!,
                style: const TextStyle(fontSize: 13, color: Colors.blue),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cerrar'),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.copy),
              label: const Text('Copiar Enlace'),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: detail.presignedUrl!));
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Enlace copiado al portapapeles con éxito'),
                  ),
                );
              },
            ),
          ],
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al recuperar la dirección del documento'),
        ),
      );
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
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_tramite == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalle de Trámite')),
        body: const Center(
          child: Text('No se pudieron cargar los detalles del trámite'),
        ),
      );
    }

    final formattedDate =
        '${_tramite!.createdAt.day}/${_tramite!.createdAt.month}/${_tramite!.createdAt.year} ${_tramite!.createdAt.hour}:${_tramite!.createdAt.minute}';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Trámite Folio #${_tramite!.folio}'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (!_isEdit)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: TextButton.icon(
                icon: const Icon(Icons.edit),
                label: const Text('Editar'),
                onPressed: () => setState(() => _isEdit = true),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column (Details and edit form)
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Service and General Info Card
                    Card(
                      elevation: 0,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey[200]!),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Información General',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const Divider(height: 32),
                            _buildInfoRow('Servicio Solicitado',
                                _tramite!.serviceName ?? 'N/A'),
                            _buildInfoRow('ID del Servicio', _tramite!.service),
                            _buildInfoRow('Folio', '#${_tramite!.folio}'),
                            _buildInfoRow('Fecha de Creación', formattedDate),
                            _buildInfoRow(
                                'Usuario Solicitante (ID)', _tramite!.user),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Status and Notes (Form fields in edit mode, text in read mode)
                    Card(
                      elevation: 0,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey[200]!),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Resolución del Trámite',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const Divider(height: 32),
                            if (!_isEdit) ...[
                              // Read-only state
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 150,
                                    child: Text(
                                      'Estado Actual:',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(_tramite!.status)
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _tramite!.status,
                                      style: TextStyle(
                                        color:
                                            _getStatusColor(_tramite!.status),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    width: 150,
                                    child: Text(
                                      'Notas / Indicaciones:',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      _tramite!.notes ?? 'Sin observaciones.',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                            ] else ...[
                              // Editable state
                              DropdownButtonFormField<String>(
                                value: _statuses.contains(_selectedStatus) ? _selectedStatus : null,
                                decoration: const InputDecoration(
                                    labelText: 'Estado *'),
                                items: _statuses
                                    .map((status) => DropdownMenuItem(
                                          value: status,
                                          child: Text(status),
                                        ))
                                    .toList(),
                                onChanged: (val) =>
                                    setState(() => _selectedStatus = val),
                                validator: (val) =>
                                    val == null ? 'Seleccione un estado' : null,
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: _notesController,
                                decoration: const InputDecoration(
                                  labelText: 'Notas / Observaciones',
                                  hintText:
                                      'Añada observaciones o requerimientos para el ciudadano...',
                                  alignLabelWithHint: true,
                                ),
                                maxLines: 4,
                              ),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: _saving
                                        ? null
                                        : () => setState(() {
                                              _isEdit = false;
                                              _selectedStatus =
                                                  _tramite!.status;
                                              _notesController.text =
                                                  _tramite!.notes ?? '';
                                            }),
                                    child: const Text('Cancelar'),
                                  ),
                                  const SizedBox(width: 12),
                                  SizedBox(
                                    width: 120,
                                    child: ElevatedButton(
                                      onPressed: _saving ? null : _save,
                                      child: _saving
                                          ? const SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2),
                                            )
                                          : const Text('Guardar Cambios'),
                                    ),
                                  ),
                                ],
                              ),
                            ]
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),

              // Right Column (Documents attached list)
              Expanded(
                flex: 2,
                child: Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey[200]!),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Documentos Adjuntos',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const Divider(height: 32),
                        if (_tramite!.documents.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24.0),
                            child: Center(
                              child: Text(
                                'No se adjuntaron documentos a este trámite.',
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 13),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _tramite!.documents.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final doc = _tramite!.documents[index];
                              final isFetchingThis = _fetchingDocId == doc.id;

                              return Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey[100]!),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.description,
                                        color: Colors.grey, size: 24),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            doc.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            doc.filename,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    isFetchingThis
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2),
                                          )
                                        : IconButton(
                                            tooltip: 'Ver/Copiar Enlace',
                                            icon: const Icon(Icons.link,
                                                color: Colors.blue),
                                            onPressed: () =>
                                                _fetchAndCopyDocumentUrl(doc),
                                          ),
                                  ],
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF334155),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
