import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sport_rent/models/empresa_model.dart';
import 'package:sport_rent/services/empresa_service.dart';
import 'package:sport_rent/services/usuario_service.dart';

class EmpresaController extends GetxController {
  final _empresaService = EmpresaService();
  final _usuarioService = UsuarioService();

  final Rx<Empresa?> empresa = Rx<Empresa?>(null);
  final RxList<Empresa> todasEmpresas = <Empresa>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  String get nombreEmpresa => empresa.value?.nombreEmpresa ?? '';
  String get nit => empresa.value?.nit ?? '';
  bool get estaVerificada => empresa.value?.verificada ?? false;

  Future<void> cargarEmpresa(String empresaId) async {
    try {
      isLoading.value = true;
      error.value = '';

      empresa.value = await _empresaService.obtenerEmpresa(empresaId);
    } catch (e) {
      error.value = 'Error al cargar la empresa';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> cargarTodasEmpresas() async {
    try {
      isLoading.value = true;
      error.value = '';

      todasEmpresas.assignAll(await _empresaService.obtenerTodas());
    } catch (e) {
      error.value = 'Error al cargar las empresas';
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> registrarEmpresa({
    required String empresaId,
    required String usuarioId,
    required String nombreEmpresa,
    required String nit,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';

      final nuevaEmpresa = Empresa(
        id: empresaId,
        usuarioId: usuarioId,
        nombreEmpresa: nombreEmpresa,
        nit: nit,
      );

      await _empresaService.crearEmpresa(nuevaEmpresa);
      empresa.value = nuevaEmpresa;
      return true;
    } catch (e) {
      error.value = 'Error al registrar la empresa';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> actualizarEmpresa({
    required String nombre,
    required String nit,
  }) async {
    if (nombre.isEmpty || nit.isEmpty) {
      error.value = 'Nombre y NIT son requeridos';
      return false;
    }

    final e = empresa.value;
    if (e == null) return false;

    try {
      isLoading.value = true;
      error.value = '';

      await _empresaService.actualizarEmpresa(e.id, {
        'nombreEmpresa': nombre,
        'nit': nit,
      });

      empresa.value = Empresa(
        id: e.id,
        usuarioId: e.usuarioId,
        nombreEmpresa: nombre,
        nit: nit,
        verificada: e.verificada,
        fechaRegistro: e.fechaRegistro,
      );

      Get.snackbar('Empresa actualizada', 'Los datos fueron guardados',
          backgroundColor: Colors.green[100], colorText: Colors.black87);
      return true;
    } catch (e) {
      error.value = 'Error al actualizar la empresa';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> verificarEmpresa(String empresaId) async {
    try {
      isLoading.value = true;
      error.value = '';

      await _empresaService.actualizarEmpresa(empresaId, {'verificada': true});

      final index = todasEmpresas.indexWhere((e) => e.id == empresaId);
      if (index != -1) {
        final e = todasEmpresas[index];
        todasEmpresas[index] = Empresa(
          id: e.id,
          usuarioId: e.usuarioId,
          nombreEmpresa: e.nombreEmpresa,
          nit: e.nit,
          verificada: true,
          fechaRegistro: e.fechaRegistro,
        );
      }

      if (empresa.value?.id == empresaId) {
        final current = empresa.value!;
        empresa.value = Empresa(
          id: current.id,
          usuarioId: current.usuarioId,
          nombreEmpresa: current.nombreEmpresa,
          nit: current.nit,
          verificada: true,
          fechaRegistro: current.fechaRegistro,
        );
      }

      Get.snackbar('Empresa verificada', 'La empresa fue aprobada',
          backgroundColor: Colors.green[100], colorText: Colors.black87);
      return true;
    } catch (e) {
      error.value = 'Error al verificar la empresa';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> rechazarEmpresa(String empresaId) async {
    try {
      isLoading.value = true;
      error.value = '';

      Empresa? empresaAEliminar;
      final index = todasEmpresas.indexWhere((e) => e.id == empresaId);
      if (index != -1) {
        empresaAEliminar = todasEmpresas[index];
      } else if (empresa.value?.id == empresaId) {
        empresaAEliminar = empresa.value;
      } else {
        empresaAEliminar = await _empresaService.obtenerEmpresa(empresaId);
      }

      if (empresaAEliminar != null && empresaAEliminar.usuarioId.isNotEmpty) {
        try {
          await _usuarioService.eliminarUsuario(empresaAEliminar.usuarioId);
        } catch (e) {
          debugPrint('Error eliminando usuario asociado: $e');
        }
      }

      await _empresaService.eliminarEmpresa(empresaId);
      todasEmpresas.removeWhere((e) => e.id == empresaId);
      if (empresa.value?.id == empresaId) {
        empresa.value = null;
      }

      Get.snackbar('Empresa rechazada', 'La empresa y su usuario asociado fueron eliminados',
          backgroundColor: Colors.red[50], colorText: Colors.red[700]);
      return true;
    } catch (e) {
      error.value = 'Error al rechazar la empresa';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void limpiarError() => error.value = '';
}
