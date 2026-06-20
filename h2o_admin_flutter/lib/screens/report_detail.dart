import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import '../core/config.dart';
import '../models/report_model.dart';
import '../models/user_model.dart';
import '../models/media_model.dart';
import '../providers/report_provider.dart';
import '../providers/user_provider.dart';

class ReportDetailScreen extends StatefulWidget {
  final String reportId;
  final bool isEditMode;

  const ReportDetailScreen({
    required this.reportId,
    this.isEditMode = false,
    super.key,
  });

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  bool _isEdit = false;
  bool _loading = true;
  bool _saving = false;
  ReportModel? _report;
  List<UserModel> _operators = [];
  List<MediaModel> _mediaList = [];
  bool _loadingMedia = false;

  // Controllers for editing
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _locationController;
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;
  late TextEditingController _descriptionController;
  late TextEditingController _notesController;
  late TextEditingController _estimatedTimeController;

  String? _selectedStatus;
  String? _selectedReportType;
  String? _selectedOperatorId;

  final MapController _mapController = MapController();

  static const List<String> _reportTypes = [
    'baja',
    'media',
    'alta',
    'extrema',
  ];

  static const List<String> _statuses = [
    'Recibido',
    'En revisión',
    'En atención',
    'Resuelto',
    'Cerrado',
  ];

  @override
  void initState() {
    super.initState();
    _isEdit = widget.isEditMode;
    _locationController = TextEditingController();
    _latitudeController = TextEditingController();
    _longitudeController = TextEditingController();
    _descriptionController = TextEditingController();
    _notesController = TextEditingController();
    _estimatedTimeController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    _locationController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    _estimatedTimeController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() => _loading = true);
    try {
      final reportProvider = context.read<ReportProvider>();
      final userProvider = context.read<UserProvider>();

      // 1. Fetch operators list
      final ops = await userProvider.getOperators(null);
      setState(() => _operators = ops);

      // 2. Fetch report detail
      final rep = await reportProvider.getReportDetail(widget.reportId);
      if (rep != null) {
        setState(() {
          _report = rep;
          _locationController.text = rep.locationText;
          _latitudeController.text = rep.latitude.toString();
          _longitudeController.text = rep.longitude.toString();
          _descriptionController.text = rep.description;
          _notesController.text = rep.notes ?? '';
          _estimatedTimeController.text = rep.estimatedTime ?? '';
          
          _selectedReportType = _reportTypes.contains(rep.reportType)
              ? rep.reportType
              : _reportTypes.first;
              
          _selectedStatus = _statuses.contains(rep.statusText)
              ? rep.statusText
              : _statuses.first;

          _selectedOperatorId = rep.assignedOperatorId;
          // Clean empty or not matching assigned Operator
          if (_selectedOperatorId != null &&
              !_operators.any((o) => o.id == _selectedOperatorId)) {
            _selectedOperatorId = null;
          }
        });

        // 3. Fetch media evidence asynchronously
        if (rep.media.isNotEmpty) {
          _fetchMedia(rep.media);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar datos del reporte: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _fetchMedia(List<String> mediaIds) async {
    setState(() => _loadingMedia = true);
    try {
      final list = await context.read<ReportProvider>().getReportMedia(mediaIds);
      setState(() => _mediaList = list);
    } catch (e) {
      print('Error loading media: $e');
    } finally {
      setState(() => _loadingMedia = false);
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final lat = double.tryParse(_latitudeController.text);
      final lon = double.tryParse(_longitudeController.text);
      if (lat == null || lon == null) {
        throw Exception('Las coordenadas deben ser números válidos');
      }

      final success = await context.read<ReportProvider>().updateReport(
            widget.reportId,
            latitude: lat,
            longitude: lon,
            locationText: _locationController.text.trim(),
            reportType: _selectedReportType!,
            description: _descriptionController.text.trim(),
            status: _selectedStatus!,
            assignedOperatorId: _selectedOperatorId ?? '',
            estimatedTime: _estimatedTimeController.text.trim(),
            notes: _notesController.text.trim(),
          );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reporte actualizado exitosamente')),
        );
        setState(() => _isEdit = false);
        // Reload details to sync
        _loadInitialData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al actualizar el reporte')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _saving = false);
    }
  }

  String _getOperatorName(String? id) {
    if (id == null || id.isEmpty) return 'No asignado';
    final op = _operators.firstWhere((o) => o.id == id, orElse: () => UserModel(id: id, email: id, role: UserRole.operator));
    return op.name ?? op.email;
  }

  Color _getSeverityColor(String? type) {
    switch (type?.toLowerCase()) {
      case 'baja':
        return Colors.green;
      case 'media':
        return Colors.blue;
      case 'alta':
        return Colors.orange;
      case 'extrema':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showImageDialog(BuildContext context, MediaModel media) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 800,
            maxHeight: 600,
          ),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                iconTheme: const IconThemeData(color: Colors.white),
                title: Text(
                  media.filename,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Image.network(
                    media.presignedUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Text(
                          'Error al cargar imagen',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: AppConfig.backgroundGray,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_report == null) {
      return Scaffold(
        backgroundColor: AppConfig.backgroundGray,
        appBar: AppBar(
          title: const Text('Reporte no encontrado'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('El reporte solicitado no existe o no se pudo cargar.'),
              const SizedBox(height: 16),
              Expanded(child: 
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Volver al listado'),
              ),
              ),
            ],
          ),
        ),
      );
    }


    final mapLatLng = LatLng(
      double.tryParse(_latitudeController.text) ?? _report!.latitude,
      double.tryParse(_longitudeController.text) ?? _report!.longitude,
    );

    return Scaffold(
      backgroundColor: AppConfig.backgroundGray,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Breadcrumbs & Back Button Row
                Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.of(context).pop(true),
                      child: const Text(
                        'Gestión de Red',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('/', style: TextStyle(color: Colors.grey)),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => Navigator.of(context).pop(true),
                      child: const Text(
                        'Fugas Reportadas',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('/', style: TextStyle(color: Colors.grey)),
                    const SizedBox(width: 8),
                    Text(
                      'Reporte Folio #${_report!.folio}',
                      style: TextStyle(
                        color: AppConfig.primaryBlue,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Title and Action Buttons Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.of(context).pop(true),
                          tooltip: 'Volver',
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Reporte Folio #${_report!.folio}',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Status Badge
                        _buildStatusBadge(_report!),
                      ],
                    ),
                    // Action button: Toggle Edit / Save
                    Row(
                      children: [
                        if (_isEdit) ...[
                          OutlinedButton.icon(
                            icon: const Icon(Icons.cancel),
                            label: const Text('Cancelar'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.grey[700],
                              side: BorderSide(color: Colors.grey[300]!),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            ),
                            onPressed: () {
                              setState(() {
                                _isEdit = false;
                                // Reset fields
                                _locationController.text = _report!.locationText;
                                _latitudeController.text = _report!.latitude.toString();
                                _longitudeController.text = _report!.longitude.toString();
                                _descriptionController.text = _report!.description;
                                _notesController.text = _report!.notes ?? '';
                                _estimatedTimeController.text = _report!.estimatedTime ?? '';
                                _selectedReportType = _report!.reportType;
                                _selectedStatus = _report!.statusText;
                                _selectedOperatorId = _report!.assignedOperatorId;
                              });
                            },
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            icon: _saving
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : const Icon(Icons.save),
                            label: Text(_saving ? 'Guardando...' : 'Guardar Cambios'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppConfig.primaryBlue,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(0, 50),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            ),
                            onPressed: _saving ? null : _saveChanges,
                          ),
                        ] else ...[
                          ElevatedButton.icon(
                            icon: const Icon(Icons.edit),
                            label: const Text('Editar Reporte'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppConfig.primaryBlue,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(0, 50),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            ),
                            onPressed: () => setState(() => _isEdit = true),
                          ),
                        ]
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Responsive Grid Layout
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 900;
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Column (Details Form/Fields)
                        Expanded(
                          flex: isWide ? 3 : 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildGeneralInfoCard(),
                              const SizedBox(height: 16),
                              _buildLocationInfoCard(),
                            ],
                          ),
                        ),
                        if (isWide) const SizedBox(width: 24),
                        // Right Column (Map and Media)
                        if (isWide)
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildMapCard(mapLatLng),
                                const SizedBox(height: 16),
                                _buildMediaCard(),
                              ],
                            ),
                          ),
                      ],
                    );
                  },
                ),
                // If not wide screen, display the map and media cards below in single column
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 900;
                    if (!isWide) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 16),
                          _buildMapCard(mapLatLng),
                          const SizedBox(height: 16),
                          _buildMediaCard(),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(ReportModel report) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: report.statusColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: report.statusColor.withOpacity(0.3)),
      ),
      child: Text(
        report.statusText,
        style: TextStyle(
          color: report.statusColor,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildGeneralInfoCard() {
    return Card(
      color: Colors.white,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información General',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    label: 'ID del Reporte',
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _report!.id,
                            style: const TextStyle(fontSize: 14, fontFamily: 'monospace'),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 16),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: _report!.id));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('ID copiado al portapapeles'), duration: Duration(seconds: 1)),
                            );
                          },
                          tooltip: 'Copiar ID',
                          splashRadius: 18,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: _buildInfoItem(
                    label: 'Fecha Reportada',
                    child: Text(
                      DateFormat('dd/MM/yyyy HH:mm').format(_report!.reportedAt),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    label: 'Reportado por (Usuario)',
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _report!.user,
                            style: const TextStyle(fontSize: 14, fontFamily: 'monospace'),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 16),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: _report!.user));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('ID copiado al portapapeles'), duration: Duration(seconds: 1)),
                            );
                          },
                          tooltip: 'Copiar ID',
                          splashRadius: 18,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: _buildInfoItem(
                    label: 'Tipo de Reporte / Fuga',
                    child: _isEdit
                        ? DropdownButtonFormField<String>(
                            value: _selectedReportType,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            items: _reportTypes
                                .map((t) => DropdownMenuItem(
                                      value: t,
                                      child: Text(t.toUpperCase()),
                                    ))
                                .toList(),
                            onChanged: (val) => setState(() => _selectedReportType = val),
                          )
                        : Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: _getSeverityColor(_report!.reportType),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _report!.reportType.toUpperCase(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _getSeverityColor(_report!.reportType),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    label: 'Estado de Atención',
                    child: _isEdit
                        ? DropdownButtonFormField<String>(
                            value: _selectedStatus,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            items: _statuses
                                .map((s) => DropdownMenuItem(
                                      value: s,
                                      child: Text(s),
                                    ))
                                .toList(),
                            onChanged: (val) => setState(() => _selectedStatus = val),
                          )
                        : Text(
                            _report!.statusText,
                            style: const TextStyle(fontSize: 14),
                          ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: _buildInfoItem(
                    label: 'Operador Asignado',
                    child: _isEdit
                        ? DropdownButtonFormField<String?>(
                            value: _selectedOperatorId,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            hint: const Text('No asignado'),
                            items: [
                              const DropdownMenuItem<String?>(
                                value: null,
                                child: Text('No asignado'),
                              ),
                              ..._operators.map((op) => DropdownMenuItem<String?>(
                                    value: op.id,
                                    child: Text(op.name ?? op.email),
                                  )),
                            ],
                            onChanged: (val) => setState(() => _selectedOperatorId = val),
                          )
                        : Text(
                            _getOperatorName(_report!.assignedOperatorId),
                            style: const TextStyle(fontSize: 14),
                          ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    label: 'Tiempo Estimado de Atención',
                    child: _isEdit
                        ? TextFormField(
                            controller: _estimatedTimeController,
                            decoration: const InputDecoration(
                              hintText: 'Ej. 2h, 4h, 1d',
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                          )
                        : Text(
                            _report!.estimatedTime?.isEmpty == false ? _report!.estimatedTime! : 'Sin estimación',
                            style: const TextStyle(fontSize: 14),
                          ),
                  ),
                ),
                const SizedBox(width: 24),
                const Expanded(child: SizedBox.shrink()),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoItem(
              label: 'Descripción del Reporte',
              child: _isEdit
                  ? TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Describa el incidente...',
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      validator: (val) => val == null || val.trim().isEmpty ? 'La descripción es requerida' : null,
                    )
                  : Text(
                      _report!.description.isEmpty ? 'Sin descripción' : _report!.description,
                      style: const TextStyle(fontSize: 14),
                    ),
            ),
            const SizedBox(height: 16),
            _buildInfoItem(
              label: 'Notas Internas / Bitácora',
              child: _isEdit
                  ? TextFormField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Notas de atención o bitácora de seguimiento...',
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    )
                  : Text(
                      _report!.notes?.isEmpty == false ? _report!.notes! : 'Sin notas registradas',
                      style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationInfoCard() {
    return Card(
      color: Colors.white,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ubicación y Coordenadas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 24),
            _buildInfoItem(
              label: 'Dirección o Referencia de Ubicación',
              child: _isEdit
                  ? TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        hintText: 'Ej. fuentes del papagaso',
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      validator: (val) => val == null || val.trim().isEmpty ? 'La ubicación es requerida' : null,
                    )
                  : Text(
                      _report!.locationText,
                      style: const TextStyle(fontSize: 14),
                    ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    label: 'Latitud',
                    child: _isEdit
                        ? TextFormField(
                            controller: _latitudeController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
                            onChanged: (val) {
                              // Force map center refresh if valid double
                              final dVal = double.tryParse(val);
                              if (dVal != null) {
                                final currentLon = double.tryParse(_longitudeController.text) ?? _report!.longitude;
                                _mapController.move(LatLng(dVal, currentLon), _mapController.camera.zoom);
                              }
                            },
                          )
                        : Text(
                            _report!.latitude.toString(),
                            style: const TextStyle(fontSize: 14),
                          ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: _buildInfoItem(
                    label: 'Longitud',
                    child: _isEdit
                        ? TextFormField(
                            controller: _longitudeController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
                            onChanged: (val) {
                              // Force map center refresh if valid double
                              final dVal = double.tryParse(val);
                              if (dVal != null) {
                                final currentLat = double.tryParse(_latitudeController.text) ?? _report!.latitude;
                                _mapController.move(LatLng(currentLat, dVal), _mapController.camera.zoom);
                              }
                            },
                          )
                        : Text(
                            _report!.longitude.toString(),
                            style: const TextStyle(fontSize: 14),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapCard(LatLng currentLatLng) {
    return Card(
      color: Colors.white,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Ubicación Geográfica',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                if (_isEdit)
                  Text(
                    'Toca en el mapa para reubicar',
                    style: TextStyle(fontSize: 12, color: AppConfig.secondaryAzure),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[200]!),
                borderRadius: BorderRadius.circular(8),
              ),
              clipBehavior: Clip.antiAlias,
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: currentLatLng,
                  initialZoom: 15.0,
                  onTap: (tapPos, latLng) {
                    if (_isEdit) {
                      setState(() {
                        _latitudeController.text = latLng.latitude.toString();
                        _longitudeController.text = latLng.longitude.toString();
                      });
                      _mapController.move(latLng, _mapController.camera.zoom);
                    }
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'h2o_admin_flutter',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: currentLatLng,
                        width: 40.0,
                        height: 40.0,
                        child: Icon(
                          Icons.location_on,
                          color: _getSeverityColor(_selectedReportType ?? _report!.reportType),
                          size: 40.0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: () {
                    _mapController.move(currentLatLng, 15.0);
                  },
                  icon: const Icon(Icons.center_focus_strong, size: 16),
                  label: const Text('Centrar marcador', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaCard() {
    return Card(
      color: Colors.white,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Evidencia Fotográfica',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (_loadingMedia)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_mediaList.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 36.0),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  children: [
                    Icon(Icons.photo_library_outlined, size: 36, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text(
                      'No hay imágenes adjuntas',
                      style: TextStyle(color: Colors.grey[500], fontSize: 13),
                    ),
                  ],
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1,
                ),
                itemCount: _mediaList.length,
                itemBuilder: (context, index) {
                  final media = _mediaList[index];
                  return InkWell(
                    onTap: () => _showImageDialog(context, media),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[200]!),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            media.presignedUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(strokeWidth: 2),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[100],
                                child: Icon(Icons.broken_image, color: Colors.grey[400]),
                              );
                            },
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              color: Colors.black.withOpacity(0.5),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                              child: Text(
                                media.filename,
                                style: const TextStyle(color: Colors.white, fontSize: 10),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}
