import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Ajusta esta URL según tu entorno
  static String baseUrl = 'http://localhost:8000';

  String? _authToken;

  Future<void> _saveToken(String token) async {
    _authToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token');
  }

  Map<String, String> _headers({Map<String, String>? extra}) {
    final h = <String, String>{'Accept': 'application/json'};
    if (_authToken != null && _authToken!.isNotEmpty) {
      h['Cookie'] = 'auth_token=$_authToken';
      h['Authorization'] = 'Token $_authToken';
    }
    if (extra != null) h.addAll(extra);
    return h;
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final resp = await http.post(
      Uri.parse('\${baseUrl}/api/auth/login/'),
      headers: _headers(),
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (resp.statusCode == 200) {
      // read auth_token cookie from Set-Cookie header
      final setCookie = resp.headers['set-cookie'];
      if (setCookie != null) {
        final match = RegExp(r'auth_token=([^;]+)').firstMatch(setCookie);
        if (match != null) {
          await _saveToken(match.group(1)!);
        }
      }
      return jsonDecode(resp.body) as Map<String, dynamic>;
    }
    throw Exception('Login failed: \\${resp.statusCode}');
  }

  Future<void> logout() async {
    final resp = await http.post(
      Uri.parse('\${baseUrl}/api/auth/logout/'),
      headers: _headers(),
    );
    if (resp.statusCode == 200) {
      _authToken = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
    } else {
      throw Exception('Logout failed');
    }
  }

  Future<Map<String, dynamic>> getUser() async {
    final resp = await http.get(
      Uri.parse('\${baseUrl}/api/auth/user/'),
      headers: _headers(),
    );
    if (resp.statusCode == 200)
      return jsonDecode(resp.body) as Map<String, dynamic>;
    throw Exception('Failed to get user');
  }

  Future<Map<String, dynamic>> getReports({
    int page = 1,
    String? search,
    String? ordering,
    Map<String, String>? filters,
  }) async {
    final params = <String, String>{'page': page.toString()};
    if (search != null) params['search'] = search;
    if (ordering != null) params['ordering'] = ordering;
    if (filters != null) params.addAll(filters);
    final uri = Uri.parse(
      '\${baseUrl}/api/reports/',
    ).replace(queryParameters: params);
    final resp = await http.get(uri, headers: _headers());
    if (resp.statusCode == 200)
      return jsonDecode(resp.body) as Map<String, dynamic>;
    throw Exception('Failed to list reports');
  }

  Future<Map<String, dynamic>> getReport(String id) async {
    final resp = await http.get(
      Uri.parse('\${baseUrl}/api/reports/\$id/'),
      headers: _headers(),
    );
    if (resp.statusCode == 200)
      return jsonDecode(resp.body) as Map<String, dynamic>;
    throw Exception('Failed to get report');
  }

  Future<Map<String, dynamic>> createReport(Map<String, dynamic> data) async {
    final resp = await http.post(
      Uri.parse('\${baseUrl}/api/reports/'),
      headers: _headers(),//{'Content-Type': 'application/json'}),
      body: jsonEncode(data),
    );
    if (resp.statusCode == 201)
      return jsonDecode(resp.body) as Map<String, dynamic>;
    throw Exception('Failed to create report');
  }

  Future<Map<String, dynamic>> updateReport(
    String id,
    Map<String, dynamic> data,
  ) async {
    final resp = await http.put(
      Uri.parse('\${baseUrl}/api/reports/\$id/'),
      headers: _headers(),//{'Content-Type': 'application/json'}),
      body: jsonEncode(data),
    );
    if (resp.statusCode == 200)
      return jsonDecode(resp.body) as Map<String, dynamic>;
    throw Exception('Failed to update report: \\${resp.body}');
  }

  Future<void> deleteReport(String id) async {
    final resp = await http.delete(
      Uri.parse('\${baseUrl}/api/reports/\$id/'),
      headers: _headers(),
    );
    if (resp.statusCode == 204) return;
    throw Exception('Failed to delete report');
  }
}
