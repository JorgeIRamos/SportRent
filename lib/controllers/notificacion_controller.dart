import 'package:get/get.dart';
import 'package:sport_rent/models/notificacion_model.dart';
import 'package:sport_rent/services/notificacion_service.dart';

class NotificacionController extends GetxController {
  final _notificacionService = NotificacionService();

  final RxList<Notificacion> notificaciones = <Notificacion>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  int get totalNoLeidas => notificaciones.where((n) => !n.leida).length;
  bool get hayNoLeidas => totalNoLeidas > 0;

  Future<void> cargarNotificaciones(String usuarioId) async {
    try {
      isLoading.value = true;
      error.value = '';

      notificaciones.assignAll(
        await _notificacionService.obtenerPorUsuario(usuarioId),
      );
    } catch (e) {
      error.value = 'Error al cargar notificaciones';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> marcarLeida(String notificacionId) async {
    try {
      await _notificacionService.actualizarNotificacion(
          notificacionId, {'leida': true});

      final index = notificaciones.indexWhere((n) => n.id == notificacionId);
      if (index != -1) {
        notificaciones[index].leida = true;
        notificaciones.refresh();
      }
    } catch (e) {
      error.value = 'Error al marcar notificación';
    }
  }

  Future<void> marcarTodasLeidas() async {
    try {
      final noLeidas = notificaciones.where((n) => !n.leida).toList();
      for (final n in noLeidas) {
        await _notificacionService.actualizarNotificacion(n.id, {'leida': true});
        n.leida = true;
      }
      notificaciones.refresh();
    } catch (e) {
      error.value = 'Error al marcar notificaciones';
    }
  }

  Future<void> eliminarNotificacion(String notificacionId) async {
    try {
      await _notificacionService.eliminarNotificacion(notificacionId);
      notificaciones.removeWhere((n) => n.id == notificacionId);
    } catch (e) {
      error.value = 'Error al eliminar notificación';
    }
  }

  Future<void> crearNotificacion(Notificacion notificacion) async {
    try {
      final id = await _notificacionService.crearNotificacion(notificacion);
      notificaciones.insert(0, Notificacion.fromJson({
        ...notificacion.toJson(),
        'id': id,
      }));
    } catch (e) {
      error.value = 'Error al crear notificación';
    }
  }
}
