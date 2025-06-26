
import 'package:flutter/material.dart';
import 'auth_service.dart'; // importa tu clase

class SesionModel with ChangeNotifier {
  bool _autenticado = false;
  Map<String, dynamic>? _usuario;

  bool get estaAutenticado => _autenticado;
  Map<String, dynamic>? get usuario => _usuario;

  Future<void> verificarSesion() async {
    _autenticado = await AuthService.isLoggedIn();
    if (_autenticado) {
      _usuario = await AuthService.getUser();
    }
    notifyListeners();
  }

  Future<bool> iniciarSesion(String email, String password) async {
    final ok = await AuthService.login(email, password);
    if (ok) {
      _usuario = await AuthService.getUser();
      _autenticado = true;
      notifyListeners();
    }
    return ok;
  }

  Future<void> cerrarSesion() async {
    await AuthService.logout();
    _usuario = null;
    _autenticado = false;
    notifyListeners();
  }
}
