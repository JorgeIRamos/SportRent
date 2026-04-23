import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sport_rent/models/calificacion_model.dart';

class CalificacionService {
  final _db = FirebaseFirestore.instance;
  final _col = 'calificaciones';

  Future<String> crearCalificacion(Calificacion calificacion) async {
    final ref = await _db.collection(_col).add(calificacion.toJson());
    return ref.id;
  }

  Future<List<Calificacion>> obtenerPorCancha(String canchaId) async {
    final snap = await _db
        .collection(_col)
        .where('canchaId', isEqualTo: canchaId)
        .orderBy('fecha', descending: true)
        .get();
    return snap.docs
        .map((d) => Calificacion.fromJson({...d.data(), 'id': d.id}))
        .toList();
  }

  Future<List<Calificacion>> obtenerPorUsuario(String usuarioId) async {
    final snap = await _db
        .collection(_col)
        .where('usuarioId', isEqualTo: usuarioId)
        .get();
    return snap.docs
        .map((d) => Calificacion.fromJson({...d.data(), 'id': d.id}))
        .toList();
  }

  Future<List<Calificacion>> obtenerPorReserva(String reservaId) async {
    final snap = await _db
        .collection(_col)
        .where('reservaId', isEqualTo: reservaId)
        .get();
    return snap.docs
        .map((d) => Calificacion.fromJson({...d.data(), 'id': d.id}))
        .toList();
  }

  Future<void> eliminarCalificacion(String id) async {
    await _db.collection(_col).doc(id).delete();
  }
}
