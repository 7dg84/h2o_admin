import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'services/api.dart';
import 'screens/login.dart';
import 'screens/reports_list.dart';
import 'screens/admin_home.dart';
import 'core/config.dart';
import 'providers/navigation_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/report_provider.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/report_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final apiService = ApiService();
  final authService = AuthService(apiService);
  final reportService = ReportService(apiService);
  // final tramiteService = TramiteService(apiService);
  // final serviceService = ServiceService(apiService);

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => AuthProvider(authService)),
    ChangeNotifierProvider(create: (_) => NavigationProvider()),
    ChangeNotifierProvider(create: (_) => ReportProvider(reportService)),
    // ChangeNotifierProvider(create: (_) => TramiteProvider(tramiteService)),
    // ChangeNotifierProvider(create: (_) => ServiceProvider(serviceService)),
  ], child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'H2O Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppConfig.primaryBlue,
          primary: AppConfig.primaryBlue,
          secondary: AppConfig.secondaryAzure,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: AppConfig.backgroundGray,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConfig.primaryBlue,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppConfig.cardBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppConfig.cardBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide:
                const BorderSide(color: AppConfig.primaryBlue, width: 2),
          ),
        ),
        cardTheme: CardThemeData(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: AppConfig.cardBorder))),
      ),
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return auth.isAuthenticated ? const AdminHome() : const LoginScreen();
        },
      ),
      // onGenerateRoute: (settings) {
      //   if (settings.name == '/report-detail') {
      //     final reportId = settings.arguments as String;
      //     return MaterialPageRoute(
      //       builder: (context) => ReportDetailScreen(reportId: reportId),
      //     );
      //   }
      // },
      routes: {
        '/reports': (context) => const AdminHome(),
        '/admin': (context) => const AdminHome(),
      },
    );
  }
}
