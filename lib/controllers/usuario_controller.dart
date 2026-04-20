import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sport_rent/models/usuario_model.dart';

class UsuarioController extends GetxController {
  final Rx<Usuario?> usuario = Rx<Usuario?>(null);
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxSet<String> favoritos = <String>{}.obs;

  bool esFavorita(String canchaId) => favoritos.contains(canchaId);
  int get totalFavoritos => favoritos.length;

  Future<void> cargarUsuario(String usuarioId) async {
    try {
      isLoading.value = true;
      error.value = '';
      await Future.delayed(Duration(milliseconds: 500));

      // Mock: reemplazar con consulta real al servicio
      usuario.value = Usuario(
        id: usuarioId,
        nombre: 'Jorge Ramos',
        email: 'jorge@email.com',
        telefono: '3001234567',
        rol: 'cliente',
      );
    } catch (e) {
      error.value = 'No se pudo cargar el perfil';
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> actualizarPerfil({
    required String nombre,
    required String telefono,
    String? email,
  }) async {
    if (nombre.isEmpty || telefono.isEmpty) {
      error.value = 'Nombre y teléfono son requeridos';
      return false;
    }

    try {
      isLoading.value = true;
      error.value = '';
      await Future.delayed(Duration(milliseconds: 500));

      if (usuario.value != null) {
        usuario.value = Usuario(
          id: usuario.value!.id,
          nombre: nombre,
          email: email ?? usuario.value!.email,
          telefono: telefono,
          rol: usuario.value!.rol,
          empresaId: usuario.value!.empresaId,
        );
      }

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

    try {
      isLoading.value = true;
      error.value = '';
      await Future.delayed(Duration(milliseconds: 500));

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

  void toggleFavorito(String canchaId) {
    if (favoritos.contains(canchaId)) {
      favoritos.remove(canchaId);
    } else {
      favoritos.add(canchaId);
    }
  }

  void limpiarError() => error.value = '';
}
