import 'package:flutter/material.dart';
import '../screens/login.dart';
import '../screens/admin_home.dart';
import '../screens/report_detail.dart';

/// Nombres de rutas de la aplicación
class AppRoutes {
  static const String login = '/login';
  static const String home = '/home';
  static const String reports = '/reports';
  static const String admin = '/admin';
  static const String reportDetail = '/report-detail';

  /// Generador de rutas
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );
      case home:
      case reports:
      case admin:
        return MaterialPageRoute(
          builder: (_) => const AdminHome(),
          settings: settings,
        );
      case reportDetail:
        final args = settings.arguments as ReportDetailArguments;
        return MaterialPageRoute(
          builder: (_) => ReportDetailScreen(
            reportId: args.reportId,
            isEditMode: args.isEditMode,
          ),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No se definió una ruta para: ${settings.name}'),
            ),
          ),
        );
    }
  }
}

/// Argumentos para la pantalla de detalle de reportes
class ReportDetailArguments {
  final String reportId;
  final bool isEditMode;

  ReportDetailArguments({
    required this.reportId,
    this.isEditMode = false,
  });
}
