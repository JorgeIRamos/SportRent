import 'package:get/get.dart';
import 'package:sport_rent/controllers/empresa_controller.dart';
import 'package:sport_rent/models/usuario_model.dart';
import 'package:sport_rent/services/auth_service.dart';

class AuthController extends GetxController {
  final _authService = AuthService();

  final Rx<Usuario?> usuario = Rx<Usuario?>(null);
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  bool get isLoggedIn => usuario.value != null;
  String get rol => usuario.value?.rol ?? '';
  String get nombre => usuario.value?.nombre ?? '';
  String get email => usuario.value?.email ?? '';
  String get empresaId => usuario.value?.empresaId ?? '';

  @override
  void onInit() {
    super.onInit();
    _verificarSesion();
  }

  Future<void> _verificarSesion() async {
    final activa = await _authService.isSessionActive();
    if (activa) {
      usuario.value = _authService.usuarioActual;
    }
  }

  Future<void> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      error.value = 'Completa todos los campos';
      return;
    }

    try {
      isLoading.value = true;
      error.value = '';

      final u = await _authService.login(email, password);
      usuario.value = u;

      _redirigirSegunRol(u.rol);
    } catch (e) {
      error.value = 'Correo o contraseña incorrectos';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register({
    required String nombre,
    required String email,
    required String password,
    required String telefono,
    String rol = 'cliente',
    String? nombreEmpresa,
    String? nit,
  }) async {
    if (nombre.isEmpty || email.isEmpty || password.isEmpty || telefono.isEmpty) {
      error.value = 'Completa todos los campos';
      return;
    }

    if (!email.contains('@')) {
      error.value = 'Ingresa un correo válido';
      return;
    }

    if (password.length < 6) {
      error.value = 'La contraseña debe tener al menos 6 caracteres';
      return;
    }

    if (rol == 'empresa' && (nombreEmpresa == null || nombreEmpresa.isEmpty || nit == null || nit.isEmpty)) {
      error.value = 'Ingresa el nombre de la empresa y el NIT';
      return;
    }

    try {
      isLoading.value = true;
      error.value = '';

      final u = await _authService.register(
        nombre: nombre,
        email: email,
        password: password,
        telefono: telefono,
        rol: rol,
      );
      usuario.value = u;

      if (rol == 'empresa') {
        await Get.find<EmpresaController>().registrarEmpresa(
          empresaId: u.empresaId!,
          usuarioId: u.id,
          nombreEmpresa: nombreEmpresa!,
          nit: nit!,
        );
      }

      _redirigirSegunRol(u.rol);
    } catch (e) {
      error.value = 'Error al registrarse. Intenta de nuevo.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;
      await _authService.logout();
      usuario.value = null;
      Get.offAllNamed('/home');
    } catch (e) {
      error.value = 'Error al cerrar sesión';
    } finally {
      isLoading.value = false;
    }
  }

  void limpiarError() => error.value = '';

  void _redirigirSegunRol(String rol) {
    switch (rol) {
      case 'admin':
        Get.offAllNamed('/home-admin');
        break;
      case 'empresa':
        Get.offAllNamed('/home-empresa');
        break;
      default:
        Get.offAllNamed('/home-usuario');
    }
  }
}
