import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sport_rent/models/anuncio_model.dart';
import 'package:sport_rent/services/anuncio_service.dart';

class AnuncioController extends GetxController {
  final _anuncioService = AnuncioService();

  final RxList<Anuncio> anuncios = <Anuncio>[].obs;
  final RxList<Anuncio> anunciosActivos = <Anuncio>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  Future<void> cargarPorEmpresa(String empresaId) async {
    try {
      isLoading.value = true;
      error.value = '';

      anuncios.assignAll(await _anuncioService.obtenerPorEmpresa(empresaId));
    } catch (e) {
      error.value = 'Error al cargar anuncios';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> cargarActivos() async {
    try {
      isLoading.value = true;
      error.value = '';

      anunciosActivos.assignAll(await _anuncioService.obtenerActivos());
    } catch (e) {
      error.value = 'Error al cargar anuncios';
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> crearAnuncio({
    required String empresaId,
    required String titulo,
    required String descripcion,
    required DateTime fechaInicio,
    required DateTime fechaFin,
    String? imagenUrl,
  }) async {
    if (titulo.isEmpty || descripcion.isEmpty) {
      error.value = 'Título y descripción son requeridos';
      return false;
    }

    if (!fechaFin.isAfter(fechaInicio)) {
      error.value = 'La fecha de fin debe ser posterior a la de inicio';
      return false;
    }

    try {
      isLoading.value = true;
      error.value = '';

      final nuevo = Anuncio(
        id: '',
        empresaId: empresaId,
        titulo: titulo,
        descripcion: descripcion,
        imagenUrl: imagenUrl,
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
      );

      final id = await _anuncioService.crearAnuncio(nuevo);
      anuncios.insert(0, Anuncio.fromJson({...nuevo.toJson(), 'id': id}));

      Get.snackbar('Anuncio creado', 'El anuncio fue publicado',
          backgroundColor: Colors.green[100], colorText: Colors.black87);
      return true;
    } catch (e) {
      error.value = 'Error al crear el anuncio';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleActivo(String anuncioId, bool activo) async {
    try {
      await _anuncioService.toggleActivo(anuncioId, activo);

      final index = anuncios.indexWhere((a) => a.id == anuncioId);
      if (index != -1) {
        anuncios[index].activo = activo;
        anuncios.refresh();
      }
    } catch (e) {
      error.value = 'Error al cambiar estado del anuncio';
    }
  }

  Future<void> eliminarAnuncio(String anuncioId) async {
    try {
      await _anuncioService.eliminarAnuncio(anuncioId);
      anuncios.removeWhere((a) => a.id == anuncioId);

      Get.snackbar('Anuncio eliminado', 'El anuncio fue removido',
          backgroundColor: Colors.green[100], colorText: Colors.black87);
    } catch (e) {
      error.value = 'Error al eliminar el anuncio';
    }
  }

  void limpiarError() => error.value = '';
}
