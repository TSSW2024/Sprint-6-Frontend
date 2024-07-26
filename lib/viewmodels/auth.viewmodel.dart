import 'dart:convert';
import 'dart:io';
import 'package:ejemplo_1/models/users_model.dart';
import 'package:ejemplo_1/services/crud_monedero_service.dart';
import 'package:ejemplo_1/services/crud_usuario_services.dart';
import 'package:ejemplo_1/services/profile_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth.service.dart';
import 'package:logger/logger.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService;

  AuthViewModel(this._authService) {
    _isLoading = false;
    _loadToken();
  }

  late bool _isLoading;
  String? _errorMessage;

  UserModel? _user;
  String? _token;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserModel? get user => _user;
  bool get isAuthenticated => _token != null && _user != null;

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString('token');

    if (storedToken != null) {
      _token = storedToken;
      await validateToken();
    }
  }

  Future<void> updateUserProfile({String? displayName, File? photo}) async {
    _startLoading();
    notifyListeners();

    final profileService = ProfileService(_token!);

    bool success = await profileService.updateUserProfile(
        displayName: displayName, photo: photo);

    if (success) {
      // Fetch the updated user profile
      // Suponiendo que tienes un método para obtener el perfil actualizado del usuario
      await validateToken();
    }

    _stopLoading();
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _startLoading();
    try {
      final data = await _authService.login(email, password);
      if (data != null) {
        _token = data["token"];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", _token!);

        _errorMessage = null;

        // Validar el token para obtener información del usuario
        await validateToken();

        // Verificar si el usuario ya existe antes de intentar agregarlo
        if (_user != null) {
          final userExists =
              await CrudServicesAgregarUsuario().doesUserExist(_user!.uid);
          if (!userExists) {
            await CrudServicesAgregarUsuario().postUser(_user!);
          }

          final Monedero? monedero =
              await MonederoService().createOrUpdateMonedero(_user!);

          if (monedero != null) {
            Logger().i('Monedero creado o actualizado exitosamente');

            // Obtener monedero a través del usuario
            final Monedero? fetchedMonedero =
                await MonederoService().getMonedero(_user!);

            if (fetchedMonedero != null) {
              Logger().i('Monedero obtenido exitosamente $fetchedMonedero');
            } else {
              Logger().e('Error al obtener monedero');
            }
          } else {
            Logger().e('Error al crear o actualizar monedero');
          }
        }
      } else {
        _errorMessage = "Credenciales incorrectas";
      }
    } catch (e) {
      _errorMessage = "Error al iniciar sesión";
    } finally {
      _stopLoading();
    }
  }

  Future<void> register(String email, String password) async {
    _startLoading();
    try {
      final data = await _authService.register(email, password);
      if (data != null) {
        _token = data["token"];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", _token!);

        Logger().i('Token almacenado $_token');

        _errorMessage = "Usuario registrado";

        // Validar el token para obtener información del usuario
        await validateToken();

        if (_user != null) {
          Logger().i('Usuario $_user');
          await CrudServicesAgregarUsuario().postUser(_user!);

          final Monedero? monedero =
              await MonederoService().createOrUpdateMonedero(_user!);

          if (monedero != null) {
            Logger().i('Monedero creado o actualizado exitosamente');
          } else {
            Logger().e('Error al crear o actualizar monedero');
          }
        }
      } else {
        _errorMessage = "Error al registrar usuario";
      }
    } catch (e) {
      _errorMessage = "Error al registrar usuario $e";
    } finally {
      _stopLoading();
    }
  }

  Future<void> signOut() async {
    _startLoading();
    try {
      await _authService.logout();

      _user = null;
      _token = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove("token");
      await prefs.remove("user");
      _errorMessage = null;
    } catch (e) {
      _errorMessage = "Error al cerrar sesión";
    } finally {
      _stopLoading();
    }
  }

  Future<void> validateToken() async {
    _startLoading();
    try {
      if (_token != null) {
        final data = await _authService.validateToken(_token!);
        if (data != null) {
          _user = UserModel.fromMap({
            "displayName": data["displayName"],
            "email": data["email"],
            "uid": data["uid"],
            "verified": data["emailVerified"],
            "role": data["role"],
            "photoURL": data["photoURL"],
          });

          if (_user!.photoURL.isEmpty) {
            _user!.photoURL =
                'https://ui-avatars.com/api/?name=${_user!.displayName}&background=random&color=fff';
          }
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString("user", jsonEncode(_user!.toMap()));
          _errorMessage = null;
        } else {
          _errorMessage = "Token inválido";
          await _authService.logout();
        }
      }
    } catch (e) {
      _errorMessage = "Error al validar token $e";
    } finally {
      _stopLoading();
    }
  }

  Future<void> forgotPassword(String email) async {
    _startLoading();
    try {
      await _authService.forgotPassword(email);
      _errorMessage = "Correo de recuperación enviado";
    } catch (e) {
      _errorMessage = "Error al enviar correo de recuperación";
    } finally {
      _stopLoading();
    }
  }

  void _startLoading() {
    _isLoading = true;
    notifyListeners();
  }

  void _stopLoading() {
    _isLoading = false;
    notifyListeners();
  }

  void clearErrorMessage() {
    _errorMessage = null;
  }
}
