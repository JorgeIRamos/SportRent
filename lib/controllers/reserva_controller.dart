import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sport_rent/controllers/notificacion_controller.dart';
import 'package:sport_rent/models/notificacion_model.dart';
import 'package:sport_rent/models/reserva_model.dart';
import 'package:sport_rent/services/cancha_service.dart';
import 'package:sport_rent/services/empresa_service.dart';
import 'package:sport_rent/services/reserva_service.dart';

class ReservaController extends GetxController {
  final _reservaService = ReservaService();
  final _canchaService = CanchaService();
  final _empresaService = EmpresaService();
  NotificacionController get _notificacionCtrl =>
      Get.find<NotificacionController>();

  final RxList<Reserva> reservas = <Reserva>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxString filtroEstado = 'Todas'.obs;
  final RxInt tabSolicitud = (-1).obs;

  static const String pendiente = 'pendiente';
  static const String confirmada = 'confirmada';
  static const String cancelada = 'cancelada';
  static const String rechazada = 'rechazada';
  static const String completada = 'completada';

  List<Reserva> get reservasFiltradas {
    if (filtroEstado.value == 'Todas') return reservas;
    return reservas
        .where((r) => r.estado == filtroEstado.value.toLowerCase())
        .toList();
  }

  List<Reserva> get proximas => reservas
      .where((r) => r.estado == pendiente || r.estado == confirmada)
      .where((r) => r.fecha.isAfter(DateTime.now()))
      .toList();

  List<Reserva> get historial => reservas
      .where(
        (r) =>
            r.estado == completada ||
            r.estado == cancelada ||
            r.estado == rechazada,
      )
      .toList();

  int get totalConfirmadas =>
      reservas.where((r) => r.estado == confirmada).length;
  int get totalPendientes =>
      reservas.where((r) => r.estado == pendiente).length;
  int get totalCanceladas => reservas
      .where((r) => r.estado == cancelada || r.estado == rechazada)
      .length;
  int get totalCompletadas =>
      reservas.where((r) => r.estado == completada).length;

  Future<void> cargarReservasUsuario(String usuarioId) async {
    try {
      isLoading.value = true;
      error.value = '';

      reservas.assignAll(await _reservaService.obtenerPorUsuario(usuarioId));
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

      final canchas = await _canchaService.obtenerPorEmpresa(empresaId);
      if (canchas.isEmpty) {
        reservas.clear();
        return;
      }

      final canchaIds = canchas.map((c) => c.id).take(30).toList();
      reservas.assignAll(await _reservaService.obtenerPorEmpresa(canchaIds));
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
    String? nombreCliente,
    String? nombreCancha,
  }) async {
    if (horaInicio.isEmpty || horaFin.isEmpty) {
      error.value = 'Selecciona la hora de inicio y fin';
      return false;
    }

    if (montoTotal <= 0) {
      error.value = 'El monto debe ser mayor a cero';
      return false;
    }

    try {
      isLoading.value = true;
      error.value = '';

      final nueva = Reserva(
        id: '',
        usuarioId: usuarioId,
        canchaId: canchaId,
        fecha: fecha,
        horaInicio: horaInicio,
        horaFin: horaFin,
        montoTotal: montoTotal,
        estado: pendiente,
        nombreCliente: nombreCliente,
        nombreCancha: nombreCancha,
      );

      final data = nueva.toJson()..remove('id');
      final id = await _reservaService.crearReserva(
        Reserva.fromJson({'id': '', ...data}),
      );
      reservas.insert(0, Reserva.fromJson({'id': id, ...data}));

      // Enviar notificación a la empresa
      try {
        final cancha = await _canchaService.obtenerCancha(canchaId);
        if (cancha != null) {
          final empresa = await _empresaService.obtenerEmpresa(
            cancha.empresaId,
          );
          if (empresa != null) {
            final notif = Notificacion(
              id: '',
              usuarioId: empresa.usuarioId,
              titulo: 'Nueva reserva pendiente',
              mensaje:
                  'Tienes una nueva reserva pendiente para ${nombreCancha ?? 'la cancha'} el ${fecha.day}/${fecha.month} a las $horaInicio. Revisa y confirma.',
              tipo: 'reserva',
            );
            await _notificacionCtrl.crearNotificacion(notif);
          }
        }
      } catch (_) {
        // Ignorar error de notificación
      }

      return true;
    } catch (e) {
      error.value = 'No se pudo crear la reserva';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> cancelarReserva(String reservaId) async => _cambiarEstado(
    reservaId,
    cancelada,
    mensaje: 'Reserva cancelada correctamente',
  );

  Future<void> rechazarReserva(String reservaId) async => _cambiarEstado(
    reservaId,
    rechazada,
    mensaje: 'Reserva rechazada',
    notificarCliente: true,
  );

  Future<void> confirmarReserva(String reservaId) async => _cambiarEstado(
    reservaId,
    confirmada,
    mensaje: 'Reserva confirmada',
    notificarCliente: true,
  );

  Future<void> completarReserva(String reservaId) async => _cambiarEstado(
    reservaId,
    completada,
    mensaje: 'Reserva marcada como completada',
  );

  Future<void> _cambiarEstado(
    String reservaId,
    String nuevoEstado, {
    required String mensaje,
    bool notificarCliente = false,
  }) async {
    try {
      isLoading.value = true;

      await _reservaService.actualizarReserva(reservaId, {
        'estado': nuevoEstado,
      });

      final index = reservas.indexWhere((r) => r.id == reservaId);
      if (index != -1) {
        final reserva = reservas[index];
        reserva.estado = nuevoEstado;
        reservas.refresh();

        if (notificarCliente) {
          try {
            final notif = Notificacion(
              id: '',
              usuarioId: reserva.usuarioId,
              titulo: nuevoEstado == confirmada
                  ? 'Reserva confirmada'
                  : 'Reserva rechazada',
              mensaje: nuevoEstado == confirmada
                  ? 'Tu reserva para ${reserva.nombreCancha ?? 'la cancha'} el ${reserva.fecha.day}/${reserva.fecha.month} a las ${reserva.horaInicio} ha sido confirmada.'
                  : 'Tu reserva para ${reserva.nombreCancha ?? 'la cancha'} el ${reserva.fecha.day}/${reserva.fecha.month} a las ${reserva.horaInicio} ha sido rechazada.',
              tipo: 'reserva',
            );
            await _notificacionCtrl.crearNotificacion(notif);
          } catch (_) {}
        }

        Get.snackbar(
          'Listo',
          mensaje,
          backgroundColor: Colors.green[100],
          colorText: Colors.black87,
        );
      }
    } catch (e) {
      error.value = 'Error al actualizar la reserva';
    } finally {
      isLoading.value = false;
    }
  }

  void setFiltro(String estado) => filtroEstado.value = estado;
  void limpiarError() => error.value = '';
}
