import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sport_rent/models/cancha_model.dart';

class CanchaService {
  final _db = FirebaseFirestore.instance;
  final _col = 'canchas';

  Future<List<Cancha>> obtenerPorEmpresa(String empresaId) async {
    final snap = await _db
        .collection(_col)
        .where('empresaId', isEqualTo: empresaId)
        .get();
    return snap.docs
        .map((d) => Cancha.fromJson({...d.data(), 'id': d.id}))
        .toList();
  }

  Future<List<Cancha>> obtenerActivas() async {
    final snap = await _db
        .collection(_col)
        .where('activa', isEqualTo: true)
        .get();
    return snap.docs
        .map((d) => Cancha.fromJson({...d.data(), 'id': d.id}))
        .toList();
  }

  Future<List<Cancha>> obtenerPorDeporte(String deporte) async {
    final snap = await _db
        .collection(_col)
        .where('tipoDeporte', isEqualTo: deporte)
        .where('activa', isEqualTo: true)
        .get();
    return snap.docs
        .map((d) => Cancha.fromJson({...d.data(), 'id': d.id}))
        .toList();
  }

  Future<Cancha?> obtenerCancha(String id) async {
    final doc = await _db.collection(_col).doc(id).get();
    if (!doc.exists) return null;
    return Cancha.fromJson({'id': doc.id, ...doc.data()!});
  }

  Future<String> crearCancha(Cancha cancha) async {
    final ref = await _db.collection(_col).add(cancha.toJson());
    return ref.id;
  }

  Future<void> actualizarCancha(String id, Map<String, dynamic> datos) async {
    await _db.collection(_col).doc(id).update(datos);
  }

  Future<void> toggleActiva(String id, bool activa) async {
    await _db.collection(_col).doc(id).update({'activa': activa});
  }

  Future<void> actualizarCalificacion(String id, double promedio) async {
    await _db
        .collection(_col)
        .doc(id)
        .update({'calificacionPromedio': promedio});
  }
}
