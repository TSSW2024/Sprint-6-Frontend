import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';

class AuthService {
  final String baseURL = "https://backend-auth.tssw.cl";
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final Logger _logger = Logger();

  Future<Map<String, dynamic>?> googleLogin() async {
    try {
      _logger.i("Iniciando el flujo de inicio de sesión de Google");
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        _logger.i("Inicio de sesión cancelado por el usuario");
        return null;
      }

      _logger.i("GoogleUser obtenido, obteniendo autenticación");
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      _logger.i("ID Token: ${googleAuth.idToken}");
      _logger.i("Access Token: ${googleAuth.accessToken}");

      if (googleAuth.idToken == null) {
        _logger.i("ID Token es null");
        return null;
      }

      //ahora acceder con las credenciales de google al usuario de firebase con la sdk de firebase para obtener el idtoken de firebase
      // y pasarlo al backend en el hader de la autorizacion a validate token para obtener el usuario si eso se peude hacer se significa que existe el usuario debe devolver el token si no es un error
      final firebaseUserCredential =
          await FirebaseAuth.instance.signInWithCredential(
        GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
          accessToken: googleAuth.accessToken,
        ),
      );

      // devolver el token de firebase

      return {
        "token": await firebaseUserCredential.user!.getIdToken(),
      };
    } catch (e) {
      _logger.i("Error al iniciar sesión con Google: $e");
      return null;
    }
  }

  Future<void> signOutFromGoogle() async {
    await _googleSignIn.signOut();
    await logout(); // También cierra sesión en tu backend
  }

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
