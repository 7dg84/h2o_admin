import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/report_model.dart';
import '../providers/report_provider.dart';

class ReportsMapPage extends StatefulWidget {
  const ReportsMapPage({super.key});

  @override
  State<ReportsMapPage> createState() => _ReportsMapPageState();
}

class _ReportsMapPageState extends State<ReportsMapPage> {
  late TextEditingController _searchController;
  final MapController _mapController = MapController();
  int _currentPage = 1;
  int _itemsPerPage = 10;
  bool _loading = false;
  ReportModel? _selectedReport;

  // Color mapping for report types
  static const Map<String, Color> reportTypeColors = {
    'Superficial': Colors.blue,
    'Tuberia': Colors.teal,
    'Domiciliaria': Colors.orange,
    'Obstruido': Colors.red,
  };

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
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await context.read<ReportProvider>().fetchAllReports();
  }

  Color _getMarkerColor(String type) {
    switch (type) {
      case 'superficial':
        return Colors.blue;
      case 'tuberia':
        return Colors.teal;
      case 'domiciliaria':
        return Colors.orange;
      case 'obstruido':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _onMarkerTap(ReportModel report) {
    if (report.latitude != null && report.longitude != null) {
      _mapController.move(LatLng(report.latitude!, report.longitude!), 16);
    }
    setState(() => _selectedReport = report);
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

    return Column(
      children: [
        // Search and Controls Bar
        // Padding(
        //   padding: const EdgeInsets.all(16.0),
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //     children: [
        //       Expanded(
        //         child: TextField(
        //           controller: _searchController,
        //           decoration: InputDecoration(
        //             prefixIcon: const Icon(Icons.search),
        //             hintText: 'Buscar por folio o ubicación...',
        //             border: OutlineInputBorder(
        //               borderRadius: BorderRadius.circular(8),
        //             ),
        //             contentPadding: const EdgeInsets.symmetric(
        //                 horizontal: 16, vertical: 12),
        //           ),
        //           onChanged: (value) {
        //             // TODO: Implementar búsqueda en tiempo real
        //             setState(() => _currentPage = 1);
        //           },
        //         ),
        //       ),
        //       const SizedBox(width: 16),
        //       SizedBox(
        //         width: 120,
        //         child: ElevatedButton.icon(
        //           icon: const Icon(Icons.filter_list),
        //           label: const Text('Filtrar'),
        //           style: ElevatedButton.styleFrom(
        //             padding: const EdgeInsets.symmetric(
        //                 horizontal: 16, vertical: 12),
        //             shape: RoundedRectangleBorder(
        //               borderRadius: BorderRadius.circular(8),
        //             ),
        //           ),
        //           onPressed: () {
        //             // TODO: Implementar diálogo de filtros avanzados
        //           },
        //         ),
        //       ),
        //     ],
        //   ),
        // ),

        if (_loading)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: LinearProgressIndicator(),
          ),
        // Map
        Expanded(
          child: reports.isEmpty
              ? const Center(child: Text('No hay reportes para mostrar'))
              : Stack(
                  children: [
                    SizedBox.expand(
                      child: FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter:
                              LatLng(19.4184, -98.9452), // Default: Chimalhucán
                          initialZoom: 13,
                          interactiveFlags: InteractiveFlag.all,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.h2ochimal.app',
                          ),
                          MarkerLayer(
                            markers: [
                              ...reports
                                  .where((r) =>
                                      r.latitude != null && r.longitude != null)
                                  .map(
                                    (report) => Marker(
                                      point: LatLng(
                                          report.latitude!, report.longitude!),
                                      width: 40,
                                      height: 40,
                                      child: GestureDetector(
                                        onTap: () => _onMarkerTap(report),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: _getMarkerColor(
                                                report.reportType),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: _selectedReport?.id ==
                                                      report.id
                                                  ? Colors.white
                                                  : Colors.transparent,
                                              width: 3,
                                            ),
                                            boxShadow:
                                                _selectedReport?.id == report.id
                                                    ? [
                                                        BoxShadow(
                                                          color: Colors.black
                                                              .withOpacity(0.3),
                                                          blurRadius: 8,
                                                          spreadRadius: 2,
                                                        )
                                                      ]
                                                    : [],
                                          ),
                                          child: const Center(
                                            child: Icon(
                                              Icons.location_on,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Selected Report Details Card
                    if (_selectedReport != null)
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _selectedReport!.folio,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue[700],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: _getMarkerColor(
                                              _selectedReport!.reportType)
                                          .withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      _selectedReport!.reportType ?? 'N/A',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: _getMarkerColor(
                                            _selectedReport!.reportType),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _selectedReport!.locationText ??
                                    'Sin ubicación',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Estado: ${_selectedReport!.statusText}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      // TODO: Implementar navegación a detalle
                                    },
                                    child: const Text('Ver detalles'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
        ),
        // Pagination
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.grey[300]!),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mostrando ${startIndex + 1}-${endIndex} de ${filteredReports.length} reportes',
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
        ),
        // Legend
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.grey[300]!),
            ),
          ),
          child: Row(
            children: [
              const Text(
                'Tipos de fuga:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const SizedBox(width: 16),
              ..._buildLegendItems(),
            ],
          ),
        ),
      ],
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
      buttons.add(_buildPageButton(i));
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

  List<Widget> _buildLegendItems() {
    return reportTypeColors.entries
        .where((e) => e.key != 'defaul')
        .map(
          (entry) => Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: entry.value,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  entry.key.replaceAll('_', ' ').toUpperCase(),
                  style: const TextStyle(fontSize: 11),
                ),
              ],
            ),
          ),
        )
        .toList();
  }
}
