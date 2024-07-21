import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';

class AuthService {
  final String baseURL = "https://backend-auth.tssw.cl";

  Future<Map<String, dynamic>?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseURL/login"),
      headers: {"Content-Type": "application/json; charset=UTF-8"},
      body: jsonEncode({"email": email, "password": password}),
    );
    //Logger().i(response.body);
    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      return result["data"];
    } else {
      return null;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
    await prefs.remove("user");
  }

  Future<Map<String, dynamic>?> register(String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseURL/register"),
      headers: {"Content-Type": "application/json; charset=UTF-8"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      return result["data"];
    } else {
      return null;
    }
  }

  Future<Map<String, dynamic>?> validateToken(String token) async {
    final response = await http.get(
      Uri.parse("$baseURL/validate-token"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      return result["data"];
    } else {
      return null;
    }
  }

  Future<void> forgotPassword(String email) async {
    final response = await http.post(
      Uri.parse("$baseURL/forgot-password"),
      headers: {"Content-Type": "application/json; charset=UTF-8"},
      body: jsonEncode({"email": email}),
    );

    if (response.statusCode != 200) {
      throw Exception("Error al enviar el correo");
    }
  }
}
