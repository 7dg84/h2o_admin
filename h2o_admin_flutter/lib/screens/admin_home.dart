import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/report_service.dart';
import '../services/user_service.dart';
import 'admin_layout.dart';
import 'reports_admin.dart';
import 'reports_map.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({Key? key}) : super(key: key);

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  final List<String> _sections = [
    'Reportes',
    'Mapa',
    'Usuarios',
    'Medios',
    'Ajustes'
  ];
  int _selected = 0;

  // late final ApiService _apiService;
  late final ReportService _reportService;
  late final UserService _userService;

  @override
  void initState() {
    super.initState();
  }

  Widget _buildContent() {
    switch (_selected) {
      case 0:
        return ReportsAdminPage();
      case 1:
        return const ReportsMapPage();
      default:
        return Center(
            child: Text('Sección: ${_sections[_selected]} (pendiente)'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      child: _buildContent(),
      sections: _sections,
      selectedIndex: _selected,
      onSelect: (i) => setState(() => _selected = i),
    );
  }
}
