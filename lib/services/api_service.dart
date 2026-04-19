import 'package:http/http.dart' as http;

class ApiService {
//static const String _baseUrl = 'http://localhost:3000';
static const String _baseUrl = 'https://hexa-tracker-server.azurewebsites.net';

static Future<http.Response> get(String endpoint) async {
  final response = await http.get(
    Uri.parse('$_baseUrl$endpoint'),
  );
  return response;
}

static String imagemUrl(String url) {
  return 'https://hexa-tracker-server.azurewebsites.net/imagem?url=${Uri.encodeComponent(url)}';
}

}