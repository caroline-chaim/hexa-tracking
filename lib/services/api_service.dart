import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  //static const String _baseUrl = 'http://localhost:3000';
  static const String _baseUrl = 'hexa-tracker-server.azurewebsites.net';

  static Future<http.Response> get(String endpoint) async {
    final response = await http.get(Uri.parse('$_baseUrl$endpoint'));
    return response;
  }

  static Future<Map<String, String>> getGameDetails(String id) async {
    final response = await get('/api/bgg/thing/$id');
    final data = jsonDecode(response.body);
    return {
      'name': data['name'],
      'image': data['image'],
      'thumbnail': data['thumbnail'],
    };
  }

  static String proxyImage(String imageUrl) {
    final encoded = Uri.encodeComponent(imageUrl);
    return '$_baseUrl/api/bgg/image?url=$encoded';
  }

static Future<List<Map<String, String>>> getHotGames() async {
  final response = await get('/api/bgg/hot');
  final List data = jsonDecode(response.body);
  return data.map<Map<String, String>>((g) => {
    'id': g['id'],
    'name': g['name'],
    'image': g['thumbnail'], // usa thumbnail direto
  }).toList();
}
  static Future<List<Map<String, String>>> getRankedGames(int page) async {
    final response = await get('/api/bgg/ranked?page=$page');
    final List data = jsonDecode(response.body);
    return data.map<Map<String, String>>((g) => {
      'id': g['id'],
      'name': g['name'],
      'image': g['image'] ?? g['thumbnail'] ?? '',
    }).toList();
  }


 static Future<List<Map<String, String>>> searchGames(String query) async {
  final encoded = Uri.encodeComponent(query);
  final response = await get('/api/bgg/search?query=$encoded');
  final List data = jsonDecode(response.body);
  return data.map<Map<String, String>>((g) => {
    'id': g['id'],
    'name': g['name'],
    'image': g['thumbnail'] ?? '',
  }).toList();
} 
} 

