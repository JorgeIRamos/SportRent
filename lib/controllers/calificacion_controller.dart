import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sport_rent/models/calificacion_model.dart';
import 'package:sport_rent/services/calificacion_service.dart';
import 'package:sport_rent/services/cancha_service.dart';

class CalificacionController extends GetxController {
  final _calificacionService = CalificacionService();
  final _canchaService = CanchaService();

  final RxList<Calificacion> calificaciones = <Calificacion>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  double get promedioActual {
    if (calificaciones.isEmpty) return 0.0;
    final suma = calificaciones.fold<int>(0, (acc, c) => acc + c.puntuacion);
    return suma / calificaciones.length;
  }

  Future<void> cargarPorCancha(String canchaId) async {
    try {
      isLoading.value = true;
      error.value = '';

      calificaciones.assignAll(
        await _calificacionService.obtenerPorCancha(canchaId),
      );
    } catch (e) {
      error.value = 'Error al cargar calificaciones';
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> yaCalificada(String usuarioId, String reservaId) async {
    final lista = await _calificacionService.obtenerPorReserva(reservaId);
    return lista.any((c) => c.usuarioId == usuarioId);
  }

  Future<bool> calificar({
    required String usuarioId,
    required String canchaId,
    required String reservaId,
    required int puntuacion,
    String comentario = '',
  }) async {
    if (puntuacion < 1 || puntuacion > 5) {
      error.value = 'La puntuación debe estar entre 1 y 5';
      return false;
    }

    final yaCalifico = await yaCalificada(usuarioId, reservaId);
    if (yaCalifico) {
      error.value = 'Ya calificaste esta reserva';
      return false;
    }

    try {
      isLoading.value = true;
      error.value = '';

      final nueva = Calificacion(
        id: '',
        usuarioId: usuarioId,
        canchaId: canchaId,
        reservaId: reservaId,
        puntuacion: puntuacion,
        comentario: comentario,
      );

      final id = await _calificacionService.crearCalificacion(nueva);
      calificaciones.insert(0, Calificacion.fromJson({...nueva.toJson(), 'id': id}));

      final nuevoPromedio = promedioActual;
      await _canchaService.actualizarCalificacion(canchaId, nuevoPromedio);

      Get.snackbar('Gracias', 'Tu calificación fue enviada',
          backgroundColor: Colors.green[100], colorText: Colors.black87);
      return true;
    } catch (e) {
      error.value = 'Error al enviar la calificación';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void limpiarError() => error.value = '';
}
