import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class FriendService {
  static const String _baseUrl = 'https://hexa-tracker-server.azurewebsites.net';
  //static const String _baseUrl = 'http://localhost:3000';

  static Future<Map<String, String>> _authHeaders() async {
    final token = await AuthService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<String?> sendRequest(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/friends/request'),
        headers: await _authHeaders(),
        body: jsonEncode({'email': email}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 201) return null; // sucesso
      return data['error'] ?? 'Erro desconhecido';
    } catch (_) {
      return 'Erro de conexão';
    }
  }

  static Future<List<Map<String, dynamic>>> getPendingRequests() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/friends/requests'),
        headers: await _authHeaders(),
      );
      if (response.statusCode != 200) return [];
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  static Future<bool> acceptRequest(String fromUserId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/friends/accept/$fromUserId'),
        headers: await _authHeaders(),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> declineRequest(String fromUserId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/friends/decline/$fromUserId'),
        headers: await _authHeaders(),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> getFriends() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/friends'),
        headers: await _authHeaders(),
      );
      if (response.statusCode != 200) return [];
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  static Future<bool> removeFriend(String friendId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/friends/$friendId'),
        headers: await _authHeaders(),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> getFriendLibrary(String friendId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/friends/$friendId/library'),
        headers: await _authHeaders(),
      );
      if (response.statusCode != 200) return [];
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getFriendStats(String friendId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/friends/$friendId/stats'),
        headers: await _authHeaders(),
      );
      if (response.statusCode != 200) return [];
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }
}