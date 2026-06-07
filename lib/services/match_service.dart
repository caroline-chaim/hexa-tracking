import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class MatchService {
  static const String _baseUrl = 'https://hexa-tracker-server.azurewebsites.net';
  //static const String _baseUrl = 'http://localhost:3000';

  static Future<Map<String, String>> _authHeaders() async {
    final token = await AuthService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<bool> saveMatch({
    required String gameId,
    required String gameName,
    required String gameThumbnail,
    required int durationSeconds,
    required String result, // 'win' ou 'loss'
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/matches'),
        headers: await _authHeaders(),
        body: jsonEncode({
          'gameId': gameId,
          'gameName': gameName,
          'gameThumbnail': gameThumbnail,
          'durationSeconds': durationSeconds,
          'result': result,
        }),
      );
      return response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> getMonthMatches() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/matches/month'),
        headers: await _authHeaders(),
      );
      if (response.statusCode != 200) return [];
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getAllMatches() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/matches'),
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