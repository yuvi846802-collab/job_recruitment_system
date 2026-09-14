import 'dart:convert';
import 'package:http/http.dart' as http;
import 'storage_service.dart';

class ApiService {
  static Future<Map<String, String>> _getHeaders() async {
    final token = await StorageService.getToken();
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Future<dynamic> get(String url) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse(url), headers: headers);
      return _handleResponse(response);
    } catch (e) {
      if (e is Exception && e.toString().startsWith('Exception: ')) {
        rethrow;
      }
      throw Exception('Network connection error: Unable to connect to server.');
    }
  }

  static Future<dynamic> post(String url, Map<String, dynamic> body) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      if (e is Exception && e.toString().startsWith('Exception: ')) {
        rethrow;
      }
      throw Exception('Network connection error: Unable to connect to server.');
    }
  }

  static Future<dynamic> put(String url, Map<String, dynamic> body) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      if (e is Exception && e.toString().startsWith('Exception: ')) {
        rethrow;
      }
      throw Exception('Network connection error: Unable to connect to server.');
    }
  }

  static Future<dynamic> patch(String url, [Map<String, dynamic>? body]) async {
    try {
      final headers = await _getHeaders();
      final response = await http.patch(
        Uri.parse(url),
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      if (e is Exception && e.toString().startsWith('Exception: ')) {
        rethrow;
      }
      throw Exception('Network connection error: Unable to connect to server.');
    }
  }

  static Future<dynamic> delete(String url) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(Uri.parse(url), headers: headers);
      return _handleResponse(response);
    } catch (e) {
      if (e is Exception && e.toString().startsWith('Exception: ')) {
        rethrow;
      }
      throw Exception('Network connection error: Unable to connect to server.');
    }
  }

  static dynamic _handleResponse(http.Response response) {
    Map<String, dynamic> body = {};
    try {
      body = jsonDecode(response.body);
    } catch (_) {
      body = {'message': response.body};
    }

    if (response.statusCode == 401) {
      StorageService.clearSession();
      final String message = body['message'] ?? 'Session expired. Please log in again.';
      throw Exception(message);
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    } else {
      final String message = body['message'] ?? 'An error occurred. Please try again.';
      throw Exception(message);
    }
  }
}
