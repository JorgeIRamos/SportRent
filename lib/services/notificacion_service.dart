import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sport_rent/models/notificacion_model.dart';

class NotificacionService {
  final _db = FirebaseFirestore.instance;
  final _col = 'notificaciones';

  Future<String> crearNotificacion(Notificacion notificacion) async {
    final ref = await _db.collection(_col).add(notificacion.toJson());
    return ref.id;
  }

  Future<List<Notificacion>> obtenerPorUsuario(String usuarioId) async {
    final snap = await _db
        .collection(_col)
        .where('usuarioId', isEqualTo: usuarioId)
        .orderBy('fecha', descending: true)
        .get();
    return snap.docs
        .map((d) => Notificacion.fromJson({...d.data(), 'id': d.id}))
        .toList();
  }

  Future<List<Notificacion>> obtenerNoLeidas(String usuarioId) async {
    final snap = await _db
        .collection(_col)
        .where('usuarioId', isEqualTo: usuarioId)
        .where('leida', isEqualTo: false)
        .get();
    return snap.docs
        .map((d) => Notificacion.fromJson({...d.data(), 'id': d.id}))
        .toList();
  }

  Future<void> actualizarNotificacion(
      String id, Map<String, dynamic> datos) async {
    await _db.collection(_col).doc(id).update(datos);
  }

  Future<void> eliminarNotificacion(String id) async {
    await _db.collection(_col).doc(id).delete();
  }
}
