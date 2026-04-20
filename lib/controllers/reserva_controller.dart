import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sport_rent/models/reserva_model.dart';

class ReservaController extends GetxController {
  final RxList<Reserva> reservas = <Reserva>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxString filtroEstado = 'Todas'.obs;

  // Estados válidos del sistema
  static const String pendiente = 'pendiente';
  static const String confirmada = 'confirmada';
  static const String cancelada = 'cancelada';
  static const String completada = 'completada';

  List<Reserva> get reservasFiltradas {
    if (filtroEstado.value == 'Todas') return reservas;
    return reservas.where((r) => r.estado == filtroEstado.value.toLowerCase()).toList();
  }

  List<Reserva> get proximas => reservas
      .where((r) => r.estado == pendiente || r.estado == confirmada)
      .where((r) => r.fecha.isAfter(DateTime.now()))
      .toList();

  List<Reserva> get historial => reservas
      .where((r) => r.estado == completada || r.estado == cancelada)
      .toList();

  int get totalConfirmadas => reservas.where((r) => r.estado == confirmada).length;
  int get totalPendientes => reservas.where((r) => r.estado == pendiente).length;
  int get totalCanceladas => reservas.where((r) => r.estado == cancelada).length;
  int get totalCompletadas => reservas.where((r) => r.estado == completada).length;

  Future<void> cargarReservasUsuario(String usuarioId) async {
    try {
      isLoading.value = true;
      error.value = '';
      await Future.delayed(Duration(milliseconds: 600));

      // Mock: reemplazar con llamada al servicio real filtrada por usuarioId
      reservas.assignAll(_reservasMock().where((r) => r.usuarioId == usuarioId));
    } catch (e) {
      error.value = 'Error al cargar reservas';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> cargarReservasEmpresa(String empresaId) async {
    try {
      isLoading.value = true;
      error.value = '';
      await Future.delayed(Duration(milliseconds: 600));

      // Mock: en producción filtra por las canchas de la empresa
      reservas.assignAll(_reservasMock());
    } catch (e) {
      error.value = 'Error al cargar reservas';
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> crearReserva({
    required String usuarioId,
    required String canchaId,
    required DateTime fecha,
    required String horaInicio,
    required String horaFin,
    required double montoTotal,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';
      await Future.delayed(Duration(milliseconds: 500));

      final nueva = Reserva(
        id: 'res_${DateTime.now().millisecondsSinceEpoch}',
        usuarioId: usuarioId,
        canchaId: canchaId,
        fecha: fecha,
        horaInicio: horaInicio,
        horaFin: horaFin,
        montoTotal: montoTotal,
        estado: pendiente,
      );

      reservas.insert(0, nueva);

      Get.snackbar('Reserva creada', 'Tu reserva está pendiente de confirmación',
          backgroundColor: Colors.green[100], colorText: Colors.black87);
      return true;
    } catch (e) {
      error.value = 'No se pudo crear la reserva';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> cancelarReserva(String reservaId) async {
    await _cambiarEstado(reservaId, cancelada,
        mensaje: 'Reserva cancelada correctamente');
  }

  Future<void> confirmarReserva(String reservaId) async {
    await _cambiarEstado(reservaId, confirmada,
        mensaje: 'Reserva confirmada');
  }

  Future<void> completarReserva(String reservaId) async {
    await _cambiarEstado(reservaId, completada,
        mensaje: 'Reserva marcada como completada');
  }

  Future<void> _cambiarEstado(String reservaId, String nuevoEstado,
      {required String mensaje}) async {
    try {
      isLoading.value = true;
      await Future.delayed(Duration(milliseconds: 400));

      final index = reservas.indexWhere((r) => r.id == reservaId);
      if (index != -1) {
        reservas[index].estado = nuevoEstado;
        reservas.refresh();
        Get.snackbar('Listo', mensaje,
            backgroundColor: Colors.green[100], colorText: Colors.black87);
      }
    } catch (e) {
      error.value = 'Error al actualizar la reserva';
    } finally {
      isLoading.value = false;
    }
  }

  void setFiltro(String estado) => filtroEstado.value = estado;

  List<Reserva> _reservasMock() => [
        Reserva(
          id: 'res_001',
          usuarioId: 'user_001',
          canchaId: 'c001',
          fecha: DateTime.now(),
          horaInicio: '15:00',
          horaFin: '16:00',
          montoTotal: 450000,
          estado: confirmada,
        ),
        Reserva(
          id: 'res_002',
          usuarioId: 'user_001',
          canchaId: 'c002',
          fecha: DateTime.now().add(Duration(days: 1)),
          horaInicio: '09:00',
          horaFin: '10:00',
          montoTotal: 320000,
          estado: pendiente,
        ),
        Reserva(
          id: 'res_003',
          usuarioId: 'user_001',
          canchaId: 'c003',
          fecha: DateTime.now().subtract(Duration(days: 5)),
          horaInicio: '10:00',
          horaFin: '11:00',
          montoTotal: 200000,
          estado: completada,
        ),
        Reserva(
          id: 'res_004',
          usuarioId: 'user_001',
          canchaId: 'c001',
          fecha: DateTime.now().subtract(Duration(days: 10)),
          horaInicio: '18:00',
          horaFin: '19:00',
          montoTotal: 450000,
          estado: cancelada,
        ),
      ];
}
