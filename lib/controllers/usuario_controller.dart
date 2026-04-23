import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sport_rent/models/usuario_model.dart';
import 'package:sport_rent/services/auth_service.dart';
import 'package:sport_rent/services/usuario_service.dart';

class UsuarioController extends GetxController {
  final _usuarioService = UsuarioService();
  final _authService = AuthService();

  final Rx<Usuario?> usuario = Rx<Usuario?>(null);
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  Future<void> cargarUsuario(String usuarioId) async {
    try {
      isLoading.value = true;
      error.value = '';

      usuario.value = await _usuarioService.obtenerUsuario(usuarioId);
    } catch (e) {
      error.value = 'No se pudo cargar el perfil';
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> actualizarPerfil({
    required String nombre,
    required String telefono,
  }) async {
    if (nombre.isEmpty || telefono.isEmpty) {
      error.value = 'Nombre y teléfono son requeridos';
      return false;
    }

    final u = usuario.value;
    if (u == null) return false;

    try {
      isLoading.value = true;
      error.value = '';

      await _usuarioService.actualizarUsuario(u.id, {
        'nombre': nombre,
        'telefono': telefono,
      });

      usuario.value = Usuario(
        id: u.id,
        nombre: nombre,
        email: u.email,
        telefono: telefono,
        rol: u.rol,
        empresaId: u.empresaId,
        activo: u.activo,
        fechaRegistro: u.fechaRegistro,
      );

      Get.snackbar('Perfil actualizado', 'Tus datos fueron guardados',
          backgroundColor: Colors.green[100], colorText: Colors.black87);
      return true;
    } catch (e) {
      error.value = 'Error al actualizar el perfil';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> cambiarPassword({
    required String passwordActual,
    required String passwordNuevo,
  }) async {
    if (passwordActual.isEmpty || passwordNuevo.isEmpty) {
      error.value = 'Completa ambos campos';
      return false;
    }

    if (passwordNuevo.length < 6) {
      error.value = 'La nueva contraseña debe tener al menos 6 caracteres';
      return false;
    }

    final u = usuario.value;
    if (u == null) return false;

    try {
      isLoading.value = true;
      error.value = '';

      await _authService.cambiarPassword(
        emailActual: u.email,
        passwordActual: passwordActual,
        passwordNuevo: passwordNuevo,
      );

      Get.snackbar('Contraseña actualizada', 'Tu contraseña fue cambiada exitosamente',
          backgroundColor: Colors.green[100], colorText: Colors.black87);
      return true;
    } catch (e) {
      error.value = 'Contraseña actual incorrecta';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void limpiarError() => error.value = '';
}
