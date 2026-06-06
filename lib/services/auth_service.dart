import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _baseUrl = 'https://hexa-tracker-server.azurewebsites.net';
  //  static const String _baseUrl = 'http://localhost:3000';
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';

  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '944989699683-0nk6j0e2tn4p4b1de9mvjusciblv5qtc.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );

static Future<Map<String, dynamic>?> signInWithGoogle() async {
  try {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;
    
    // No Flutter Web vem access_token em vez de idToken
    final token = googleAuth.idToken ?? googleAuth.accessToken;
    if (token == null) throw Exception('Não foi possível obter o token do Google');

    final response = await http.post(
      Uri.parse('$_baseUrl/auth/google'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'idToken': token}),
    );

    if (response.statusCode != 200) {
      throw Exception('Erro no servidor: ${response.body}');
    }

    final data = jsonDecode(response.body);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, data['token']);
    await prefs.setString(_userKey, jsonEncode(data['user']));

    return data['user'];
  } catch (e) {
    print('Erro no login: $e');
    return null;
  }
}

  // Recupera o token salvo (para usar nas requisições)
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Recupera os dados do usuário salvos
  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString(_userKey);
    if (userStr == null) return null;
    return jsonDecode(userStr);
  }

  // Verifica se há sessão ativa
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  // Logout
  static Future<void> signOut() async {
    await _googleSignIn.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }
}