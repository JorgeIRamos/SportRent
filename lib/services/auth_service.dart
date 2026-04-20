import 'package:sport_rent/models/usuario_model.dart';

class AuthService {
  // Simula la sesión activa. Reemplazar con Firebase Auth.
  static Usuario? _usuarioActual;

  static Usuario? get usuarioActual => _usuarioActual;

  Future<Usuario> login(String email, String password) async {
    await Future.delayed(Duration(milliseconds: 800));

    // Mock: detecta rol por email para pruebas
    final rol = email.contains('admin')
        ? 'admin'
        : email.contains('empresa')
            ? 'empresa'
            : 'cliente';

    final usuario = Usuario(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      nombre: rol == 'admin' ? 'Administrador' : rol == 'empresa' ? 'Mi Empresa' : 'Jorge Ramos',
      email: email,
      telefono: '3001234567',
      rol: rol,
      empresaId: rol == 'empresa' ? 'emp_001' : null,
    );

    _usuarioActual = usuario;
    return usuario;
  }

  Future<Usuario> register({
    required String nombre,
    required String email,
    required String password,
    required String telefono,
    String rol = 'cliente',
  }) async {
    await Future.delayed(Duration(milliseconds: 800));

    final usuario = Usuario(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      nombre: nombre,
      email: email,
      telefono: telefono,
      rol: rol,
    );

    _usuarioActual = usuario;
    return usuario;
  }

  Future<void> logout() async {
    await Future.delayed(Duration(milliseconds: 300));
    _usuarioActual = null;
  }

  Future<bool> isSessionActive() async {
    return _usuarioActual != null;
  }
}
