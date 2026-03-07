import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:HamroGharSewa/constants/api_constants.dart';
import 'package:HamroGharSewa/services/token_manager.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  final String _baseUrl = ApiConstants.baseUrl; 

  Map<String, String> _getHeaders(String? token) {
    // Clean token if present
    String? cleanToken;
    if (token != null && token.isNotEmpty) {
      cleanToken = token.trim().replaceAll('"', '').replaceAll('\n', '').replaceAll('\r', '');
      
      // Debug logging
      print('🔑 Token length: ${cleanToken.length}');
      print('🔑 Token parts: ${cleanToken.split('.').length}');
      print('🔑 Token preview: ${cleanToken.substring(0, cleanToken.length > 50 ? 50 : cleanToken.length)}...');
    }
    
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (cleanToken != null && cleanToken.isNotEmpty) 'Authorization': 'Bearer $cleanToken',
    };
  }

  Future<http.Response> get(String endpoint, {bool requireAuth = true}) async {
    final token = requireAuth ? await TokenManager().getAccessToken() : null;
    final url = Uri.parse('$_baseUrl$endpoint');
    return await http.get(url, headers: _getHeaders(token));
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic>? body) async {
    final token = await TokenManager().getAccessToken();
    final url = Uri.parse('$_baseUrl$endpoint');
    return await http.post(
      url,
      headers: _getHeaders(token),
      body: body != null ? json.encode(body) : null,
    );
  }


  Future<http.Response> patch(String endpoint, Map<String, dynamic>? body) async {
    final token = await TokenManager().getAccessToken();
    final url = Uri.parse('$_baseUrl$endpoint');
    return await http.patch(
      url,
      headers: _getHeaders(token),
      body: body != null ? json.encode(body) : json.encode({}), // sends '{}'
    );
  }
  Future<http.Response> delete(String endpoint) async {
    final token = await TokenManager().getAccessToken();
    final url = Uri.parse('$_baseUrl$endpoint');
    return await http.delete(url, headers: _getHeaders(token));
  }
  Future<http.Response> put(String endpoint, Map<String, dynamic>? body) async {
    final token = await TokenManager().getAccessToken();
    final url = Uri.parse('$_baseUrl$endpoint');
    return await http.put(
      url,
      headers: _getHeaders(token),
      body: body != null ? json.encode(body) : null,
    );
  }
}