import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class LibraryService {
  static const String _baseUrl = 'https://hexatracker.azurewebsites.net';
  //static const String _baseUrl = 'http://localhost:3000';

  static Future<Map<String, String>> _authHeaders() async {
    final token = await AuthService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<List<Map<String, String>>> getLibrary() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/library'),
        headers: await _authHeaders(),
      );
      if (response.statusCode != 200) return [];
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Map<String, String>.from(e)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<bool> isInLibrary(String gameId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/library/$gameId/check'),
        headers: await _authHeaders(),
      );
      if (response.statusCode != 200) return false;
      final data = jsonDecode(response.body);
      return data['inLibrary'] == true;
    } catch (_) {
      return false;
    }
  }

  static Future<void> addGame(Map<String, String> game) async {
    try {
      await http.post(
        Uri.parse('$_baseUrl/library'),
        headers: await _authHeaders(),
        body: jsonEncode(game),
      );
    } catch (_) {}
  }

  static Future<void> removeGame(String gameId) async {
    try {
      await http.delete(
        Uri.parse('$_baseUrl/library/$gameId'),
        headers: await _authHeaders(),
      );
    } catch (_) {}
  }
}