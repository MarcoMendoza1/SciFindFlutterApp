import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const _loginUrl = 'api/Authentication/Login';
  static const baseUrl = 'http://localhost:5003/';

  static Future<bool> login(String email, String password) async {
    final body = {
      "Id": 0,
      "name": "",
      "TelephoneNumber": "",
      "Address": "",
      "email": email,
      "password": password,
      "role": "Normal"
    };

    final response = await http.post(
      Uri.parse(baseUrl + _loginUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final token = response.body.replaceAll('"', '');

      if (JwtDecoder.isExpired(token)) {
        return false;
      }

      final decoded = JwtDecoder.decode(token);
      final user = {
        "id": decoded["UserId"] ?? null,
        "name": decoded["http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name"] ?? "Usuario",
        "email": decoded["http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress"] ?? "Sin correo",
        "role": decoded["http://schemas.microsoft.com/ws/2008/06/identity/claims/role"] ?? "Normal"
      };

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", token);
      await prefs.setString("user", jsonEncode(user));
      return true;
    }

    return false;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
    await prefs.remove("user");
  }

  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    final user = prefs.getString("user");

    if (token != null && !JwtDecoder.isExpired(token)) {
      return jsonDecode(user!);
    }

    return null;
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    return token != null && !JwtDecoder.isExpired(token);
  }

  static Future<bool> updateUserProfile({
    required String id,
    required String name,
    required String phone,
    required String address,
    required String email,
  }) async {
    final url = Uri.parse('${baseUrl}api/authentication');

    final body = {
      "id": id,
      "name": name,
      "telephoneNumber": phone,
      "address": address,
      "email": email,
      "role": "Normal"
    };

    final response = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['flag'] == true;
    }

    return false;
  }

}
